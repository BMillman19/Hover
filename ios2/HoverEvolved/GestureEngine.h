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
- (void)socketOpened;

@end

@interface GestureEngine : NSObject

- (void)enableSocketWithCode:(NSString *)code;

+ (GestureEngine *)sharedEngine;

- (void)reset;

- (void)test;

- (UIView *)getVideoFeedViewWithRect:(CGRect)rect;

@property (nonatomic, weak) id<GestureEngineDelegate> delegate;

@end
