//
//  MPMovieView.h
//  MediaPlayer
//
//  Created by Shen Slavik on 3/6/13.
//
//

#import <UIKit/UIKit.h>

#import "UIInternalMovieView.h"
#import "MPMoviePlayerHUD.h"
#import "MPMoviePlayerCtrlPanel.h"

@interface MPMovieView : UIControl

@property(nonatomic,retain) MPMoviePlayerCtrlPanel* controlView;
@property(nonatomic,retain) UIView* customView;
@property(nonatomic,assign) BOOL autoHide;

@end
