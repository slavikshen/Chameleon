//
//  QTMovie+PlaybackStatusAfx.m
//  MediaPlayer
//
//  Created by Shen Slavik on 3/5/13.
//
//

#import "QTMovie+PlaybackStatusAfx.h"

@implementation QTMovie (PlaybackStatusAfx)

-(NSTimeInterval)maxSecondsLoaded {
    NSTimeInterval tMaxLoaded;
    QTGetTimeInterval([self maxTimeLoaded], &tMaxLoaded);
    return tMaxLoaded;
}

-(NSTimeInterval)durationSecond {
    NSTimeInterval tDuration;
    QTGetTimeInterval([self duration], &tDuration);
    return tDuration;
}

-(NSTimeInterval)playedSeconds {
    NSTimeInterval tCurrentTime;
    QTGetTimeInterval([self currentTime], &tCurrentTime);
    return tCurrentTime;
}

-(void)setPlayedSeconds:(NSTimeInterval)seconds {

    NSTimeInterval max = [self maxSecondsLoaded];
    if( seconds > max ) {
        // abort when try to set over the max
        return;
    } else if ( seconds < 0 ) {
        seconds = 0;
    }

    QTTime newTime = QTMakeTimeWithTimeInterval(seconds);
    [self setCurrentTime:newTime];

}

-(CGFloat)percentLoaded
{
    NSTimeInterval tMaxLoaded;
    NSTimeInterval tDuration;
    
    QTGetTimeInterval([self duration], &tDuration);
    QTGetTimeInterval([self maxTimeLoaded], &tMaxLoaded);

    if( tDuration > 0.0f ) {
        return (CGFloat) tMaxLoaded/tDuration;
    }
    
    return 0.0f;
}

-(CGFloat)percentPlayed {

    NSTimeInterval tCurrentTime;
    NSTimeInterval tDuration;
    
    QTGetTimeInterval([self duration], &tDuration);
    QTGetTimeInterval([self currentTime], &tCurrentTime);

    if( tDuration > 0.0f ) {
        return (CGFloat) tCurrentTime/tDuration;
    }
    
    return 0.0f;

}

-(void)gotoPercent:(CGFloat)percent {

    NSLog(@"goto percent: %0.2f", percent);

    NSTimeInterval duration = [self durationSecond];
    NSTimeInterval newTime = duration*percent;
    
    NSLog(@"goto time: %0.2f", newTime);
    
    [self setPlayedSeconds:newTime];
    
}


-(MPPlaybackTimeState)playbackTimeState {

    NSTimeInterval tMaxLoaded;
    NSTimeInterval tDuration;
    NSTimeInterval tCurrentTime;
    
    QTGetTimeInterval([self duration], &tDuration);
    QTGetTimeInterval([self maxTimeLoaded], &tMaxLoaded);
    QTGetTimeInterval([self currentTime], &tCurrentTime);
    
    MPPlaybackTimeState state;
    state.duration = tDuration;
    state.maxLoaded = tMaxLoaded;
    state.current = tCurrentTime;

    if( tDuration > 0.0f ) {
        state.percentLoaded = (CGFloat) tMaxLoaded/tDuration;
        state.percentPlayed = (CGFloat) tCurrentTime/tDuration;
    }
    
    return state;
    
}


@end
