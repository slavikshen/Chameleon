//
//  QTMovieViewExt.m
//  MediaPlayer
//
//  Created by Jerry Tian on 2/26/13.
//
//

#import "QTMovieViewExt.h"
#import "QTMovieStateHUD.h"

@interface NSView(LocateUIKitView)

- (NSView*)UIKitView;

@end

@implementation NSView(LocateUIKitView)

- (NSView*)locateViewOfClass:(Class)c {

    if( [self isKindOfClass:c] ) {
        return self;
    }

    NSView* ret = nil;
    for( NSView* v in self.subviews ) {
        ret = [v locateViewOfClass:c];
        if( ret ) { break; }
    }
    
    return ret;
}

- (NSView*)UIKitView {
    return [self locateViewOfClass:NSClassFromString(@"UIKitView")];
}

@end

@interface QTMovieViewExt()

@property(nonatomic,retain) NSTrackingArea* trackingArea;
@property(nonatomic,retain) QTMovieStateHUD* hud;

@end


@implementation QTMovieViewExt {
    
    BOOL _flipped;
   
    NSView* _prevSuperview;
    CGRect _frameBeforeExitFullScreen;
    
}

- (id)initWithFrame:(NSRect)frameRect {

    self = [super initWithFrame:frameRect];
    [self _setup];
    return self;
    
}

- (void)_setup {
    [self _checkFlip];
    [self _setupHUD];
    self.fillColor = [NSColor blackColor];
}

- (void)_setupHUD {

    QTMovieStateHUD* hud = [[QTMovieStateHUD alloc] init];
    self.hud = hud;

}

- (void)setHud:(QTMovieStateHUD *)hud {

    if(_hud) {
        [_hud removeFromSuperview];
    }
    _hud = hud;
    if(_hud) {
    
        _hud.autoresizingMask = NSViewMinXMargin | NSViewMaxYMargin |
                                NSViewMaxXMargin | NSViewMinYMargin;
    
        CGRect bounds = self.bounds;
        CGRect frame = hud.frame;
        
        CGFloat W = bounds.size.width;
        CGFloat H = bounds.size.height;
        CGFloat hw = frame.size.width;
        CGFloat hh = frame.size.height;
        
        frame.origin.x = floorf((W-hw)/2);
        frame.origin.y = floorf((H-hh)/2);
        
        hud.frame = frame;
        [self addSubview:hud];
        
    }

}

- (void)_checkFlip {
    SInt32 major, minor, bugfix;
    Gestalt(gestaltSystemVersionMajor, &major);
    Gestalt(gestaltSystemVersionMinor, &minor);
    Gestalt(gestaltSystemVersionBugFix, &bugfix);
    
    NSString *systemVersion = [NSString stringWithFormat:@"%d.%d.%d",
                               major, minor, bugfix];
    NSLog(@"OSX system version detected: %@", systemVersion);
    

    _flipped = (major >= 10 && minor >= 8);
}

- (void) _adjustVolumnByScrollEvent:(NSEvent *) event {
    
    //    NSLog(@"got scroll event: %@", event);
    float volume = [self.movie volume];
    if (event.deltaY > 0.0f) {//scroll down, volumn down.
        volume -= 0.05f;
    } else {
        volume += 0.05f;
    }
    
    if (volume < 0.0f) {
        volume = 0.0f;
    } else if (volume > 1.0f) {
        volume = 1.0f;
    }
    
    [self.movie setVolume:volume];
    [_hud showVolume:volume];

}

- (void) _moveBackOrForwardByScollEvent:(NSEvent *) event {

    QTTime currentTime = [self.movie currentTime];
    
    if (event.deltaX > 0) {
        currentTime.timeValue += currentTime.timeScale/10;
    } else {
        currentTime.timeValue -= currentTime.timeScale/10;
    }
    
    [self.movie setCurrentTime:currentTime];

}

- (void) _playOrStopDelayed {
    float rate = [self.movie rate];
    if (rate == 0) {
        [_hud showPlay];
        [self.movie autoplay];
    } else {
        [_hud showPause];
        [self.movie stop];
    }
}

- (void)mouseDown:(NSEvent *)event {
//    long loadState = [[self.movie attributeForKey:QTMovieLoadStateAttribute] longValue];
//    NSLog(@"got mouse down: %@, load state: %ld, rate: %f", event, loadState, [self.movie rate]);
    
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_playOrStopDelayed) object:nil];
    
    if (event.clickCount > 2) {
        return;
    } else if (event.clickCount == 2) {
        [self switchFullScreen];
//        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:QTMovieViewExtNotification_VideoDoubleClicked object:self]];
    } else {
        [self performSelector:@selector(_playOrStopDelayed) withObject:nil afterDelay:0.3];
    }
}

- (void)scrollWheel:(NSEvent *)event {
//    NSLog(@"movie scroll wheel");
//    
    if (event.deltaY != 0) {
        [self _adjustVolumnByScrollEvent:event];
        return;
    }
  
    
    if (event.deltaX != 0) {
        [self _moveBackOrForwardByScollEvent:event];
        return;
    }

}

- (void)mouseUp:(NSEvent *)theEvent {

}

- (NSRect)movieControllerBounds {

    CGRect bounds = self.bounds;
    CGFloat h = [self controllerBarHeight]+1;
    CGRect frame = CGRectMake(0, 0, bounds.size.width, h);

    return frame;
}

- (BOOL)isFlipped {
    return _flipped;
}

#pragma mark - fullscreen

- (void)switchFullScreen {

    // locate ns window
    NSWindow* win = self.window;
    [win toggleFullScreen:self];

}


- (void)viewDidMoveToWindow {

    [super viewDidMoveToWindow];

    [self unregisterEvent];
    if( self.window ) {
        [self registerEvent];
    }

}

- (void)registerEvent {
    
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(_willEnterFullScreen:) name:NSWindowWillEnterFullScreenNotification object:nil];
    [center addObserver:self selector:@selector(_didEnterFullScreen:) name:NSWindowDidEnterFullScreenNotification object:nil];
    [center addObserver:self selector:@selector(_willExitFullScreen:) name:NSWindowWillExitFullScreenNotification object:nil];
    [center addObserver:self selector:@selector(_didExitFullScreen:) name:NSWindowDidExitFullScreenNotification object:nil];
    [center addObserver:self selector:@selector(_willClose:) name:NSWindowWillCloseNotification object:nil];

}

- (void)unregisterEvent {

    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:NSWindowWillEnterFullScreenNotification object:nil];
    [center removeObserver:self name:NSWindowDidEnterFullScreenNotification object:nil];
    [center removeObserver:self name:NSWindowWillExitFullScreenNotification object:nil];
    [center removeObserver:self name:NSWindowDidExitFullScreenNotification object:nil];
    [center removeObserver:self name:NSWindowWillCloseNotification object:nil];


}

- (void)_willClose:(NSNotification*)n {

    if( n.object != self.window ) { return; }
    
    [[self movie] stop];
    
}

- (void)_willEnterFullScreen:(NSNotification*)n {

    if( n.object != self.window ) { return; }

//    NSLog(@"will enter full screen");
    _prevSuperview = self.superview;
    _frameBeforeExitFullScreen = self.frame;
        
    NSWindow* win = self.window;
    NSView* contentView = win.contentView;
    
    // look for subview of UIKitView
    NSView* uikitView = [contentView UIKitView];
    [uikitView setHidden:YES];
    
    win.backgroundColor = [NSColor blackColor];
    
    [self _hideControl];
}

- (void)_didEnterFullScreen:(NSNotification*)n {

    if( n.object != self.window ) { return; }

//    NSLog(@"did enter full screen");
    
    NSWindow* win = self.window;
    NSView* contentView = win.contentView;
    
    _flipped = NO;
    self.frame = contentView.bounds;
    [contentView addSubview:self];
    
    [self addSubview:_hud positioned:NSWindowAbove relativeTo:nil];

}

- (void)_willExitFullScreen:(NSNotification*)n {

    if( n.object != self.window ) { return; }
    
//    NSLog(@"will exit full screen");
    
    NSWindow* win = self.window;
    NSView* contentView = win.contentView;
    NSView* uikitView = [contentView UIKitView];
    [uikitView setHidden:NO];

}

- (void)_didExitFullScreen:(NSNotification*)n {

    if( n.object != self.window ) { return; }
    
//    NSLog(@"did exit full screen");
    
    [self _checkFlip];
    [_prevSuperview addSubview:self];
    
    self.frame = _frameBeforeExitFullScreen;
    
    [self addSubview:_hud positioned:NSWindowAbove relativeTo:nil];
    
}

- (void)setTrackingArea:(NSTrackingArea *)trackingArea {

    if( _trackingArea ) {
        [self removeTrackingArea:_trackingArea];
    }
    _trackingArea = trackingArea;
    if( _trackingArea ) {
        [self addTrackingArea:_trackingArea];
    }

}

- (void)updateTrackingAreas {

    CGRect bounds = self.bounds;
    NSTrackingArea* trackingArea = [[NSTrackingArea alloc] initWithRect:bounds options:NSTrackingActiveInActiveApp|NSTrackingMouseMoved owner:self userInfo:nil];
    self.trackingArea = trackingArea;
    [trackingArea release];

}

- (void)mouseMoved:(NSEvent *)theEvent {

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_automaticHideControl) object:nil];
    
    if( ![self isControllerVisible] ) {
        [self setControllerVisible:YES];
    }
    
    [self performSelector:@selector(_automaticHideControl) withObject:nil afterDelay:3];

}

- (void)_hideControl {
    [NSCursor setHiddenUntilMouseMoves:YES];
    [self setControllerVisible:NO];
}

- (void)_automaticHideControl {
    [self _hideControl];
}



@end
