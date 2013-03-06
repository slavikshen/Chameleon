//
//  MPMoviePlayerHUD.h
//  MediaPlayer
//
//  Created by Shen Slavik on 3/5/13.
//
//

#import <UIKit/UIKit.h>

@interface MPMoviePlayerHUD : UIView

- (void)showPause;
//- (void)showPlay;
- (void)showLoading;
- (void)showVolume:(CGFloat)v;
- (void)hide;

@end
