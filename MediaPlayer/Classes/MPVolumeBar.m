//
//  MPVolumeBar.m
//  MediaPlayer
//
//  Created by Shen Slavik on 3/8/13.
//
//

#import "MPVolumeBar.h"
#import "UIImage+QTKitImage.h"
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIResponderAppKitIntegration.h>

#define BAR_CORNER_R 3
#define KNOB_W 10
#define KNOB_H 16
#define KNOB_CR 5
#define X_INSET 3
#define Y_INSET 11
#define MIN_NOTIFICATION_CHANGE 0.05f
#define BORDER_SIZE 3
#define LIGHT_R 3
#define IMG_INSET 0

#define BAR_HUE 0.0f
#define MAX_BAR_SATURATION 0.1f

@interface MPVolumeBar()

@property(nonatomic,assign) CALayer* slotBar;
@property(nonatomic,assign) CALayer* volBar;
@property(nonatomic,assign) CALayer* knob;
@property(nonatomic,assign) CAGradientLayer* knobLight;

@property(nonatomic,assign) BOOL draggingKnob;
@property(nonatomic,assign) CGFloat draggingValue;

@property(nonatomic,assign) UIImageView* volumeImage;

@end

@implementation MPVolumeBar


- (id)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    [self _setup];

    return self;
}

- (void)_setup {

    _volume = 1; // default value

    CAGradientLayer* slotBar = [CAGradientLayer layer];
    slotBar.cornerRadius = BAR_CORNER_R;
    slotBar.colors = @[
        (id)[UIColor colorWithWhite:0.1 alpha:0.8f].CGColor,
        (id)[UIColor colorWithWhite:0.25 alpha:0.5f].CGColor,
        (id)[UIColor colorWithWhite:0.3 alpha:0.8f].CGColor,
    ];
    slotBar.locations = @[
        @(0.1f),
        @(0.8f),
        @(1.0f)
    ];
    slotBar.borderWidth = 1;
    slotBar.borderColor = [UIColor colorWithWhite:0.3 alpha:0.1f].CGColor;
    
    CAGradientLayer* volBar = [CAGradientLayer layer];
    volBar.colors = @[
        (id)[UIColor colorWithHue:BAR_HUE saturation:MAX_BAR_SATURATION-0.1f brightness:0.6f alpha:0.5f].CGColor,
        (id)[UIColor colorWithHue:BAR_HUE saturation:MAX_BAR_SATURATION brightness:0.7f alpha:0.5f].CGColor,
    ];

    volBar.startPoint = CGPointMake(0, 0);
    volBar.endPoint = CGPointMake(0,1);
    volBar.cornerRadius = BAR_CORNER_R;
    volBar.borderWidth = 1;
    volBar.borderColor = [UIColor colorWithWhite:0.0f alpha:0.5f].CGColor;

    CAGradientLayer* knob = [CAGradientLayer layer];
    knob.cornerRadius = KNOB_CR;
    knob.colors = @[
        (id)[UIColor colorWithWhite:1.0f alpha:1.0f].CGColor,
        (id)[UIColor colorWithWhite:0.8f alpha:1.0f].CGColor,
    ];
    knob.borderWidth = 0.5f;
    knob.borderColor = [UIColor colorWithWhite:0.0f alpha:0.3f].CGColor;
    knob.shadowOffset = CGSizeMake(0, 0);
    knob.shadowPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, KNOB_W, KNOB_H) cornerRadius:KNOB_CR].CGPath;
    knob.shadowColor = [UIColor blackColor].CGColor;
    knob.shadowRadius = LIGHT_R;
    knob.shadowOpacity = 0.8f;

    CAGradientLayer* knobLight = [CAGradientLayer layer];
    knobLight.cornerRadius = KNOB_CR-2;
    knobLight.colors = @[
        (id)[UIColor colorWithWhite:0.8f alpha:1].CGColor,
        (id)[UIColor colorWithWhite:0.9f alpha:1].CGColor,
        (id)[UIColor colorWithWhite:0.8f alpha:1].CGColor,
    ];
    knobLight.startPoint = CGPointMake(0,0);
    knobLight.endPoint = CGPointMake(1,1);
    knobLight.frame = CGRectMake(BORDER_SIZE/2,BORDER_SIZE/2,KNOB_W-BORDER_SIZE,KNOB_H-BORDER_SIZE);
    
//    CAShapeLayer* maskLayer = [CAShapeLayer layer];
//    UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(-2, -2, KNOB_W+4, KNOB_H+4) cornerRadius:KNOB_CR];
//    [path addArcWithCenter:CGPointMake(KNOB_W/2, KNOB_H/2) radius:(KNOB_W-BORDER_SIZE)/2-1 startAngle:0 endAngle:M_PI*2 clockwise:NO];
//    maskLayer.path = path.CGPath;
//    knob.mask = maskLayer;
    
    CALayer* layer = self.layer;
    
    [layer addSublayer:slotBar];
    [layer addSublayer:volBar];

    [layer addSublayer:knobLight];
    [layer addSublayer:knob];
    
    self.slotBar = slotBar;
    self.volBar = volBar;
    self.knob = knob;
    self.knobLight = knobLight;
    
    UIImageView* volImage = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
    volImage.contentMode = UIViewContentModeScaleAspectFit;
    volImage.image = [UIImage QTKitImageWithName:@"chameleon_qtmovie_volume-3s.png"];
    [self addSubview:volImage];
    self.volumeImage = volImage;

}

- (void)layoutSubviews {

    CGRect bounds = self.bounds;
    CGFloat H = bounds.size.height;
    CGFloat imgSize = H - IMG_INSET*2;
    
    CGRect imgFrame = CGRectMake(IMG_INSET, IMG_INSET, imgSize, imgSize);
    _volumeImage.frame = imgFrame;
    
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {

    [super layoutSublayersOfLayer:layer];

    if( layer == self.layer ) {
        [self _layoutContent];
    }

}

- (void)_layoutContent {

    [self _showSolt];
    if( _draggingKnob ) {
        [self _showVolume:_draggingValue];
    } else {
        [self _showVolume:_volume];
    }
    
}

- (void)setVolume:(CGFloat)v {
    _volume = v;
    [self setNeedsLayout];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    [super touchesBegan:touches withEvent:event];
    
    UITouch* t = [touches anyObject];
    CGPoint p = [t locationInView:self];

    CGFloat percent = [self _percentValueForPosition:p];
    
    if( percent > 1 || percent < 0 ) {
        // ignore
        return;
    }
    
    //start dragging
    _draggingKnob = YES;
    _draggingValue = percent;
    [self _showVolume:_draggingValue];
    
    if( ABS(_draggingValue - _volume) > MIN_NOTIFICATION_CHANGE*2 ) {
        [self setVolume:_draggingValue];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

    [super touchesMoved:touches withEvent:event];

    if( _draggingKnob ) {
    
        UITouch* t = [touches anyObject];
        CGPoint p = [t locationInView:self];

        CGFloat percent = [self _percentValueForPosition:p];
        
        if( percent > 1 || percent < 0 ) {
            // do nothing
        } else {
            _draggingValue = percent;
            [self _showVolume:_draggingValue];
            if( ABS(_draggingValue - _volume) > MIN_NOTIFICATION_CHANGE ) {
                [self setVolume:_draggingValue];
                [self sendActionsForControlEvents:UIControlEventValueChanged];
            }
        }
    }

}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {

    [super touchesCancelled:touches withEvent:event];

    if( _draggingKnob ) {
    
        UITouch* t = [touches anyObject];
        CGPoint p = [t locationInView:self];

        CGFloat percent = [self _percentValueForPosition:p];
        
        if( percent > 1 ) {
            percent = 1;
        } else if( percent < 0 ) {
            percent = 0;
        }
        
        _draggingValue = percent;
        [self _showVolume:_draggingValue];
        [self setVolume:_draggingValue];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    
    _draggingKnob = NO;
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

    [super touchesEnded:touches withEvent:event];
    
    if( _draggingKnob ) {
    
        UITouch* t = [touches anyObject];
        CGPoint p = [t locationInView:self];

        CGFloat percent = [self _percentValueForPosition:p];
        
        if( percent > 1 ) {
            percent = 1;
        } else if( percent < 0 ) {
            percent = 0;
        }
        
        _draggingValue = percent;
        [self _showVolume:_draggingValue];
        [self setVolume:_draggingValue];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    
    _draggingKnob = NO;

}

- (CGRect)_barFrame {
    CGRect bounds = self.bounds;
    // reserve space for icon
    bounds.size.width -= bounds.size.height;
    bounds.origin.x += bounds.size.height;
    
    // bar frame
    CGRect playedFrame = bounds;
    playedFrame.origin.y += Y_INSET;
    playedFrame.size.height -= Y_INSET*2;
    playedFrame.size.width -= X_INSET;
    
    return playedFrame;    
}

- (CGFloat)_percentValueForPosition:(CGPoint)pos {
    
    CGRect maxFrame = [self _barFrame];
    CGFloat percent = (pos.x - maxFrame.origin.x)/maxFrame.size.width;
    
    return percent;

}

- (void)_showVolume:(CGFloat)p {

    CGRect playedFrame = [self _barFrame];
    playedFrame.size.width *= p;
    _volBar.frame = playedFrame;
    
    CGFloat R = CGRectGetMaxX(playedFrame);
    CGFloat cy = CGRectGetMidY(playedFrame);
    CGFloat cx = playedFrame.origin.x + playedFrame.size.width;
    
    if( cx + KNOB_W/2 > R ) {
        cx = R - KNOB_W/2;
    } else if( cx < KNOB_W/2 ) {
        cx = KNOB_W/2;
    }  
    
    CGRect knobFrame = CGRectMake(cx-KNOB_W/2, cy-KNOB_H/2, KNOB_W, KNOB_H );
    CGRect lightFrame = CGRectInset(knobFrame, BORDER_SIZE, BORDER_SIZE);
    
    _knob.frame = knobFrame;
    _knobLight.frame = lightFrame;
    
    NSString* name = @"chameleon_qtmovie_volume-0s.png";
    
    if( p > 0.7f ) {
        name = @"chameleon_qtmovie_volume-3s.png";
    } else if( p > 0.3f ) {
        name = @"chameleon_qtmovie_volume-2s.png";
    } else if ( p > 0.0f ) {
        name = @"chameleon_qtmovie_volume-1s.png";
    }

    _volumeImage.image = [UIImage QTKitImageWithName:name];

}

- (void)_showSolt {
    CGRect frame = [self _barFrame];
    _slotBar.frame = frame;
}

- (void)mouseMoved:(CGPoint)delta withEvent:(UIEvent *)event {

    [super mouseMoved:delta withEvent:event];
    
    [self _showHightlight];
   
}

- (void)mouseExitedView:(UIView *)exited enteredView:(UIView *)entered withEvent:(UIEvent *)event {
    if( exited == self || ![entered isDescendantOfView:self] ) {
        [self _resetHighlight];
    }
}

- (void)_showHightlight {

    _knobLight.colors = @[
        (id)[UIColor colorWithHue:BAR_HUE saturation:0.7f brightness:0.8f alpha:0.8f].CGColor,
        (id)[UIColor colorWithHue:BAR_HUE saturation:1.0f brightness:1.0f alpha:0.8f].CGColor,
    ];
    
    _knob.shadowColor = [UIColor colorWithHue:BAR_HUE saturation:1 brightness:1 alpha:1].CGColor;
}

- (void)_resetHighlight {
    _knobLight.colors = @[
        (id)[UIColor colorWithWhite:0.8f alpha:1].CGColor,
        (id)[UIColor colorWithWhite:0.9f alpha:1].CGColor,
        (id)[UIColor colorWithWhite:0.8f alpha:1].CGColor,
    ];
    _knob.shadowColor = [UIColor blackColor].CGColor;
}



@end
