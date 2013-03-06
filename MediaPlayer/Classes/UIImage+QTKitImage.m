//
//  UIImage+QTKitImage.m
//  MediaPlayer
//
//  Created by Shen Slavik on 3/5/13.
//
//

#import "UIImage+QTKitImage.h"

@implementation UIImage (QTKitImage)

+ (UIImage *)QTKitImageWithName:(NSString *)name
{

    static NSMutableDictionary* CACHE = nil;
    if( nil == CACHE ) {
        CACHE = [[NSMutableDictionary alloc] initWithCapacity:8];
    }

    UIImage *image = [CACHE objectForKey:name];

    if (!image) {    
        NSString* root = [[NSBundle mainBundle] bundlePath];
        NSString* path = [NSString stringWithFormat:@"%@/Contents/Frameworks/MediaPlayer.framework/Resources/%@", root, name];
        NSData* data = [NSData dataWithContentsOfFile:path];
        image = [UIImage imageWithData:data];
        
        if(image) {
            [CACHE setObject:image forKey:name];
        }
    }

    return image;
}


@end
