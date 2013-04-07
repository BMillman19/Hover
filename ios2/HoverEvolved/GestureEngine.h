//
//  GestureEngine.h
//  OpenCV Tutorial
//
//  Created by Brandon Millman on 4/6/13.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    kSnap,
    kLeftSwipe,
    kRightSwipe,
    kUpSwipe,
    kDownSwipe
} GestureType;

@protocol GestureEngineDelegate <NSObject>

- (void)gestureRecognized:(GestureType)type;

@end

@interface GestureEngine : NSObject

- (void)enableSocketWithCode:(NSString *)code;

+ (GestureEngine *)sharedEngine;

- (void)reset;

@property (nonatomic, weak) id<GestureEngineDelegate> delegate;

@end
