//
//  MPMoviePlayerHUD.m
//  MediaPlayer
//
//  Created by Shen Slavik on 3/5/13.
//
//

#import "MPMoviePlayerHUD.h"
#import "UIImage+QTKitImage.h"

#import <QuartzCore/QuartzCore.h>

#define MPMoviePlayerHUDPreferredSize 104
#define MPMoviePlayerHUDCornerRadius  10
#define MPMoviePlayerHUDIconInset     20
#define MPMoviePlayerHUDVolumeBlockSize 6
#define MPMoviePlayerHUDVolumeMaxLevel 10

@implementation MPMoviePlayerHUD {
    UIImageView* _imageView;
    
    CAShapeLayer* _volumeLayer;
    CAShapeLayer* _volumeBgLayer;
    
    NSUInteger _volumeLevel;

}

+ (Class)layerClass {
    return [CAShapeLayer class];
}

- (id)init {
    return [self initWithFrame:CGRectMake(0, 0, MPMoviePlayerHUDPreferredSize, MPMoviePlayerHUDPreferredSize)];
}

- (id)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    [self _setup];
    return self;

}

- (void)_setup {

    self.userInteractionEnabled = NO;
    
    CGRect bounds = self.bounds;
    CGRect imgFrame = CGRectInset(bounds, MPMoviePlayerHUDIconInset, MPMoviePlayerHUDIconInset);
    UIImageView* imgView = [[UIImageView alloc] initWithFrame:imgFrame];
    imgView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
                               UIViewAutoresizingFlexibleRightMargin |
                               UIViewAutoresizingFlexibleTopMargin |
                               UIViewAutoresizingFlexibleBottomMargin;
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:imgView];
    
    _imageView = imgView;
    [imgView release];
    
    CAShapeLayer* layer = (CAShapeLayer*)self.layer;
    layer.fillColor = [[UIColor colorWithWhite:0 alpha:0.5f] CGColor];
    layer.lineWidth = 0;

    self.hidden = YES;
    self.alpha = 0;
    

    CAShapeLayer* volumeBgLayer = [CAShapeLayer layer];
    volumeBgLayer.fillColor = [UIColor colorWithWhite:1 alpha:0.2f].CGColor;
    volumeBgLayer.hidden = YES;
    [layer addSublayer:volumeBgLayer];
    _volumeBgLayer = volumeBgLayer;

    CAShapeLayer* volumeLayer = [CAShapeLayer layer];
    volumeLayer.fillColor = [UIColor whiteColor].CGColor;
    volumeLayer.hidden = YES;
    [layer addSublayer:volumeLayer];
    _volumeLayer = volumeLayer;

    UIBezierPath* path = [UIBezierPath bezierPath];
    CGFloat x = 0;
    CGFloat size = MPMoviePlayerHUDVolumeBlockSize;
    CGFloat indent = size/2;
    for( NSUInteger i = MPMoviePlayerHUDVolumeMaxLevel; i != 0; i-- ) {
        [path moveToPoint:CGPointMake(x, 0)];
        [path addLineToPoint:CGPointMake(x+size, 0)];
        [path addLineToPoint:CGPointMake(x+size, size)];
        [path addLineToPoint:CGPointMake(x, size)];
        [path addLineToPoint:CGPointMake(x, 0)];
        x += size + indent;
    }
    
    _volumeBgLayer.path = path.CGPath;

}

- (void)dealloc {
    [self _stopAutoHide];
    [super dealloc];
}

- (void)_show:(BOOL)autoHide {
    
    MPMoviePlayerHUD *s = self;
    s.hidden = NO;
    [UIView animateWithDuration:0.25f animations:^() {
        s.alpha = 1;
    } completion:nil];
    if(autoHide) {
        [self _startAutoHide];
    }
    
}

- (void)hide {
    [self _hide];
}

- (void)_hide {

    [self _stopAutoHide];

    MPMoviePlayerHUD *s = self;
    [UIView animateWithDuration:0.25f animations:^() {
        s.alpha = 0;
    } completion:^(BOOL finish) {
        s.hidden = NO;
    }];
    
}

- (void)showPause {

    _volumeLayer.hidden = YES;
    _volumeBgLayer.hidden = YES;
    [self _stopAutoHide];

    _imageView.image = [UIImage QTKitImageWithName:@"chameleon_qtmovie_pause.png"];

    [self _show:NO];

}

//- (void)showPlay {
//
//    _volumeLayer.hidden = YES;
//    _volumeBgLayer.hidden = YES;
//    
//    [self _stopAutoHide];
//    _imageView.image = [UIImage QTKitImageWithName:@"chameleon_qtmovie_play.png"];
//
//    [self _show:YES];
//}

- (void)showLoading {

    _volumeLayer.hidden = YES;
    _volumeBgLayer.hidden = YES;

    [self _hide];
}

- (void)showVolume:(CGFloat)v {

    [self _stopAutoHide];

    NSString* name = @"chameleon_qtmovie_volume-0.png";
    
    if( v > 0.7f ) {
        name = @"chameleon_qtmovie_volume-3.png";
    } else if( v > 0.3f ) {
        name = @"chameleon_qtmovie_volume-2.png";
    } else if (v > 0.0f ) {
        name = @"chameleon_qtmovie_volume-1.png";
    }

    _imageView.image = [UIImage QTKitImageWithName:name];
    
    NSUInteger vol = ceilf(v/(1.0f/MPMoviePlayerHUDVolumeMaxLevel));
    
    if( vol != _volumeLevel ) {
    
        _volumeLevel = vol;
    
        UIBezierPath* path = [UIBezierPath bezierPath];
        
        CGFloat x = 0;
        CGFloat size = MPMoviePlayerHUDVolumeBlockSize;
        CGFloat indent = size/2;
        for( NSUInteger i = vol; i != 0; i-- ) {
            [path moveToPoint:CGPointMake(x, 0)];
            [path addLineToPoint:CGPointMake(x+size, 0)];
            [path addLineToPoint:CGPointMake(x+size, size)];
            [path addLineToPoint:CGPointMake(x, size)];
            [path addLineToPoint:CGPointMake(x, 0)];
            x += size + indent;
        }
        
        _volumeLayer.path = path.CGPath;
    }

    _volumeLayer.hidden = NO;
    _volumeBgLayer.hidden = NO;
    
    [self _show:YES];
}

- (void)_stopAutoHide {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_autoHide) object:nil];
}

- (void)_startAutoHide {
    [self performSelector:@selector(_autoHide) withObject:nil afterDelay:1];
}

- (void)_autoHide {
    [self _hide];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect:bounds cornerRadius:MPMoviePlayerHUDCornerRadius];
    CAShapeLayer* layer = (CAShapeLayer*)self.layer;
    layer.path = [path CGPath];
    
    CGFloat W = bounds.size.width;
    CGFloat H = bounds.size.height;
    
    CGFloat y = H - MPMoviePlayerHUDCornerRadius - MPMoviePlayerHUDVolumeBlockSize*2;
    CGFloat vw = ceilf(MPMoviePlayerHUDVolumeBlockSize*(MPMoviePlayerHUDVolumeMaxLevel+(MPMoviePlayerHUDVolumeMaxLevel-1)/2));
    CGFloat x = floorf((W-vw)/2);
    CGRect frame = CGRectMake(x, y, vw, MPMoviePlayerHUDVolumeBlockSize);
    
    _volumeLayer.frame = frame;
    _volumeBgLayer.frame = frame;
    
}

@end
