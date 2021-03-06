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
#import "GPUImage.h"
#import "WinstonTopicEngine.h"

@interface GestureEngine () <WinstonTopicEngineDelegate, SnapEngineDelegate, NetworkSocketDelegate>

@property (nonatomic, strong) WinstonTopicEngine *topicEngine;
@property (nonatomic, strong) SnapEngine *snapEngine;
@property (nonatomic, strong) NetworkSocket *networkSocket;
@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, assign) BOOL motionDetected;
@property (nonatomic, strong) NSMutableArray *motionData;
@property (nonatomic, assign) BOOL voiceEnabled;
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
        self.voiceEnabled = NO;
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

- (void)test {
    [self socketDidOpen];
}


- (UIView *)getVideoFeedViewWithRect:(CGRect)rect {
    GPUImageView *filteredVideoView = [[GPUImageView alloc] initWithFrame:rect];
    [self.videoCamera addTarget:filteredVideoView];
    return filteredVideoView;
}

- (void)emitGesture:(GestureType)gesture {
    NSString *keyword;
    
    switch (gesture) {
        case kSnap:
            keyword = @"snap";
            break;
        case kLeftSwipe:
            keyword = @"left";
            break;
        case kRightSwipe:
            keyword = @"right";
            break;
        case kLeftLongSwipe:
            keyword = @"left_long";
            break;
        case kRightLongSwipe:
            keyword = @"right_long";
            break;
        case kUpSwipe:
            keyword = @"up";
            break;
        case kDownSwipe:
            keyword = @"down";
            break;
        default:
            keyword = @"";
            break;
    }
    
    [self.delegate gestureRecognized:gesture];
    
    if (self.networkSocket) {
        [self.networkSocket sendEvent:@"send_gesture" withPayload:@{@"payload" : keyword}];
    } else {
        //NSLog(@"Trying to send something but socket is closed");
    }

}

- (void)emitVoice:(NSString *)voice {
    if (self.networkSocket) {
        [self.networkSocket sendEvent:@"send_gesture" withPayload:@{@"payload" : voice}];
    }
}

- (void)cleanup {
    if (self.snapEngine) {
        [self.snapEngine stop];
        self.snapEngine = nil;
    }
    
    if (self.networkSocket) {
        self.networkSocket.delegate = nil;
        [self.networkSocket close];
        self.networkSocket = nil;
    }
    
    if (self.videoCamera) {
        [self.videoCamera stopCameraCapture];
        self.videoCamera = nil;
    }
    
    if (self.topicEngine) {
        self.topicEngine = nil;
    }
}


- (void) processMotionData {
    
    if (self.voiceEnabled)
        return;
        
    int window = 2;
    if (self.motionData.count < window * 3) {
        return;
    }
    double head1Val_x = [[self.motionData[0] objectForKey:@"x"] doubleValue];
    double head1Val_y = [[self.motionData[0] objectForKey:@"y"] doubleValue];
    double head2Val_x = [[self.motionData[1] objectForKey:@"x"] doubleValue];
    double head2Val_y = [[self.motionData[1] objectForKey:@"y"] doubleValue];
    double tail1Val_x = [[self.motionData[self.motionData.count-1] objectForKey:@"x"] doubleValue];
    double tail1Val_y = [[self.motionData[self.motionData.count-1] objectForKey:@"y"] doubleValue];
    double tail2Val_x = [[self.motionData[self.motionData.count-2] objectForKey:@"x"] doubleValue];
    double tail2Val_y = [[self.motionData[self.motionData.count-2] objectForKey:@"y"] doubleValue];
//    for (id obj in self.motionData)
//        NSLog(@"obj: %@", obj);
    double delta_y = 0;
    double delta_x = 0;
    
    double start_x, start_y, end_x, end_y = 0;
    for (int i = 0; i < window; i++) {
        start_x += [[self.motionData[i] objectForKey:@"x"] doubleValue];
        start_y += [[self.motionData[i] objectForKey:@"y"] doubleValue];
    }
    for (int i = self.motionData.count - (1 + window); i < self.motionData.count - 1; i++) {
        end_x += [[self.motionData[i] objectForKey:@"x"] doubleValue];
        end_y += [[self.motionData[i] objectForKey:@"y"] doubleValue];
    }
    delta_x = (end_x - start_x) / window;
    delta_y = (end_y - start_y) / window;
    //    for (int i = 1; i <= self.motionData.count-1; i++) {
    //        double prev_x = [[self.motionData[i-1] objectForKey:@"x"] doubleValue];
    //        double curr_x = [[self.motionData[i] objectForKey:@"x"] doubleValue];
    //
    //        double prev_y = [[self.motionData[i-1] objectForKey:@"y"] doubleValue];
    //        double curr_y = [[self.motionData[i] objectForKey:@"y"] doubleValue];
    //        double prev_int =[[self.motionData[i-1] objectForKey:@"intensity"] doubleValue];
    //        double curr_int =[[self.motionData[i] objectForKey:@"intensity"] doubleValue];
    //        delta_x = delta_x + (prev_x - curr_x);
    //        delta_y = delta_y + (prev_y - curr_y);
    //        NSLog(@"Prev X: %g", prev_x);
    //        NSLog(@"Curr X: %g", curr_x);
    //        NSLog(@"Prev Y: %g", prev_y);
    //        NSLog(@"Curr Y: %g", curr_y);
    //        NSLog(@"Abs X: %g", fabs(prev_x - curr_x));
    //        NSLog(@"Abs Y: %g", fabs(prev_y - curr_y));
    //        NSLog(@"Delta X: %g", delta_x);
    //        NSLog(@"Delta Y: %g", delta_y);
    
    //    }
    
    double totalChangeX = fabs(delta_x);
    double totalChangeY = fabs(delta_y);
    
    int longThreshold = 20;
    bool longSwipe = self.motionData.count > longThreshold;
    
    //NSLog(@"%f, %f", totalChangeX, totalChangeY);
    
    if ( totalChangeX > totalChangeY) {
        if (delta_x > 0) {
            if (longSwipe) {
                NSLog(@"LONG_RIGHT");

                [self emitGesture:kRightLongSwipe];
            } else {
                NSLog(@"RIGHT");

                [self emitGesture:kRightSwipe];
            }
        }
        else {
            if (longSwipe) {
                NSLog(@"LONG_LEFT");

                [self emitGesture:kLeftLongSwipe];
            } else {
                NSLog(@"LEFT");

                [self emitGesture:kLeftSwipe];
            }
        }
        //        // Up/Down swipe
        //        if ((head1Val_x + head2Val_x)/2 < ((tail1Val_x + tail2Val_x)/2)) {
        //            // Up swipe
        //            NSLog(@"UP");
        //        } else if ((head1Val_x + head2Val_x)/2 > ((tail1Val_x + tail2Val_x)/2)) {
        //            // Down swipe
        //            NSLog(@"DOWN");
        //        }
    } else if (totalChangeX < totalChangeY) {
        if (delta_y > 0) {
            NSLog(@"DOWN");
            [self emitGesture:kDownSwipe];
        }
        else {
            NSLog(@"UP");
            [self emitGesture:kUpSwipe];
        }
        //        // Left/Right swipe
        //        if ((head1Val_y + head2Val_y)/2 < ((tail1Val_y + tail2Val_y)/2)) {
        //            // Right swipe
        //            NSLog(@"RIGHT");
        //        } else if ((head1Val_y + head2Val_y)/2 > ((tail1Val_y + tail2Val_y)/2)) {
        //            // Left swipe
        //            NSLog(@"LEFT");
        //        }
    } else {
        NSLog(@"SAME VALUE");
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
    
    
    // start video cap
    
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];

    self.videoCamera.outputImageOrientation = UIInterfaceOrientationLandscapeLeft;
    self.motionDetected = false;
    self.motionData = [[NSMutableArray alloc] init];
    
    GPUImageMotionDetector *detector = [[GPUImageMotionDetector alloc] init];
    detector.motionDetectionBlock = ^(CGPoint motionCentroid, CGFloat motionIntensity, CMTime frameTime) {
        if (!isnan(motionCentroid.x) && !isnan(motionCentroid.y)) {
            //NSLog(@"%@, %g", NSStringFromCGPoint(motionCentroid), motionIntensity);
        }
        if (!self.motionDetected && !isnan(motionCentroid.x) && !isnan(motionCentroid.y)) {
            // Initialize the motionData array
            self.motionDetected = true;
            [self.motionData addObject:@{@"x": @(motionCentroid.x), @"y": @(motionCentroid.y), @"intensity": @(motionIntensity)}];
        } else if (self.motionDetected && isnan(motionCentroid.x) && isnan(motionCentroid.y)) {
            // Process the motionData array
            [self processMotionData];
            // Then reset the motionData array
            [self.motionData removeAllObjects];
            self.motionDetected = false;
        } else if (self.motionDetected && !isnan(motionCentroid.x) && !isnan(motionCentroid.y)){
            // Add values to motionData array
            [self.motionData addObject:@{@"x": @(motionCentroid.x), @"y": @(motionCentroid.y)}];
        }
    };
    [self.videoCamera addTarget:detector];
    [self.videoCamera startCameraCapture];
    
    
    [self.delegate socketOpened];

}

- (void)socketDidClose {
    [self cleanup];
    
}

- (void)socketDidFailWithError:(NSError *)error {
    [self cleanup];
}

- (void)toggleVoiceMode {
    if (!self.voiceEnabled) {
        [self.delegate engineDidSwitchToVoiceMode];
        self.voiceEnabled = YES;
        
        [self.snapEngine stop];
        
        self.topicEngine = [[WinstonTopicEngine alloc] init];
        self.topicEngine.delegate = self;
        [self.topicEngine start];
    } else {
        [self.delegate engineDidSwitchToSwipeMode];
        self.voiceEnabled = NO;
        
        [self.topicEngine stop];
        
        self.snapEngine = [[SnapEngine alloc] init];
        self.snapEngine.delegate = self;
        [self.snapEngine start];
    }
}

#pragma mark - SnapEngineDelegate

-(void) snapDidOccur {
    NSLog(@"Snap!");
    
    [self emitGesture:kSnap];

}

- (void)topicEngine:(WinstonTopicEngine *)engine didFindTopic:(NSString *)topic
{
    if (self.voiceEnabled) {
        if ([topic isEqualToString:@"back"]) {
            [self.delegate engineDidSwitchToSwipeMode];
            self.voiceEnabled = NO;
            
            [self.topicEngine stop];
            
            self.snapEngine = [[SnapEngine alloc] init];
            self.snapEngine.delegate = self;
            [self.snapEngine start];
            return;
            
        }
        [self emitVoice:topic];
        [self.delegate voiceRecognized:topic];
    }
}


@end
