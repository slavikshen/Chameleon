//
//  QTMovieStateHUD.h
//  MediaPlayer
//
//  Created by Shen Slavik on 3/2/13.
//
//

#import <Cocoa/Cocoa.h>

@interface QTMovieStateHUD : NSView

- (void)showPause;
- (void)showPlay;
- (void)showLoading;
- (void)showVolume:(CGFloat)v;

@end
