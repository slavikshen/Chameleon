//
//  MPMovieView.m
//  MediaPlayer
//
//  Created by Shen Slavik on 3/6/13.
//
//

#import "MPMovieView.h"
#import <AppKit/AppKit.h>
#import <UIKit/UIResponderAppKitIntegration.h>

#define AUTO_HIDE_INTERVAL 3

@implementation MPMovieView {
    BOOL _animating;
}

- (void)dealloc {
    [_customView release];
    [_controlView release];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [super dealloc];
}

- (void)setAutoHide:(BOOL)autoHide {

    [self _stopAutoHide];

    if( _autoHide != autoHide ) {
        _autoHide = autoHide;
        if( _autoHide ) {
            [self _startAutoHide];
        } else {
            [self _showControl];
        }
    }

}

- (void)setControlView:(MPMoviePlayerCtrlPanel *)controlView {

    [self _stopAutoHide];
    
    [_controlView release];
    _controlView = [controlView retain];

    if(_controlView) {
        if( _autoHide ) {
            [self _startAutoHide];
        } else {
            [self _showControl];
        }
    }

}

- (void)_startAutoHide {
    [self performSelector:@selector(_autoHideControl) withObject:nil afterDelay:AUTO_HIDE_INTERVAL];
}

- (void)_stopAutoHide {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_autoHideControl) object:nil];
}

- (void)_autoHideControl {
    if( !_autoHide ) {
        return;
    }
    [self _hideControl];
}

- (void)_showControl {
    if( _controlView.hidden ) {
        _controlView.hidden = NO;
        _customView.hidden = NO;
        [UIView animateWithDuration:0.25f animations:^() {
            _animating = YES;
            _controlView.alpha = 1;
            _customView.alpha = 1;
        } completion:^(BOOL finish) {
            _animating = NO;
        }];
    }
}

- (void)_hideControl {
    if( !_controlView.hidden ) {
        [UIView animateWithDuration:0.25f animations:^() {
            _animating = YES;
            _controlView.alpha = 0;
            _customView.alpha = 0;
        } completion:^(BOOL finish) {
            _animating = NO;
            _controlView.hidden = YES;
            _customView.hidden = YES;
        }];
    }
    [NSCursor setHiddenUntilMouseMoves:YES];
}

- (void)mouseMoved:(CGPoint)delta withEvent:(UIEvent *)event {

    [super mouseMoved:delta withEvent:event];

    if( !_animating ) {
        [self _stopAutoHide];
        
        [self _showControl];    
        if( _autoHide ) {
            [self _startAutoHide];
        }
    }

}

@end
