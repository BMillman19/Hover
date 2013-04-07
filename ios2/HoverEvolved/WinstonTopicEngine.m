//
//  WinstonTopicEngine.m
//  Winston
//
//  Created by Brandon Millman on 12/12/12.
//  Copyright (c) 2012 Equinox. All rights reserved.
//

#import "WinstonTopicEngine.h"
#import <SpeechKit/SpeechKit.h>

const unsigned char SpeechKitApplicationKey[] = {0x4c, 0x91, 0xad, 0x24, 0x5c, 0xb5, 0x71, 0x0c, 0x6b, 0x0e, 0xca, 0x84, 0xb0, 0x26, 0xad, 0xdc, 0x18, 0x63, 0x0c, 0x94, 0xeb, 0xc7, 0x40, 0xd9, 0x00, 0x7e, 0x34, 0x41, 0x32, 0xb0, 0xae, 0x7e, 0x41, 0x5c, 0xa2, 0x9e, 0x11, 0x14, 0xaa, 0x7c, 0x22, 0x74, 0x01, 0xd2, 0x9a, 0xae, 0xae, 0xb2, 0x11, 0xba, 0x46, 0xfd, 0x81, 0x86, 0xd6, 0x81, 0x05, 0x0b, 0xc2, 0x37, 0xbb, 0x71, 0xb5, 0xfc};

@interface WinstonTopicEngine () <SpeechKitDelegate, SKRecognizerDelegate>

@property (nonatomic, strong) SKRecognizer *recognizer;
@property (nonatomic, strong) NSTimer *updateTimer;
@property (nonatomic, assign) BOOL isUpdating;
@property (nonatomic, assign) BOOL needsToSendTopicToDelegate;
@property (nonatomic, strong) NSMutableDictionary *frequencyMap;

@end

@implementation WinstonTopicEngine

@synthesize updateInterval = _updateInterval;
@synthesize recognizer = _recognizer;
@synthesize updateTimer = _updateTimer;
@synthesize isUpdating = _isUpdating;
@synthesize needsToSendTopicToDelegate = _needsToSendTopicToDelegate;
@synthesize frequencyMap = _frequencyMap;


#pragma mark - Init and Dealloc

- (void)dealloc
{
    [_recognizer cancel];
    //[_recognizer release];
    [_updateTimer invalidate];
    //[_updateTimer release];
    //[_frequencyMap release];
    //[super dealloc];
}

- (id)init
{
    if (self = [super init])
    {
        // set up speech kit with credentials
        [SpeechKit setupWithID:@"NMDPTRIAL_bmillman1920121211231938"
                          host:@"sandbox.nmdp.nuancemobility.net"
                          port:443
                        useSSL:NO
                      delegate:self];
        
        // default updateInterval
        _updateInterval = 5.0;
        
        // starts off not updating
        _isUpdating = NO;
        _needsToSendTopicToDelegate = YES;
        
        // set up freqeuncy map
        self.frequencyMap = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - Instance Methods

- (void)start
{
    self.recognizer = [[SKRecognizer alloc] initWithType:SKDictationRecognizerType
                                           detection:SKShortEndOfSpeechDetection
                                            language:@"en_US"
                                            delegate:self];
    
    //self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:self.updateInterval target:self selector:@selector(handleUpdateTimer:) userInfo:nil repeats:YES];
    
}

- (void)stop
{
    [self.recognizer cancel];
    self.recognizer = nil;
    
}

#pragma mark - Private Methods

- (void)handleUpdateTimer:(NSTimer *)timer
{
    NSLog(@"Winston: Will update soon!");
//    self.needsToSendTopicToDelegate = YES;
//    [self.recognizer stopRecording];
}

- (void)updateFrequencyMapWithNewResults:(NSArray *)results
{
    NSUInteger previousFrequency;
    NSString *cleanString;
    for (NSString *string in results)
    {
        cleanString = [self cleanString:string];
        if (cleanString)
        {
            previousFrequency = 0;
            if ([self.frequencyMap objectForKey:cleanString])
            {
                previousFrequency = [[self.frequencyMap objectForKey:cleanString] intValue];
            }
            [self.frequencyMap setObject:[NSNumber numberWithInt:previousFrequency + 1] forKey:cleanString];
        }
    }
}

- (NSString *)cleanString:(NSString *)string
{
    return [[string copy] lowercaseString];
}

- (void)sendTopicToDelegate
{
    NSUInteger maxFreqeuncy = 0;
    NSString *currentTopic;
    
    for (NSString *string in self.frequencyMap) {
        NSUInteger currentFrequency = [[self.frequencyMap objectForKey:string] intValue];
        if (currentFrequency > maxFreqeuncy) {
            maxFreqeuncy = currentFrequency;
            currentTopic = string;
        }
    }
    
    if (currentTopic) {
        [self.delegate topicEngine:self didFindTopic:currentTopic];
    }
    
    [self.frequencyMap removeAllObjects];
}


#pragma mark - SKRecognizerDelegate

//@optional
/*!
 @abstract Sent when the recognizer starts recording audio.
 
 @param recognizer The recognizer sending the message.
 */
- (void)recognizerDidBeginRecording:(SKRecognizer *)recognizer
{
    NSLog(@"Winston: Recording started!");
}

/*!
 @abstract Sent when the recognizer stops recording audio.
 
 @param recognizer The recognizer sending the message.
 */
- (void)recognizerDidFinishRecording:(SKRecognizer *)recognizer
{
    NSLog(@"Winston: Recording finished!");
}

//@required
/*!
 @abstract Sent when the recognition process completes successfully.
 
 @param recognizer The recognizer sending the message.
 @param results The SKRecognition object containing the recognition results.
 
 @discussion This method is only called when the recognition process completes
 successfully.  The results object contains an array of possible results, with
 the best result at index 0 or an empty array if no error occurred but no
 speech was detected.
 */
- (void)recognizer:(SKRecognizer *)recognizer didFinishWithResults:(SKRecognition *)results
{
    NSLog(@"Winston: Recording results!");
    
    NSArray* resultArray = [[results firstResult] componentsSeparatedByString: @" "];

    for (NSString *string in resultArray)
    {
        NSLog(@"Result: %@", string);
    }
    
    [self updateFrequencyMapWithNewResults:resultArray];
    
    if (self.needsToSendTopicToDelegate)
    {
        [self sendTopicToDelegate];
        self.needsToSendTopicToDelegate = YES;
    }
    
//    self.recognizer = nil;
//    self.recognizer = [[SKRecognizer alloc] initWithType:SKDictationRecognizerType
//                                               detection:SKLongEndOfSpeechDetection
//                                                language:@"en_US"
//                                                delegate:self];
    //if (self.recognizer) [self.recognizer release];
    self.recognizer = nil;
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval: 1
                                                      target:self
                                                    selector:@selector(handleTimer:)
                                                    userInfo:nil
                                                     repeats:NO];
}

- (void)handleTimer:(NSTimer *)timer {
    [self start];
    [timer invalidate];
    timer = nil;
}

/*!
 @abstract Sent when the recognition process completes with an error.
 
 @param recognizer The recognizer sending the message.
 @param error The recognition error.  Possible numeric values for the
 SKSpeechErrorDomain are listed in SpeechKitError.h and a text description is
 available via the localizedDescription method.
 @param suggestion This is a suggestion to the user about how he or she can
 improve recognition performance and is based on the audio received.  Examples
 include moving to a less noisy location if the environment is extremely noisy, or
 waiting a bit longer to start speaking if the beeginning of the recording seems
 truncated.  Results are often still present and may still be of useful quality.
 
 @discussion This method is called when the recognition process results in an
 error due to any number of circumstances.  The audio system may fail to
 initialize, the server connection may be disrupted or a parameter specified
 during initialization, such as language or authentication information was invalid.
 */
- (void)recognizer:(SKRecognizer *)recognizer didFinishWithError:(NSError *)error suggestion:(NSString *)suggestion
{
    NSLog(@"Winston: Recording error!");
    NSLog(@"Error: %@", error);
    NSLog(@"Suggestion: %@", suggestion);

    //[self.delegate topicEngine:self didFailWithError:error suggestion:suggestion];
    [self stop];
}

#pragma mark - SpeechKitDelegate

- (void)destroyed
{
    // on speech kit session destroyed
    NSLog(@"Winston: SpeechKit destrotyed!");

}

#pragma mark - Custom Accessors

- (void)setUpdateInterval:(NSTimeInterval)updateInterval
{
    _updateInterval = updateInterval;
    
    if (self.isUpdating)
    {
        [self.updateTimer invalidate];
        self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:_updateInterval target:self selector:@selector(update:) userInfo:nil repeats:YES];
    }
}


@end
