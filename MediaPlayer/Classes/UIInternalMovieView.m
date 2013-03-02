//
//  UIInternalMovieView.m
//  MediaPlayer
//
//  Created by Michael Dales on 08/07/2011.
//  Copyright 2011 Digital Flapjack Ltd. All rights reserved.
//

#import "UIInternalMovieView.h"
#import <UIKit/UIViewAdapter.h>
#import "QTMovieViewExt.h"

@implementation UIInternalMovieView

@synthesize movie=_movie;
@synthesize scalingMode=_scalingMode;


///////////////////////////////////////////////////////////////////////////////
//
- (void)setScalingMode:(MPMovieScalingMode)scalingMode
{
    _scalingMode = scalingMode;
    
    CALayer * movieLayer = _qtMovieView.layer;
    switch (scalingMode)
    {
        case MPMovieScalingModeNone:
            movieLayer.contentsGravity = kCAGravityCenter;
            break;
            
        case MPMovieScalingModeAspectFit:
            movieLayer.contentsGravity = kCAGravityResizeAspect;
            break;
            
        case MPMovieScalingModeAspectFill:
            movieLayer.contentsGravity = kCAGravityResizeAspectFill;
            break;
            
        case MPMovieScalingModeFill:
            movieLayer.contentsGravity = kCAGravityResize;
            break;
            
    }
}


///////////////////////////////////////////////////////////////////////////////
//
- (id)initWithMovie:(QTMovie *)movie
{
    if ((self = [super init]) )
    {
        self.movie = movie;
        
        _qtMovieView = [[QTMovieViewExt alloc] initWithFrame:NSRectFromCGRect(self.bounds)];
        [_qtMovieView setWantsLayer:NO];
        [_qtMovieView setMovie:movie];
        [_qtMovieView setControllerVisible:NO];
        [_qtMovieView setPreservesAspectRatio:YES];
        [_qtMovieView setEditable:NO];
        [_qtMovieView setShowsResizeIndicator:NO];
        [_qtMovieView setStepButtonsVisible:NO];
        [_qtMovieView setVolumeButtonVisible:YES];
        [_qtMovieView setHotSpotButtonVisible:NO];
        [_qtMovieView setCustomButtonVisible:NO];
        _qtMovieView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        _adaptorView = [[UIViewAdapter alloc] initWithNSView:_qtMovieView];
        _adaptorView.frame = self.bounds;
        _adaptorView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _adaptorView.scrollEnabled = NO;
        [self addSubview:_adaptorView];

    }
    
    return self;
}

- (QTMovieView *) qtMovieView {
    return _qtMovieView;
}

- (UIViewAdapter *)adaptorView {
    return _adaptorView;
}


///////////////////////////////////////////////////////////////////////////////
//
- (void)dealloc
{
    [_adaptorView release];
    [_qtMovieView release];
    [_movie release];
    [super dealloc];
}

- (void)layoutSubviews {

    [super layoutSubviews];
    _qtMovieView.frame = _adaptorView.frame;

}

@end
