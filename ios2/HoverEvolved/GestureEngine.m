//
//  GestureEngine.m
//  OpenCV Tutorial
//
//  Created by Brandon Millman on 4/6/13.
//
//

#import "GestureEngine.h"
#import "SnapEngine.h"
#import "NetworkSocket.h"

@interface GestureEngine () <SnapEngineDelegate, NetworkSocketDelegate>
@property (nonatomic, strong) SnapEngine *snapEngine;
@property (nonatomic, strong) NetworkSocket *networkSocket;
@end

@implementation GestureEngine

#pragma mark - Singleton

+ (GestureEngine *)sharedEngine {
    static GestureEngine *_sharedEngine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedEngine = [[GestureEngine alloc] init];
    });
    
    return _sharedEngine;
}

- (id)init
{
    self = [super init];
    if (self) {
    
    }
    return self;
}

- (void)enableSocketWithCode:(NSString *)code {
    NSArray *tokens = [code componentsSeparatedByString:@"!"];
    NSString *address = tokens[0];
    
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber * myNumber = [f numberFromString:tokens[1]];
    NSInteger port = myNumber.integerValue;
    
    NSString *channel = tokens[2];
    
    
    self.networkSocket = [NetworkSocket socketToAddress:address withPort:port withChannel:channel withDelegate:self];
}

- (void)reset {
    [self cleanup];
}

- (void)emitGesture:(GestureType)gesture {
    NSString *keyword;
    
    switch (gesture) {
        case kSnap:
            keyword = @"snap";
            break;
        case kLeftSwipe:
            keyword = @"left_swipe";
            break;
        case kRightSwipe:
            keyword = @"right_swipe";
            break;
        case kUpSwipe:
            keyword = @"up_swipe";
            break;
        case kDownSwipe:
            keyword = @"down_swipe";
            break;
        default:
            keyword = @"";
            break;
    }
    
    [self.delegate gestureRecognized:gesture];
    
    if (self.networkSocket) {
        [self.networkSocket sendEvent:@"send_gesture" withPayload:@{@"payload" : keyword}];
    } else {
        NSLog(@"Trying to send something but socket is closed");
    }

}

- (void)cleanup {
    if (self.snapEngine) {
        [self.snapEngine stop];
        self.snapEngine = nil;
    }
    
    if (self.networkSocket) {
        self.networkSocket = nil;
    }
}

#pragma mark - NetworkSocketDelegate

- (void)eventOccurred:(NSString *)event withPayload:(NSDictionary *)payload {
    
}

- (void)socketDidOpen {
    
    // once socket opens start the snap engine
    self.snapEngine = [[SnapEngine alloc] init];
    self.snapEngine.delegate = self;
    [self.snapEngine start];
}

- (void)socketDidClose {
    [self cleanup];
    
}

- (void)socketDidFailWithError:(NSError *)error {
    [self cleanup];
}

#pragma mark - SnapEngineDelegate

-(void) snapDidOccur {
    if (self.networkSocket) {
        [self emitGesture:kSnap];
        NSLog(@"Snap!");
    }
}

@end
