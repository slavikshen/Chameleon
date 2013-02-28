//
//  QTMovieViewExt.m
//  MediaPlayer
//
//  Created by Jerry Tian on 2/26/13.
//
//

#import "QTMovieViewExt.h"

@interface NotificationTextView : NSTextView {
    
}

@end

@implementation NotificationTextView


@end

@implementation QTMovieViewExt {
    NotificationTextView * _notificationArea;
}

@synthesize flipped = _flipped;

- (void) dealloc {
    if (_notificationArea) {
        [_notificationArea removeFromSuperview];
        [_notificationArea release];
        _notificationArea = nil;
    }
    [super dealloc];
}

- (void) _initAndConfigNotificationArea {
//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_removeNotificationArea) object:nil];
    
    
    if (_notificationArea == nil) {
        _notificationArea = [[NotificationTextView alloc] init];
        [_notificationArea setWantsLayer:YES];
        NSLog(@"do I have a layer? %@", self.layer);
        [self addSubview:_notificationArea];
    }
    
    NSRect parentFrame = self.frame;
    NSSize parentSize = parentFrame.size;
    _notificationArea.frame = NSMakeRect((parentSize.width - 200)/2, 60, 200, 30);
    _notificationArea.textColor = [NSColor whiteColor];
    _notificationArea.backgroundColor = [NSColor clearColor];//[NSColor colorWithCalibratedWhite:0.0 alpha:0.4];
    _notificationArea.font = [NSFont systemFontOfSize:24.0];
    _notificationArea.alignment = NSCenterTextAlignment;
}

- (void) _removeNotificationArea {
    if (_notificationArea) {
        [_notificationArea removeFromSuperview];
        [_notificationArea release];
        _notificationArea = nil;
    }
}

- (void) _adjustVolumnByScrollEvent:(NSEvent *) event {
    
    [self _initAndConfigNotificationArea];
    
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
    
    NSString * volumeTitle = [NSString stringWithFormat:@"Volume: %3.0f%%", volume*100];
    _notificationArea.string = volumeTitle;
    
    [self performSelector:@selector(_removeNotificationArea) withObject:nil afterDelay:3.0f];
}

- (void) _moveBackOrForwardByScollEvent:(NSEvent *) event {
    QTTime currentTime = [self.movie currentTime];
    
    if (event.deltaX > 0) {
        currentTime.timeValue += 1000;
    } else {
        currentTime.timeValue -= 1000;
    }
    
    [self.movie setCurrentTime:currentTime];
    
}

- (void)scrollWheel:(NSEvent *)event {
    if (event.deltaY != 0) {
        [self _adjustVolumnByScrollEvent:event];
        return;
    }
  
    
    if (event.deltaX != 0) {
        [self _moveBackOrForwardByScollEvent:event];
        return;
    }
}


- (void) _playOrStopDelayed {
    float rate = [self.movie rate];
    if (rate == 0) {
        [self.movie autoplay];
    } else {
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
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:QTMovieViewExtNotification_VideoDoubleClicked object:self]];
    } else {
        [self performSelector:@selector(_playOrStopDelayed) withObject:nil afterDelay:0.3];
    }
}

- (void)magnifyWithEvent:(NSEvent *)event {
    NSLog(@"got magnify event: %@", event);
}
@end
