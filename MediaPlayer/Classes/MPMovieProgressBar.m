//
//  MPMovieProgressBar.m
//  MediaPlayer
//
//  Created by Shen Slavik on 3/5/13.
//
//

#import "MPMovieProgressBar.h"
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIResponderAppKitIntegration.h>

#define BAR_CORNER_R 5
#define KNOB_SIZE 16
#define X_INSET 16
#define Y_INSET 11
#define MIN_NOTIFICATION_CHANGE 0.05f
#define BORDER_SIZE 3
#define LIGHT_R 2

@interface MPMovieProgressBar()

@property(nonatomic,assign) CALayer* slotBar;
@property(nonatomic,assign) CALayer* loadedProgressBar;
@property(nonatomic,assign) CALayer* playedProgressBar;
@property(nonatomic,assign) CALayer* knob;
@property(nonatomic,assign) CAGradientLayer* knobLight;

@property(nonatomic,assign) BOOL draggingKnob;
@property(nonatomic,assign) CGFloat draggingValue;

@end

@implementation MPMovieProgressBar

- (void)dealloc {

    [self _stopResetHightlight];
    [super dealloc];

}

- (id)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    [self _setup];

    return self;
}

- (void)_setup {

    CAGradientLayer* slotBar = [CAGradientLayer layer];
    slotBar.cornerRadius = BAR_CORNER_R;
    slotBar.colors = @[
        (id)[UIColor colorWithWhite:0 alpha:0.8f].CGColor,
        (id)[UIColor colorWithWhite:0 alpha:0.5f].CGColor,
        (id)[UIColor colorWithWhite:0 alpha:0.8f].CGColor,
    ];
    slotBar.locations = @[
        @(0.1f),
        @(0.9f),
        @(1.0f)
    ];
    slotBar.borderWidth = 1;
    slotBar.borderColor = [UIColor colorWithWhite:0 alpha:0.5f].CGColor;
    
    CAGradientLayer* loadedBar = [CAGradientLayer layer];
    loadedBar.cornerRadius = BAR_CORNER_R;
    loadedBar.colors = @[
        (id)[UIColor colorWithWhite:0.8f alpha:0.3f].CGColor,
        (id)[UIColor colorWithWhite:0.9f alpha:0.3f].CGColor,
    ];
    loadedBar.startPoint = CGPointMake(0,0);
    loadedBar.endPoint = CGPointMake(1,0);
    
    CAGradientLayer* playedBar = [CAGradientLayer layer];
    playedBar.colors = @[
        (id)[UIColor colorWithHue:0 saturation:0.9f brightness:0.6f alpha:1].CGColor,
        (id)[UIColor colorWithHue:0 saturation:1.0f brightness:0.7f alpha:1].CGColor,
    ];

    playedBar.startPoint = CGPointMake(0, 0);
    playedBar.endPoint = CGPointMake(1,0);
    playedBar.cornerRadius = BAR_CORNER_R;
    playedBar.borderWidth = 1;
    playedBar.borderColor = [UIColor colorWithWhite:0.0f alpha:0.5f].CGColor;

    CAGradientLayer* knob = [CAGradientLayer layer];
    knob.cornerRadius = KNOB_SIZE/2;
    knob.colors = @[
        (id)[UIColor colorWithWhite:1.0f alpha:1.0f].CGColor,
        (id)[UIColor colorWithWhite:0.8f alpha:1.0f].CGColor,
    ];
    knob.borderWidth = 0.5f;
    knob.borderColor = [UIColor colorWithWhite:0.0f alpha:0.3f].CGColor;
    knob.shadowOffset = CGSizeMake(0, 0);
    knob.shadowPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(KNOB_SIZE/2, KNOB_SIZE/2) radius:KNOB_SIZE/2 startAngle:0 endAngle:M_PI*2 clockwise:YES].CGPath;
    knob.shadowColor = [UIColor blackColor].CGColor;
    knob.shadowRadius = LIGHT_R;
    knob.shadowOpacity = 0.8f;

    CAGradientLayer* knobLight = [CAGradientLayer layer];
    const CGFloat innerSize = KNOB_SIZE-BORDER_SIZE*2;
    knobLight.cornerRadius = innerSize/2;
    knobLight.colors = @[
        (id)[UIColor colorWithWhite:0.8f alpha:1].CGColor,
        (id)[UIColor colorWithWhite:0.9f alpha:1].CGColor,
        (id)[UIColor colorWithWhite:0.8f alpha:1].CGColor,
    ];
    knobLight.startPoint = CGPointMake(0,0);
    knobLight.endPoint = CGPointMake(1,1);
    knobLight.frame = CGRectMake(BORDER_SIZE/2,BORDER_SIZE/2,innerSize,innerSize);
    
    CAShapeLayer* maskLayer = [CAShapeLayer layer];
    UIBezierPath* path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(KNOB_SIZE/2, KNOB_SIZE/2) radius:KNOB_SIZE+LIGHT_R startAngle:0 endAngle:M_PI*2 clockwise:YES];
    [path appendPath:[UIBezierPath bezierPathWithArcCenter:CGPointMake(KNOB_SIZE/2, KNOB_SIZE/2) radius:innerSize/2-1 startAngle:0 endAngle:M_PI*2 clockwise:NO]];
    maskLayer.path = path.CGPath;
    knob.mask = maskLayer;
    
    CALayer* layer = self.layer;
    
    [layer addSublayer:slotBar];
    [layer addSublayer:loadedBar];
    [layer addSublayer:playedBar];

    [layer addSublayer:knobLight];
    [layer addSublayer:knob];
    
    self.slotBar = slotBar;
    self.loadedProgressBar = loadedBar;
    self.playedProgressBar = playedBar;
    self.knob = knob;
    self.knobLight = knobLight;

}

- (void)layoutSublayersOfLayer:(CALayer *)layer {

    [super layoutSublayersOfLayer:layer];

    if( layer == self.layer ) {
        [self _layoutContent];
    }

}

- (void)_layoutContent {

    [self _showSolt];
    [self _showPercentLoaded:_percentLoaded];
    if( _draggingKnob ) {
        [self _showPercentPlayed:_draggingValue];
    } else {
        [self _showPercentPlayed:_percentPlayed];
    }
    
}

- (void)setPercentLoaded:(CGFloat)percentLoaded {
    _percentLoaded = percentLoaded;
    [self setNeedsLayout];
}

- (void)setPercentPlayed:(CGFloat)percentPlayed {
    _percentPlayed = percentPlayed;
    
    if( _draggingKnob ) {
        return;
    }
    
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
    [self _showPercentLoaded:_draggingValue];
    
    if( ABS(_draggingValue - _percentPlayed) > MIN_NOTIFICATION_CHANGE*2 ) {
        [self setPercentPlayed:_draggingValue];
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
            [self _showPercentLoaded:_draggingValue];
            if( ABS(_draggingValue - _percentPlayed) > MIN_NOTIFICATION_CHANGE ) {
                [self setPercentPlayed:_draggingValue];
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
        [self _showPercentLoaded:_draggingValue];
        [self setPercentPlayed:_draggingValue];
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
        [self _showPercentLoaded:_draggingValue];
        [self setPercentPlayed:_draggingValue];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    
    _draggingKnob = NO;

}

- (CGFloat)_percentValueForPosition:(CGPoint)pos {
    
    CGRect bounds = self.bounds;
    CGRect maxFrame = CGRectInset(bounds,X_INSET,Y_INSET);

    CGFloat percent = (pos.x - maxFrame.origin.x)/maxFrame.size.width;
    
    return percent;

}

- (void)_showPercentPlayed:(CGFloat)p {

    CGRect bounds = self.bounds;
    CGRect playedFrame = CGRectInset(bounds,X_INSET,Y_INSET);
    
    playedFrame.size.width *= p;
    
    _playedProgressBar.frame = playedFrame;
    
    CGFloat H = bounds.size.height;
    CGFloat W = bounds.size.width;
    
    CGFloat cy = floorf(H/2);
    CGFloat cx = playedFrame.origin.x + playedFrame.size.width;
    
    if( cx + KNOB_SIZE/2 > W ) {
        cx = W - KNOB_SIZE/2;
    } else if( cx < KNOB_SIZE/2 ) {
        cx = KNOB_SIZE/2;
    }    
    
    CGRect knobFrame = CGRectMake(cx-KNOB_SIZE/2, cy-KNOB_SIZE/2, KNOB_SIZE, KNOB_SIZE );
    CGRect lightFrame = CGRectInset(knobFrame, BORDER_SIZE, BORDER_SIZE);
    
    _knob.frame = knobFrame;
    _knobLight.frame = lightFrame;

}

- (void)_showPercentLoaded:(CGFloat)p {
    
    CGRect bounds = self.bounds;

    CGRect loadedFrame = CGRectInset(bounds,X_INSET,Y_INSET);
    
    loadedFrame.size.width *= p;
    _loadedProgressBar.frame = loadedFrame;

}

- (void)_showSolt {
    CGRect bounds = self.bounds;
    CGRect frame = CGRectInset(bounds,X_INSET-0.5f,Y_INSET-0.5f);
    _slotBar.frame = frame;
}

- (void)mouseMoved:(CGPoint)delta withEvent:(UIEvent *)event {

    [super mouseMoved:delta withEvent:event];
    
    [self _showHightlight];
   
}

- (void)mouseExitedView:(UIView *)exited enteredView:(UIView *)entered withEvent:(UIEvent *)event {

    [super mouseExitedView:exited enteredView:entered withEvent:event];
    
    if( exited == self ) {
        [self _stopResetHighlight];
    } else {
        [self performSelector:@selector(_resetHighlight) withObject:nil afterDelay:1];
    }

}

- (void)_stopResetHighlight {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_resetHighlight) object:nil];
}

- (void)_showHightlight {

    [self _stopResetHighlight];

    _knobLight.colors = @[
        (id)[UIColor colorWithHue:0 saturation:0.7f brightness:0.8f alpha:0.8f].CGColor,
        (id)[UIColor colorWithHue:0 saturation:1.0f brightness:1.0f alpha:0.8f].CGColor,
    ];
    
    _knob.shadowColor = [UIColor colorWithHue:0 saturation:1 brightness:1 alpha:1].CGColor;
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
