//
//  MPMovie.m
//  MediaPlayer
//
//  Created by Shen Slavik on 3/5/13.
//
//

#import "MPMovie.h"
#import <objc/runtime.h>

@implementation MPMovie

//+ (void)leakMethods:(Class)c {
//            
//    unsigned int count = 0;
//	Method *array = class_copyMethodList( c, &count);
//	NSLog(@"got method count:%d", count);
//	for(int i = 0 ; i < count ; i++){
//		Method method = array[i];
//		SEL methodselector = method_getName(method);
//		const char* methodname = sel_getName(methodselector);
//		unsigned int argcount = method_getNumberOfArguments(method);
//		NSString *mn = [NSString stringWithCString:methodname encoding:NSASCIIStringEncoding];
//		NSLog(@"selector name:%@ (%d)", mn, argcount);
//	}
//}
//
//+ (void)initialize {
//
//    [super initialize];
//
//    [self leakMethods:[QTMovie class]];
//
//}

@end
