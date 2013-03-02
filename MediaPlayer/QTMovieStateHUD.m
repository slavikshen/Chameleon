//
//  QTMovieStateHUD.m
//  MediaPlayer
//
//  Created by Shen Slavik on 3/2/13.
//
//

#import "QTMovieStateHUD.h"
#import <AppKit/AppKit.h>

typedef enum {

    QTMovieStateHUDIcon_Loading,
    QTMovieStateHUDIcon_Play,
    QTMovieStateHUDIcon_Pause,
    QTMovieStateHUDIcon_Forward,
    QTMovieStateHUDIcon_Backward,
    QTMovieStateHUDIcon_Volume0,
    QTMovieStateHUDIcon_Volume1,
    QTMovieStateHUDIcon_Volume2
    

} QTMovieStateHUDIconType;

@implementation QTMovieStateHUD {

    CGFloat _volume;
    NSImageCell* _iconCell;

}

- (id)init {
    return [self initWithFrame:CGRectMake(0, 0, 100, 100)];
}

- (id)initWithFrame:(NSRect)frameRect {

    self = [super initWithFrame:frameRect];
    [self _setup];
    return self;

}

- (void)dealloc {
    [self _stopAutoHide];
    [_iconCell release];
    [super dealloc];
}

- (void)_setup {
    
    _iconCell = [[NSImageCell alloc] initImageCell:nil];
    _iconCell.imageAlignment = NSImageAlignCenter;
    _iconCell.imageScaling = NSImageScaleProportionallyUpOrDown;
    _iconCell.imageFrameStyle = NSImageFrameNone;
    
    [self setHidden:YES];
        
}


- (NSImage *)_frameworkImageWithName:(NSString *)name
{
    NSImage *image = [NSImage imageNamed:name];

    if (!image) {    
        NSString* root = [[NSBundle mainBundle] bundlePath];
        NSString* path = [NSString stringWithFormat:@"%@/Contents/Frameworks/MediaPlayer.framework/Resources/%@", root, name];
        image = [[[NSImage alloc] initWithContentsOfFile:path] autorelease];
        [image setName:name];
    }

    return image;
}

- (void)showPause {

    [self _stopAutoHide];

    _iconCell.image = [self _frameworkImageWithName:@"chameleon_qtmovie_pause.png"];
    [self setNeedsDisplay:YES];
    
    [[self animator] setHidden:NO];

}

- (void)showPlay {

    [self _stopAutoHide];

    _iconCell.image = [self _frameworkImageWithName:@"chameleon_qtmovie_play.png"];
    [self setNeedsDisplay:YES];

    [[self animator] setHidden:NO];
    
    [self _startAutoHide];
}

- (void)showLoading {

    [self _stopAutoHide];

    [[self animator] setHidden:NO];
}

- (void)showVolume:(CGFloat)v {

    [self _stopAutoHide];

    NSString* name = @"chameleon_qtmovie_volume-1.png";
    
    if( v > 0.7f ) {
        name = @"chameleon_qtmovie_volume-3.png";
    } else if( v > 0.3f ) {
        name = @"chameleon_qtmovie_volume-2.png";
    }

    _iconCell.image = [self _frameworkImageWithName:name];
    [self setNeedsDisplay:YES];
    
    [[self animator] setHidden:NO];
    
    [self _startAutoHide];

}

- (void)_stopAutoHide {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_autoHide) object:nil];
}

- (void)_startAutoHide {
    
    [self performSelector:@selector(_autoHide) withObject:nil afterDelay:1];

}

- (void)_autoHide {
    
    [[self animator] setHidden:YES];

}

- (void)drawRect:(NSRect)dirtyRect
{

    CGRect bounds = self.bounds;
    [[NSColor colorWithCalibratedWhite:0 alpha:0.5f] setFill];
    [[NSBezierPath bezierPathWithRoundedRect:bounds xRadius:10 yRadius:10] fill];
    // draw state icon

    CGRect iconFrame = CGRectInset(bounds, 20, 20);
    [_iconCell drawWithFrame:iconFrame inView:self];

}

@end
