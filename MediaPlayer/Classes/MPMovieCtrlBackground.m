//
//  MPMovieCtrlBackground.m
//  MediaPlayer
//
//  Created by Shen Slavik on 3/6/13.
//
//

#import "MPMovieCtrlBackground.h"
#import <QuartzCore/QuartzCore.h>

#define TOP_INSET 0
#define BOTTOM_INSET 0
#define SEP_W 2.0f

@implementation MPMovieCtrlBackground {

    CAGradientLayer* _leftSep;
    CAGradientLayer* _rightSep;

}

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self _setup];
    return self;
}

- (void)_setup {

    
    NSArray* colors= @[
        (id)[UIColor colorWithWhite:0.3f alpha:0.1f].CGColor,
        (id)[UIColor colorWithWhite:0.0f alpha:0.1f].CGColor,
    ];
    
    CAGradientLayer* left = [CAGradientLayer layer];
    left.colors = colors;
    left.startPoint = CGPointMake(1,0);
    left.endPoint = CGPointMake(0,0);

    CAGradientLayer* right = [CAGradientLayer layer];
    right.colors = colors;
    right.startPoint = CGPointMake(0,0);
    right.endPoint = CGPointMake(1,0);

    
    CALayer* layer = self.layer;
    [layer addSublayer:left];
    [layer addSublayer:right];
    
    _leftSep = left;
    _rightSep = right;
    
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {

    [super layoutSublayersOfLayer:layer];
    if( self.layer == layer ) {
        
        CGRect bounds = layer.bounds;
        CGFloat W = bounds.size.width;
        CGFloat H = bounds.size.height;
        CGFloat sepH = H - TOP_INSET - BOTTOM_INSET;
        CGFloat y = TOP_INSET;
        CGRect leftFrame = CGRectMake(0, y, SEP_W, sepH);
        CGRect rightFrame = CGRectMake(W-SEP_W, y, SEP_W, sepH);
        
        _leftSep.frame = leftFrame;
        _rightSep.frame = rightFrame;
    
    }

}

+ (void)addBackground:(UIView*)v {

    CGRect bounds = v.bounds;
    MPMovieCtrlBackground* bg = [[MPMovieCtrlBackground alloc] initWithFrame:bounds];
    bg.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [v insertSubview:bg atIndex:0];
    [bg release];
    
}

@end
