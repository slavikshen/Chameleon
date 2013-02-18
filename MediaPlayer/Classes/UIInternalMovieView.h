//
//  UIInternalMovieView.h
//  MediaPlayer
//
//  Created by Michael Dales on 08/07/2011.
//  Copyright 2011 Digital Flapjack Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QTKit/QTKit.h>

#import "MPMoviePlayerController.h"
#import <UIKit/UIViewAdapter.h>

@interface UIInternalMovieView : UIView {
@private
//    CALayer *movieLayer;
    
    UIViewAdapter * _adaptorView;
    QTMovieView * _qtMovieView;
    QTMovie * _movie;
    MPMovieScalingMode _scalingMode;
}
@property (nonatomic, retain) QTMovie* movie;
@property (nonatomic, assign) MPMovieScalingMode scalingMode;

- (id)initWithMovie: (QTMovie*)movie;

@end
