//
//  UIInternalMovieView.m
//  MediaPlayer
//
//  Created by Michael Dales on 08/07/2011.
//  Copyright 2011 Digital Flapjack Ltd. All rights reserved.
//

#import "UIInternalMovieView.h"

@interface UIInternalMovieView()

@end

@implementation UIInternalMovieView

+ (Class)layerClass {
    return [QTMovieLayer class];
}

- (id)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    if( self ) {
        self.userInteractionEnabled = NO;
    }
    
    return self;

}

- (QTMovieLayer*)movieLayer {
    return (QTMovieLayer*)self.layer;
}

- (void)setMovie:(QTMovie *)movie {

    if( _movie ) {
        [_movie stop];
        [_movie invalidate];
        [_movie release];
        [self.movieLayer setMovie:nil];
    }
    _movie = [movie retain];
    if( _movie ) {
        [self.movieLayer setMovie:_movie];
    }

}

///////////////////////////////////////////////////////////////////////////////
//
- (void)dealloc
{
    self.movie = nil;
    [super dealloc];
}

@end
