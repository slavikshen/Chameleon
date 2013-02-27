//
//  MPMoviewPlayerController.m
//  MediaPlayer
//
//  Created by Michael Dales on 08/07/2011.
//  Copyright 2011 Digital Flapjack Ltd. All rights reserved.
//

#import "MPMoviePlayerController.h"
#import "UIInternalMovieView.h"

NSString *const MPMoviePlayerPlaybackDidFinishReasonUserInfoKey = @"MPMoviePlayerPlaybackDidFinishReasonUserInfoKey";

// notifications
NSString *const MPMoviePlayerPlaybackStateDidChangeNotification = @"MPMoviePlayerPlaybackStateDidChangeNotification";
NSString *const MPMoviePlayerPlaybackDidFinishNotification = @"MPMoviePlayerPlaybackDidFinishNotification";
NSString *const MPMoviePlayerLoadStateDidChangeNotification = @"MPMoviePlayerLoadStateDidChangeNotification";
NSString *const MPMovieDurationAvailableNotification = @"MPMovieDurationAvailableNotification";

@implementation MPMoviePlayerController

@synthesize view=_view;
@synthesize loadState=_loadState;
@synthesize contentURL=_contentURL;
@synthesize controlStyle=_controlStyle;
@synthesize movieSourceType=_movieSourceType;
@synthesize backgroundView=_backgroundView;
@synthesize playbackState=_playbackState;
@synthesize repeatMode=_repeatMode;
@synthesize shouldAutoplay;
@synthesize scalingMode=_scalingMode;

- (void) setContentURL:(NSURL *)contentURL {
    if (contentURL) {
        [_contentURL release];
        _contentURL = nil;
    }
    
    _contentURL = contentURL;
    
    _loadState = MPMovieLoadStateUnknown;
    _controlStyle = MPMovieControlStyleDefault;
    _movieSourceType = MPMovieSourceTypeUnknown;
    _playbackState = MPMoviePlaybackStateStopped;
    _repeatMode = MPMovieRepeatModeNone;
    
    NSError *error = nil;
    QTMovie * movieNew = [[QTMovie alloc] initWithURL: _contentURL
                                   error: &error];
    
    UIInternalMovieView * movieViewNew = [[UIInternalMovieView alloc] initWithMovie: movieNew];
    movieViewNew.scalingMode = _scalingMode;
    
    if (_movieView) {
        UIInternalMovieView * oldMovieView = _movieView;
        QTMovie * oldMovie = _movie;
        
        UIView * superview = _movieView.superview;
        [_movieView removeFromSuperview];
        
        _movie = movieNew;
        movieViewNew.frame = _movieView.frame;
        _movieView = movieViewNew;
        
        [superview addSubview:_movieView];
        
        
        [oldMovieView release];
        [oldMovie release];

    }
}

///////////////////////////////////////////////////////////////////////////////
//
- (void)setScalingMode:(MPMovieScalingMode)scalingMode
{
    _scalingMode = scalingMode;
    _movieView.scalingMode = scalingMode;
}


///////////////////////////////////////////////////////////////////////////////
//
- (void)setRepeatMode:(MPMovieRepeatMode)repeatMode
{
    _repeatMode = repeatMode;
    [_movie setAttribute: [NSNumber numberWithBool: repeatMode == MPMovieRepeatModeOne]
                 forKey: QTMovieLoopsAttribute];
}


///////////////////////////////////////////////////////////////////////////////
//
- (NSTimeInterval)duration
{
    QTTime time = [_movie duration];
    NSTimeInterval interval;
    
    if (QTGetTimeInterval(time, &interval))
        return interval;
    else
        return 0.0;
}


///////////////////////////////////////////////////////////////////////////////
//
- (UIView*)view
{
    return _movieView;
}



///////////////////////////////////////////////////////////////////////////////
//
- (MPMovieLoadState)loadState
{    
    NSNumber* loadState = [_movie attributeForKey: QTMovieLoadStateAttribute];
    
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
            
            
            _loadState = MPMovieLoadStateUnknown;                        
        }
            break;

        
        
        case QTMovieLoadStateLoading:             
            _loadState = MPMovieLoadStateUnknown;            
            break;
            
    
        
        case QTMovieLoadStateLoaded:            
            // we have the meta data, so post the duration available notification
            [[NSNotificationCenter defaultCenter] postNotificationName: MPMovieDurationAvailableNotification
                                                                object: self];
            
            _loadState = MPMovieLoadStateUnknown;            
            break;
            
        case QTMovieLoadStatePlayable:
            _loadState = MPMovieLoadStatePlayable;
            break;
            
        case QTMovieLoadStatePlaythroughOK:
            _loadState = MPMovieLoadStatePlaythroughOK;            
            break;
            
        case QTMovieLoadStateComplete:
            _loadState = MPMovieLoadStatePlaythroughOK;
            
            break;                                
    }
    
    return _loadState;
}


#pragma mark - notifications



///////////////////////////////////////////////////////////////////////////////
//
- (void)didEndOccurred: (NSNotification*)notification
{
    if (notification.object != _movie)
        return;

    _playbackState = MPMoviePlaybackStateStopped;
        
    NSNumber *stopCode = [NSNumber numberWithInt: MPMovieFinishReasonPlaybackEnded];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject: stopCode
                                                         forKey: MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: MPMoviePlayerPlaybackDidFinishNotification
                                                        object: self
                                                      userInfo: userInfo];
}


///////////////////////////////////////////////////////////////////////////////
//
- (void)loadStateChangeOccurred: (NSNotification*)notification
{
    if (notification.object != _movie)
        return;
        
    [[NSNotificationCenter defaultCenter] postNotificationName: MPMoviePlayerLoadStateDidChangeNotification
                                                        object: self];
}

#pragma mark - constructor/destructor

///////////////////////////////////////////////////////////////////////////////
//
- (id)initWithContentURL:(NSURL *)url
{
    self = [super init];
    if (self) 
    {
        _contentURL = [url retain];
        _loadState = MPMovieLoadStateUnknown;
        _controlStyle = MPMovieControlStyleDefault;
        _movieSourceType = MPMovieSourceTypeUnknown;
        _playbackState = MPMoviePlaybackStateStopped;
        _repeatMode = MPMovieRepeatModeNone;
        
        NSError *error = nil;
        _movie = [[QTMovie alloc] initWithURL: url
                                       error: &error];
        
        _movieView = [[UIInternalMovieView alloc] initWithMovie: _movie];
        
        self.scalingMode = MPMovieScalingModeAspectFit;
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(loadStateChangeOccurred:)
                                                     name: QTMovieLoadStateDidChangeNotification
                                                   object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(didEndOccurred:)
                                                     name: QTMovieDidEndNotification 
                                                   object: nil];
    }
    
    return self;
}


///////////////////////////////////////////////////////////////////////////////
//
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    [_movieView release];
    [_movie stop];
    [_movie invalidate];
    [_movie release];
    [_view release];
    [super dealloc];
}


#pragma mark - MPMediaPlayback


///////////////////////////////////////////////////////////////////////////////
//
- (void)play
{
    [_movie autoplay];
    _playbackState = MPMoviePlaybackStatePlaying;
}


///////////////////////////////////////////////////////////////////////////////
//
- (void)pause
{
    [_movie stop];
    _playbackState = MPMoviePlaybackStatePaused;
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
    [_movie stop];
    _playbackState = MPMoviePlaybackStateStopped;
}

#pragma mark - Pending

- (void) setShouldAutoplay:(BOOL)shouldAutoplay {
    NSLog(@"[CHAMELEON] MPMoviePlayerController.shouldAutoplay not implemented");
}

- (UIView*) backgroundView {
    NSLog(@"[CHAMELEON] MPMoviePlayerController.backgroundView not implemented");
    return nil;
}


@end
