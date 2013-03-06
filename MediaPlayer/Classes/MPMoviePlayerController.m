//
//  MPMoviewPlayerController.m
//  MediaPlayer
//
//  Created by Michael Dales on 08/07/2011.
//  Copyright 2011 Digital Flapjack Ltd. All rights reserved.
//

#import "MPMoviePlayerController.h"
#import "UIInternalMovieView.h"
#import "MPMoviePlayerHUD.h"
#import "QTMovie+PlaybackStatusAfx.h"
#import "MPMovie.h"
#import "MPMoviePlayerCtrlPanel.h"
#import "MPMovieView.h"

NSString *const MPMoviePlayerPlaybackDidFinishReasonUserInfoKey = @"MPMoviePlayerPlaybackDidFinishReasonUserInfoKey";
// notifications
NSString *const MPMoviePlayerPlaybackStateDidChangeNotification = @"MPMoviePlayerPlaybackStateDidChangeNotification";
NSString *const MPMoviePlayerPlaybackDidFinishNotification = @"MPMoviePlayerPlaybackDidFinishNotification";
NSString *const MPMoviePlayerLoadStateDidChangeNotification = @"MPMoviePlayerLoadStateDidChangeNotification";
NSString *const MPMovieDurationAvailableNotification = @"MPMovieDurationAvailableNotification";

NSString *const MPMoviePlayerControllerVolumeSetting = @"MPMoviePlayerControllerVolumeSetting";

@interface MPMoviePlayerController()<UIGestureRecognizerDelegate>

@property(nonatomic,retain) UIInternalMovieView* movieView;
@property(nonatomic,retain) MPMoviePlayerCtrlPanel* controlView;
@property(nonatomic,retain) MPMoviePlayerHUD* hud;


@property(nonatomic, readwrite, assign) MPMoviePlaybackState playbackState;

@property(nonatomic, retain) MPMovieView *normalHost;
@property(nonatomic, retain) MPMovieView* fullscreenHost;


@property(nonatomic,retain) NSDate* lastTapTime;

@end

@implementation MPMoviePlayerController {
    BOOL _didPauseVideoForWindowClose;
    BOOL _didToggleWindowFullscreen;
}

@synthesize contentURL=_contentURL;
@synthesize controlStyle=_controlStyle;
@synthesize movieSourceType=_movieSourceType;
@synthesize backgroundView=_backgroundView;
@synthesize playbackState=_playbackState;
@synthesize repeatMode=_repeatMode;

@dynamic loadState;
@dynamic movie;
@dynamic fullscreen;
@dynamic scalingMode;
@dynamic view;


-(UIView*)view {
    return (_fullscreenHost?_fullscreenHost:_normalHost);
}

- (void)setScalingMode:(MPMovieScalingMode)scalingMode {
    _movieView.scalingMode = scalingMode;
}

- (MPMovieScalingMode)scalingMode {
    return _movieView.scalingMode;
}

- (BOOL)isFullscreen {
    return (nil != _fullscreenHost);
}

- (QTMovie*)movie {
    return _movieView.movie;
}


- (void)_showMovieView {
    UIView* host = self.view;
    _movieView.frame = host.bounds;
    if( _backgroundView ) {
        [host insertSubview:_movieView aboveSubview:_backgroundView];
    } else {
        [host insertSubview:_movieView atIndex:0];
    }
}

- (void)setMovieView:(UIInternalMovieView *)movieView {

    if( _movieView ) {
        [_movieView removeFromSuperview];
        [_movieView release];
    }
    _movieView = [movieView retain];
    if( _movieView ) {
        _movieView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self _showMovieView];
    }
    
}

- (void)_showHUD {
    UIView* host = self.view;
    CGRect bounds = host.bounds;
    CGFloat W = bounds.size.width;
    CGFloat H = bounds.size.height;
    CGSize size = _hud.frame.size;
    CGRect frame = CGRectMake(floorf((W-size.width)/2), floorf((H-size.height)/2), size.width, size.height);
    _hud.frame = frame;
    [host addSubview:_hud];
}

- (void)setHud:(MPMoviePlayerHUD *)hud {

    if( _hud ) {
        [_hud removeFromSuperview];
        [_hud release];
    }
    _hud = [hud retain];
    if( _hud ) {
        _hud.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
                            UIViewAutoresizingFlexibleRightMargin |
                            UIViewAutoresizingFlexibleTopMargin |
                            UIViewAutoresizingFlexibleBottomMargin;
        [self _showHUD];
    }

}

- (void)_showControllerView {

    MPMovieView* host = (MPMovieView*)self.view;;
    CGRect bounds = host.bounds;
    CGFloat W = bounds.size.width;
    CGFloat H = bounds.size.height;
    CGFloat ch = _controlView.frame.size.height;
    CGRect frame = CGRectMake(0, H-ch, W, ch);
    _controlView.frame = frame;

    [host addSubview:_controlView];
    host.controlView = _controlView;

}

- (void)setControlView:(MPMoviePlayerCtrlPanel *)controlView {

    if(_controlView) {
        [_controlView removeFromSuperview];
        [_controlView release];
    }
    _controlView = [controlView retain];
    if( _controlView ) {
        _controlView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin |
                                        UIViewAutoresizingFlexibleWidth;
        [_controlView.progressBar addTarget:self action:@selector(_progressBarDragged:) forControlEvents:UIControlEventValueChanged];
        [_controlView.playButton addTarget:self action:@selector(_playButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_controlView.fullscreenButton addTarget:self action:@selector(_toogleFullscreenButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self _showControllerView];
    }
}

- (void)_showCustomControllerView {

    MPMovieView* host = (MPMovieView*)self.view;;
    CGRect bounds = host.bounds;
    CGFloat W = bounds.size.width;
    CGFloat ch = _controlView.frame.size.height;
    CGRect frame = CGRectMake(0, 0, W, ch);
    _customControllerView.frame = frame;

    [host addSubview:_customControllerView];
    host.customView = _customControllerView;

}

- (void)setCustomControllerView:(UIView *)customControllerView {

    if(_customControllerView) {
        [_customControllerView removeFromSuperview];
        [_customControllerView release];
    }
    _customControllerView = [customControllerView retain];
    if( _customControllerView ) {
        _customControllerView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin |
                                                 UIViewAutoresizingFlexibleWidth;
        [self _showCustomControllerView];
    }

}

- (void) setContentURL:(NSURL *)contentURL {

    [self _stopCheckProgress];

    if (_contentURL) {
        [self _unregisterEvents];
        [_contentURL release];
        _contentURL = nil;        
    }
    
    _contentURL = [contentURL copy];
    
    if( _contentURL ) {
    
        [self _registerEvents];
        
        self.movieSourceType = MPMovieSourceTypeUnknown;
        self.playbackState = MPMoviePlaybackStateStopped;
        
        NSError *error = nil;
        QTMovie * movie = [[MPMovie alloc] initWithURL: _contentURL error: &error];
        if( movie ) {
            [movie setAttribute: @(_repeatMode == MPMovieRepeatModeOne)
                      forKey: QTMovieLoopsAttribute];
            _movieView.movie = movie;
            [movie release];
        }        
        
    } else {
         _movieView.movie = nil;
    }
}


///////////////////////////////////////////////////////////////////////////////
//
- (void)setRepeatMode:(MPMovieRepeatMode)repeatMode
{
    _repeatMode = repeatMode;
    [self.movie setAttribute: @(repeatMode == MPMovieRepeatModeOne)
                      forKey: QTMovieLoopsAttribute];
}


///////////////////////////////////////////////////////////////////////////////
//
- (NSTimeInterval)duration
{
    return [self.movie durationSecond];
}


///////////////////////////////////////////////////////////////////////////////
//
- (MPMovieLoadState)loadState
{    
    NSNumber* loadState = [self.movie attributeForKey: QTMovieLoadStateAttribute];
    
    MPMovieLoadState mpLoadState = MPMovieLoadStateUnknown;
    
    switch ([loadState intValue]) {
        case QTMovieLoadStateError:            
        {
            NSLog(@"woo");
            NSNumber *stopCode = [NSNumber numberWithInt: MPMovieFinishReasonPlaybackError];
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject: stopCode
                                                                 forKey: MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
            
            // if there's a loading error we generate a stop notification
            [[NSNotificationCenter defaultCenter] postNotificationName: MPMoviePlayerPlaybackDidFinishNotification
                                                                object: self 
                                                              userInfo: userInfo];
            
            
            mpLoadState = MPMovieLoadStateUnknown;                        
        }
            break;

        
        
        case QTMovieLoadStateLoading:             
            mpLoadState = MPMovieLoadStateUnknown;            
            break;
            
    
        
        case QTMovieLoadStateLoaded:            
            // we have the meta data, so post the duration available notification
            [[NSNotificationCenter defaultCenter] postNotificationName: MPMovieDurationAvailableNotification
                                                                object: self];
            
            mpLoadState = MPMovieLoadStateUnknown;            
            break;
            
        case QTMovieLoadStatePlayable:
            mpLoadState = MPMovieLoadStatePlayable;
            break;
            
        case QTMovieLoadStatePlaythroughOK:
            mpLoadState = MPMovieLoadStatePlaythroughOK;            
            break;
            
        case QTMovieLoadStateComplete:
            mpLoadState = MPMovieLoadStatePlaythroughOK;
            
            break;                                
    }
    
    return mpLoadState;
}


#pragma mark - notifications



///////////////////////////////////////////////////////////////////////////////
//
- (void)_didEndOccurred: (NSNotification*)notification
{
    if (notification.object != self.movie)
        return;

    self.playbackState = MPMoviePlaybackStateStopped;
        
    NSNumber *stopCode = [NSNumber numberWithInt: MPMovieFinishReasonPlaybackEnded];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject: stopCode
                                                         forKey: MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: MPMoviePlayerPlaybackDidFinishNotification
                                                        object: self
                                                      userInfo: userInfo];
}


///////////////////////////////////////////////////////////////////////////////
//
- (void)_loadStateChangeOccurred: (NSNotification*)notification
{
    QTMovie* movie = self.movie;
    id obj = notification.object;
    if( obj != movie )
        return;

    [self _startCheckProgress];
    [[NSNotificationCenter defaultCenter] postNotificationName: MPMoviePlayerLoadStateDidChangeNotification
                                                        object: self];
}

- (void)_playRateDidChanged:(NSNotification*)n {

    QTMovie* movie = self.movie;
    if (n.object != movie)
        return;
//    NSNumber* rate = [n.userInfo objectForKey:QTMovieRateDidChangeNotificationParameter];
//    if( [rate boolValue] ) {

    if( [movie isPlaying] ) {
         // private method isPlaying is more acurrate
        [self _startCheckProgress];
        self.playbackState = MPMoviePlaybackStatePlaying;
        
        CGFloat vol = [[NSUserDefaults standardUserDefaults] floatForKey:MPMoviePlayerControllerVolumeSetting];
        if( ABS(vol-movie.volume)>0.05 ) {
            movie.volume = vol;
        }
        
        _normalHost.autoHide = YES;
        _fullscreenHost.autoHide = YES;
        
    } else {
        if( [movie percentPlayed] < 1 ) {
            self.playbackState = MPMoviePlaybackStatePaused;
        }
        _normalHost.autoHide = NO;
        _fullscreenHost.autoHide = NO;
    }

}

- (void)_volumeDidChange:(NSNotification*)n {

    QTMovie* movie = self.movie;
    if (n.object != movie)
        return;
    CGFloat vol = movie.volume;
    [[NSUserDefaults standardUserDefaults] setFloat:vol forKey:MPMoviePlayerControllerVolumeSetting];
}

- (void)_windowDidClosed:(NSNotification*)n {

    NSWindow* win = [self NSWindow];
    if( n.object == win ) {
        QTMovie* movie = self.movie;
        if( [movie isPlaying] ) {
            _didPauseVideoForWindowClose = YES;
            [movie stop];
        }
    }

}

- (void)_windowDidBecomeMain:(NSNotification*)n {
    NSWindow* win = [self NSWindow];
    if( n.object == win ) {
        QTMovie* movie = self.movie;
        if( ![movie isPlaying] && _didPauseVideoForWindowClose ) {
            [movie autoplay];
        }
        _didPauseVideoForWindowClose = NO;
    }
}


#pragma mark - constructor/destructor

- (void)_registerEvents {
    NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
    
    [defaultCenter addObserver: self
                      selector: @selector(_loadStateChangeOccurred:)
                          name: QTMovieLoadStateDidChangeNotification
                        object: nil];
    
    [defaultCenter addObserver: self
                      selector: @selector(_didEndOccurred:)
                          name: QTMovieDidEndNotification
                        object: nil];
    
    [defaultCenter addObserver: self
                      selector: @selector(_playRateDidChanged:)
                          name: QTMovieRateDidChangeNotification
                        object: nil];
    [defaultCenter addObserver: self
                      selector: @selector(_volumeDidChange:)
                          name: QTMovieVolumeDidChangeNotification
                        object: nil];
    
    [defaultCenter addObserver: self
                      selector: @selector(_windowDidClosed:)
                          name:NSWindowWillCloseNotification
                        object:nil];
    [defaultCenter addObserver: self
                      selector: @selector(_windowDidBecomeMain:)
                          name:NSWindowDidBecomeMainNotification
                        object:nil];
}

- (void)_unregisterEvents {
    NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self name:QTMovieLoadStateDidChangeNotification object:nil];
    [defaultCenter removeObserver:self name:QTMovieDidEndNotification object:nil];
    [defaultCenter removeObserver:self name:QTMovieRateDidChangeNotification object:nil];
    [defaultCenter removeObserver:self name:QTMovieVolumeDidChangeNotification object:nil];
    [defaultCenter removeObserver:self name:NSWindowWillCloseNotification object:nil];
    [defaultCenter removeObserver:self name:NSWindowDidBecomeMainNotification object:nil];
}

///////////////////////////////////////////////////////////////////////////////
//
- (id)initWithContentURL:(NSURL *)url
{
    self = [super init];
    if (self) 
    {
        _controlStyle = MPMovieControlStyleDefault;
        _repeatMode = MPMovieRepeatModeNone;

        _normalHost = [[MPMovieView alloc] initWithFrame:CGRectMake(0, 0, 640, 480)];
        [self _setupGestures:_normalHost];
        
        UIInternalMovieView * movieView = [[[UIInternalMovieView alloc] initWithFrame:_normalHost.bounds] autorelease];
        self.movieView = movieView;
        
        MPMoviePlayerCtrlPanel* controlView = [[[MPMoviePlayerCtrlPanel alloc] init] autorelease];
        self.controlView = controlView;
        
        MPMoviePlayerHUD* hud = [[[MPMoviePlayerHUD alloc] init] autorelease];
        self.hud = hud;

        self.scalingMode = MPMovieScalingModeAspectFit;
        self.contentURL = url;
        
        
    }
    
    return self;
}


///////////////////////////////////////////////////////////////////////////////
//
- (void)dealloc
{
    [self _stopCheckProgress];
    if( _contentURL ) {
        self.contentURL = nil;
    }
    self.customControllerView = nil;
    self.controlView = nil;
    self.hud = nil;
    self.backgroundView = nil;
    self.movieView = nil;
    self.normalHost = nil;
    self.fullscreenHost = nil;
    self.lastTapTime = nil;
    [super dealloc];
}


#pragma mark - MPMediaPlayback

- (void)setPlaybackState:(MPMoviePlaybackState)playbackState {

    if( _playbackState != playbackState ) {
    
        _playbackState = playbackState;

        switch( playbackState ) {
        case MPMoviePlaybackStateStopped:
            [_hud hide];
        break;
        case MPMoviePlaybackStatePaused:
            [_hud showPause];
            _controlView.playButton.selected = NO;
        break;
        case MPMoviePlaybackStatePlaying:
            [_hud hide];
            _controlView.playButton.selected = YES;
        break;
        case MPMoviePlaybackStateInterrupted:
        case MPMoviePlaybackStateSeekingForward:
        case MPMoviePlaybackStateSeekingBackward:
        break;
        }
    }

}

///////////////////////////////////////////////////////////////////////////////
//
- (void)play
{
    [self.movie autoplay];
//    self.playbackState = MPMoviePlaybackStatePlaying;
}


///////////////////////////////////////////////////////////////////////////////
//
- (void)pause
{
    [self.movie stop];
//    self.playbackState = MPMoviePlaybackStatePaused;
}

///////////////////////////////////////////////////////////////////////////////
//
- (void)prepareToPlay {
    // Do nothing
}

///////////////////////////////////////////////////////////////////////////////
//
- (void)stop
{
    [self.movie stop];
//    self.playbackState = MPMoviePlaybackStateStopped;
}

#pragma mark - Pending

- (void) setShouldAutoplay:(BOOL)shouldAutoplay {
    NSLog(@"[CHAMELEON] MPMoviePlayerController.shouldAutoplay not implemented");
}

#pragma mark - gestures

- (void)_setupGestures:(UIControl*)mView {

    [mView addTarget:self action:@selector(_clickMovie:) forControlEvents:UIControlEventTouchUpInside];
    
    UIPanGestureRecognizer* pan = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_pan:)] autorelease];
    [mView addGestureRecognizer:pan];
    
    UIScrollWheelGestureRecognizer* wheel = [[[UIScrollWheelGestureRecognizer alloc] initWithTarget:self action:@selector(_pan:)] autorelease];
    [mView addGestureRecognizer:wheel];

}

- (void)_clickMovie:(UIControl*)sender {
    if( nil == _lastTapTime ) {
        [self performSelector:@selector(_singleTapTimeout) withObject:nil afterDelay:0.3f];
        self.lastTapTime = [NSDate date];
    } else {
        self.lastTapTime = nil;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_singleTapTimeout) object:nil];
        [self _toggleFullscreen];
    }
}

- (void)_singleTapTimeout {
    self.lastTapTime = nil;
    [self _playOrStopDelayed];
}

- (void)_pan:(UIPanGestureRecognizer*)pan {

    UIGestureRecognizerState state = pan.state;
    if( UIGestureRecognizerStateChanged == state ||
        UIGestureRecognizerStateRecognized == state ) {
        CGPoint t = [pan translationInView:pan.view];
        if( ABS(t.y)>ABS(t.x) ) {
            // change volume
            [self _changeVolumeByY:t.y];
        } else {
            // step forward or backward
            [self _changeTimeByX:t.x];
        }
   }

}

- (void)_changeVolumeByY:(CGFloat)y {

    QTMovie* movie = self.movie;
    float volume = [movie volume];
    float newVolume = volume;
    if( y < -20 ) {//scroll down, volumn down.
        newVolume -= 0.005f;
    } else if( y > 20 ) {
        newVolume += 0.005f;
    }
    
    if (newVolume < 0 ) {
        newVolume = 0;
    } else if (newVolume > 1) {
        newVolume = 1;
    }

    [_hud showVolume:newVolume];
    
    [movie setVolume:newVolume];
}

- (void)_changeTimeByX:(CGFloat)x {

    QTMovie* movie = self.movie;
    NSTimeInterval currentTime = [movie playedSeconds];
    if (x > 20) {
        [movie setPlayedSeconds:currentTime-0.5f];
        [self _checkProgress];
    } else if( x < -20 ) {
        [movie setPlayedSeconds:currentTime+0.5f];
        [self _checkProgress];
    }

}

- (void)_stopCheckProgress {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_checkProgress) object:nil];
}

- (void)_startCheckProgress {
    [self _stopCheckProgress];
    [self performSelector:@selector(_checkProgress) withObject:nil afterDelay:1];
}

- (void)_checkProgress {

    MPPlaybackTimeState playbackTimeState = [self.movie playbackTimeState];
    [_controlView showTimeState:playbackTimeState];

    if( playbackTimeState.percentPlayed < 1 || playbackTimeState.percentLoaded < 1 ) {
        [self performSelector:@selector(_checkProgress) withObject:nil afterDelay:1];
    }

}

- (void)_progressBarDragged:(MPMovieProgressBar*)progressBar {

    CGFloat p = progressBar.percentPlayed;
    [self.movie gotoPercent:p];

}

- (void)_playButtonClicked:(UIButton*)b {
    [self _playOrStopDelayed];
}

- (void)_toogleFullscreenButtonClicked:(UIButton*)b {
    [self _toggleFullscreen];
}

#pragma mark - movie control

- (NSWindow*)NSWindow {
    UIWindow* window = [_normalHost window];
    UIScreen* screen = window.screen;
    UIKitView* uikit = screen.UIKitView;
    NSWindow* win = [uikit window];
    return win;
}

- (void) _playOrStopDelayed {
    float rate = [self.movie rate];
    if (rate == 0) {
        [self.movie play];
    } else {
//        [_hud showPause];
        [self.movie stop];
    }
}

- (void)_toggleFullscreen {

    
    if( [self isFullscreen] ) {
        // restore to prev mode
        self.fullscreenHost = nil;
        if( _didToggleWindowFullscreen ) {
            [[self NSWindow] toggleFullScreen:nil];
            _didToggleWindowFullscreen = NO;
        }
    } else {
        // switch to fullscreen
        MPMovieView* fullscreen = [[MPMovieView alloc] initWithFrame:CGRectZero];
        self.fullscreenHost = fullscreen;
        [fullscreen release];

        NSWindow* win = [self NSWindow];
        BOOL isWinFullscreen = (([win styleMask] & NSFullScreenWindowMask) == NSFullScreenWindowMask);
        
        if( !isWinFullscreen ) {
            _didToggleWindowFullscreen = YES;
            [win toggleFullScreen:nil];
        }
        
    }

}

- (void)setFullscreenHost:(MPMovieView *)view {

    if( _fullscreenHost ) {
        [_fullscreenHost removeFromSuperview];
        [_fullscreenHost release];
    }
    
    _fullscreenHost = [view retain];
    
    if( _fullscreenHost ) {
        UIWindow* win = _normalHost.window;
        _fullscreenHost.backgroundColor = [UIColor blackColor];
        _fullscreenHost.frame = win.bounds;
        _fullscreenHost.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [win addSubview:_fullscreenHost];
        _fullscreenHost.autoHide = [self.movie isPlaying];
        [self _setupGestures:_fullscreenHost];
        _normalHost.userInteractionEnabled = NO;
    } else {
        _normalHost.userInteractionEnabled = YES;
    }

    [self _showMovieView];
    [self _showControllerView];
    [self _showCustomControllerView];
    [self _showHUD];

}

@end
