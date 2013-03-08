//
//  MPMoviePlayerControllerView.m
//  MediaPlayer
//
//  Created by Shen Slavik on 3/5/13.
//
//

#import "MPMoviePlayerCtrlPanel.h"
#import "UIImage+QTKitImage.h"
#import "MPMovieCtrlBackground.h"

#import <QuartzCore/QuartzCore.h>
#import <AppKit/AppKit.h>


@interface MPMoviePlayerCtrlPanel()

@property(nonatomic,readwrite,assign) UIButton* playButton;
@property(nonatomic,readwrite,assign) MPMovieProgressBar* progressBar;
@property(nonatomic,readwrite,assign) UIButton* volumeButton;
@property(nonatomic,readwrite,assign) MPVolumeBar* volumeBar;
@property(nonatomic,readwrite,assign) UIButton* fullscreenButton;

@property(nonatomic,readwrite,assign) UILabel* currentTimeLabel;
@property(nonatomic,readwrite,assign) UILabel* durationTimeLabel;


@property(nonatomic,assign) CALayer* shadowLayer;

@end

@implementation MPMoviePlayerCtrlPanel

+ (Class)layerClass {
    return [CAGradientLayer class];
}

-(id)init {
    return [self initWithFrame:CGRectMake(0, 0, 640, 32)];
}

-(id)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    [self _setup];
    
    return self;

}

- (void)_setup {

    CGRect bounds = self.bounds;
    
    CGFloat W = bounds.size.width;
    CGFloat H = bounds.size.height;
    
    #define BUTTON_W (H)
    #define TIME_W (H*1.5f)
    #define VOL_BAR_W (H*4)
    
    // align left
    CGRect playerButtonFrame = CGRectMake(0, 0, BUTTON_W, H);
    CGRect currentFrame = CGRectMake(CGRectGetMaxX(playerButtonFrame), 0, TIME_W, H);
    // align right
    CGRect fullscreenFrame = CGRectMake(W-BUTTON_W, 0, BUTTON_W, H);
    CGRect volumeBarFrame = CGRectMake(CGRectGetMinX(fullscreenFrame)-VOL_BAR_W, 0, VOL_BAR_W, H);
    CGRect durationFrame = CGRectMake(CGRectGetMinX(volumeBarFrame)-TIME_W, 0, TIME_W, H);
    // fill the rest
    CGRect progressBarFrame = CGRectMake(CGRectGetMaxX(currentFrame), 0, CGRectGetMinX(durationFrame) - CGRectGetMaxX(currentFrame), H);
    
    UIButton* playerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    playerButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
    playerButton.frame = playerButtonFrame;
    playerButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    UIImage* playIcon = [UIImage QTKitImageWithName:@"chameleon_qtmovie_play.png"];
    UIImage* pauseIcon = [UIImage QTKitImageWithName:@"chameleon_qtmovie_pauses.png"];
    [playerButton setImage:playIcon forState:UIControlStateNormal];
    [playerButton setImage:pauseIcon forState:UIControlStateSelected];
    [self addSubview:playerButton];
    
    UIButton* fullscreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
    fullscreenButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    fullscreenButton.frame = fullscreenFrame;
    fullscreenButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [fullscreenButton setImage:[UIImage QTKitImageWithName:@"chameleon_qtmovie_fullscreen.png"] forState:UIControlStateNormal];
    [fullscreenButton setImage:[UIImage QTKitImageWithName:@"chameleon_qtmovie_unfullscreen.png"] forState:UIControlStateSelected];
    [self addSubview:fullscreenButton];

    MPMovieProgressBar* progressBar = [[[MPMovieProgressBar alloc] initWithFrame:progressBarFrame] autorelease];
    progressBar.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addSubview:progressBar];
    
    NSString* zeroText = [self secondsToReadableString:0];
    
    UILabel* currentLabel = [[[UILabel alloc] initWithFrame:currentFrame] autorelease];
    currentLabel.textColor = [UIColor whiteColor];
    currentLabel.shadowOffset = CGSizeMake(0, -1);
    currentLabel.shadowColor = [UIColor blackColor];
    currentLabel.font = [UIFont boldSystemFontOfSize:12];
    currentLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
    currentLabel.textAlignment = UITextAlignmentCenter;
    currentLabel.backgroundColor = [UIColor clearColor];
    currentLabel.text = zeroText;
    [self addSubview:currentLabel];
    
    UILabel* durationLabel = [[[UILabel alloc] initWithFrame:durationFrame] autorelease];
    durationLabel.textColor = [UIColor whiteColor];
    durationLabel.shadowOffset = CGSizeMake(0, -1);
    durationLabel.shadowColor = [UIColor blackColor];
    durationLabel.font = [UIFont boldSystemFontOfSize:12];
    durationLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    durationLabel.textAlignment= UITextAlignmentCenter;
    durationLabel.backgroundColor = [UIColor clearColor];
    durationLabel.text = zeroText;
    [self addSubview:durationLabel];
    
//    UIButton* volumeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    volumeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
//    volumeButton.frame = volumeButtonFrame;
//    volumeButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
//    volumeButton.imageEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2);
//    [volumeButton setImage:[UIImage QTKitImageWithName:@"chameleon_qtmovie_volume-2.png"] forState:UIControlStateNormal];
//    [self addSubview:volumeButton];
    
    MPVolumeBar* volumeBar = [[[MPVolumeBar alloc] initWithFrame:volumeBarFrame] autorelease];
    volumeBar.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    [self addSubview:volumeBar];
    
    // decorate all
    for( UIView* v in self.subviews ) {
        [MPMovieCtrlBackground addBackground:v];
    }
    
    self.playButton = playerButton;
    self.currentTimeLabel = currentLabel;
    self.fullscreenButton = fullscreenButton;
    self.durationTimeLabel = durationLabel;
    self.progressBar = progressBar;
//    self.volumeButton = volumeButton;
    self.volumeBar = volumeBar;

    CAGradientLayer* layer = (CAGradientLayer*)self.layer;
    layer.colors = @[
        (id)[UIColor colorWithWhite:0.2f alpha:0.5f].CGColor,
        (id)[UIColor colorWithWhite:0.0f alpha:0.5f].CGColor
    ];
    
    CAGradientLayer* shadowLayer = [CAGradientLayer layer];
    shadowLayer.colors = @[
        (id)[UIColor colorWithWhite:0.0f alpha:0.0f].CGColor,
        (id)[UIColor colorWithWhite:0.0f alpha:0.5f].CGColor
    ];
    
    [layer addSublayer:shadowLayer];
    self.shadowLayer = shadowLayer;


}

- (void)layoutSublayersOfLayer:(CALayer *)layer {


    if( layer == self.layer) {
        
        CGRect bounds = layer.bounds;
        CGFloat W = bounds.size.width;
        
        CGRect shadowFrame = CGRectMake(0, -3, W, 3);
        _shadowLayer.frame = shadowFrame;
        
    }

}

- (void)showTimeState:(MPPlaybackTimeState)time {

    NSString* durationText = [self secondsToReadableString:(long long)time.duration];
    NSString* currentText = [self secondsToReadableString:(long long)time.current];
    
    _currentTimeLabel.text = currentText;
    _durationTimeLabel.text = durationText;
    [_progressBar setPercentLoaded:time.percentLoaded];
    [_progressBar setPercentPlayed:time.percentPlayed];


}

-(NSString*)secondsToReadableString:(long long) seconds{
    long long rest = seconds % 60;
    long long val = seconds / 60;
    
    if(val < 60){
        return [NSString stringWithFormat:@"%lld:%02lld", val, rest];
    }
    long long min = val % 60;
    long long hour = val / 60;
    
    return [NSString stringWithFormat:@"%lld:%02lld:%02lld", hour, min, rest];
}


@end
