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
    kLeftLongSwipe,
    kRightLongSwipe,
    kUpSwipe,
    kDownSwipe
} GestureType;

@protocol GestureEngineDelegate <NSObject>

- (void)voiceRecognized:(NSString *)voice;
- (void)gestureRecognized:(GestureType)type;
- (void)socketOpened;
- (void)engineDidSwitchToVoiceMode;
- (void)engineDidSwitchToSwipeMode;

@end

@interface GestureEngine : NSObject

- (void)enableSocketWithCode:(NSString *)code;

+ (GestureEngine *)sharedEngine;

- (void)reset;

- (void)test;

- (UIView *)getVideoFeedViewWithRect:(CGRect)rect;

- (void)toggleVoiceMode;



@property (nonatomic, weak) id<GestureEngineDelegate> delegate;

@end
