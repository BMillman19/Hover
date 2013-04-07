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
        self.snapEngine = [[SnapEngine alloc] init];
        self.snapEngine.delegate = self;
        [self.snapEngine start];
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


#pragma mark - SnapEngineDelegate

-(void) snapDidOccur {
    if (self.networkSocket) {
        [self.networkSocket sendEvent:@"send_gesture" withPayload:@{@"payload" : @"snap"}];
        NSLog(@"Snap!");
    }
}

@end
