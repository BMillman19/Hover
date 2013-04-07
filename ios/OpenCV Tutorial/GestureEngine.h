//
//  GestureEngine.h
//  OpenCV Tutorial
//
//  Created by Brandon Millman on 4/6/13.
//
//

#import <Foundation/Foundation.h>

@interface GestureEngine : NSObject

- (void)enableSocketWithCode:(NSString *)code;

+ (GestureEngine *)sharedEngine;

@end
