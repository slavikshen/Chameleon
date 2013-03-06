//
//  MPMoviePlayerControllerView.h
//  MediaPlayer
//
//  Created by Shen Slavik on 3/5/13.
//
//

#import <UIKit/UIKit.h>
#import "MPMovieProgressBar.h"
#import "QTMovie+PlaybackStatusAfx.h"

@interface MPMoviePlayerCtrlPanel : UIView

@property(nonatomic,readonly,assign) UIButton* playButton;
@property(nonatomic,readonly,assign) MPMovieProgressBar* progressBar;
@property(nonatomic,readonly,assign) UIButton* fullscreenButton;
@property(nonatomic,readonly,assign) UILabel* currentTimeLabel;
@property(nonatomic,readonly,assign) UILabel* durationTimeLabel;

- (void)showTimeState:(MPPlaybackTimeState)time;

@end
