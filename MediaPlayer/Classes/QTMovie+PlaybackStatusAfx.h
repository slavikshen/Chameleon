//
//  QTMovie+PlaybackStatusAfx.h
//  MediaPlayer
//
//  Created by Shen Slavik on 3/5/13.
//
//

#import <QTKit/QTKit.h>

struct MPPlaybackTimeState {
  CGFloat percentLoaded;
  CGFloat percentPlayed;
  NSTimeInterval duration;
  NSTimeInterval maxLoaded;
  NSTimeInterval current;
};

typedef struct MPPlaybackTimeState MPPlaybackTimeState;


@interface QTMovie(IdlingAdditions)

-(QTTime)maxTimeLoaded;
-(BOOL)isPlaying;

@end

@interface QTMovie (PlaybackStatusAfx)

-(NSTimeInterval)maxSecondsLoaded;
-(NSTimeInterval)durationSecond;

-(NSTimeInterval)playedSeconds;
-(void)setPlayedSeconds:(NSTimeInterval)seconds;

-(void)gotoPercent:(CGFloat)percent;
-(CGFloat)percentLoaded;
-(CGFloat)percentPlayed;

-(MPPlaybackTimeState)playbackTimeState;

@end
