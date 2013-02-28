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
    if ((self = [super init]) != nil)
    {
        self.movie = movie;
        
        _qtMovieView = [[QTMovieViewExt alloc] initWithFrame:NSRectFromCGRect(self.bounds)];
        [_qtMovieView setWantsLayer:NO];
        [_qtMovieView setMovie:movie];
        [_qtMovieView setControllerVisible:YES];
        [_qtMovieView setPreservesAspectRatio:YES];
        [_qtMovieView setFillColor:[NSColor clearColor]];
        [_qtMovieView setEditable:NO];
        [_qtMovieView setShowsResizeIndicator:YES];
        [_qtMovieView setStepButtonsVisible:NO];
        [_qtMovieView setVolumeButtonVisible:NO];
        [_qtMovieView setHotSpotButtonVisible:NO];
        [_qtMovieView setCustomButtonVisible:NO];
        
        
        SInt32 major, minor, bugfix;
        Gestalt(gestaltSystemVersionMajor, &major);
        Gestalt(gestaltSystemVersionMinor, &minor);
        Gestalt(gestaltSystemVersionBugFix, &bugfix);
        
        NSString *systemVersion = [NSString stringWithFormat:@"%d.%d.%d",
                                   major, minor, bugfix];
        NSLog(@"OSX system version detected: %@", systemVersion);
        
        [_qtMovieView setFlipped:NO];
        if (major >= 10 && minor >= 8) {
            [_qtMovieView setFlipped:YES];
        }
        
        _adaptorView = [[UIViewAdapter alloc] initWithNSView:_qtMovieView];
//        _adaptorView.layer.borderWidth = 1;
//        _adaptorView.layer.borderColor = [UIColor redColor].CGColor;
        [self addSubview:_adaptorView];
//        movieLayer = _qtMovieView.layer;
//        [self.layer addSublayer: movieLayer];
        
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



///////////////////////////////////////////////////////////////////////////////
//
- (void)setFrame:(CGRect)frame
{
    NSLog(@"movie frame set to: %@", NSStringFromCGRect(frame));
    [super setFrame: frame];
    
    [_adaptorView setFrame:frame];
    [_qtMovieView setFrame:NSRectFromCGRect(frame)];
}

@end
