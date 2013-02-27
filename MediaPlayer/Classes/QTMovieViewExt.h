//
//  QTMovieViewExt.h
//  MediaPlayer
//
//  Created by Jerry Tian on 2/26/13.
//
//

#import <QTKit/QTKit.h>

@interface QTMovieViewExt : QTMovieView {
@private
    BOOL _flipped;
}

@property (nonatomic, getter = isFlipped) BOOL flipped;

@end
