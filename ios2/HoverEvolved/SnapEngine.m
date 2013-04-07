//
//  SnapEngine.m
//  OpenCV Tutorial
//
//  Created by Ashley Chou on 4/6/13.
//
//

#import "SnapEngine.h"

bool peakDetected = false;
double prevPeak = -200;

@implementation SnapEngine

-(void) start {
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    
  	NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithFloat: 44100.0],                 AVSampleRateKey,
                              [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
                              [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
                              [NSNumber numberWithInt: AVAudioQualityMax],         AVEncoderAudioQualityKey,
                              nil];
    
  	NSError *error;
    
  	recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    
  	if (recorder) {
  		[recorder prepareToRecord];
  		recorder.meteringEnabled = YES;
  		[recorder record];
        levelTimer = [NSTimer scheduledTimerWithTimeInterval: 0.03 target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES]; // Samples audio ~30 times a second
  	} else
  		NSLog(@"Error");
    
}

-(void) stop {
    [recorder stop];
}

- (void)levelTimerCallback:(NSTimer *)timer {
	[recorder updateMeters];
    double currPeak = [recorder peakPowerForChannel:0];
    
    // NSLog(@"%f", currPeak);
    // if (peakDetected && (abs(prevPeak) - abs(currPeak))) {

    if (peakDetected && (abs(prevPeak) - abs(currPeak) < -0.5)) {
        peakDetected = false;
    } else if ((currPeak > -0.000003) && !peakDetected) {
        peakDetected = true;
        [self.delegate snapDidOccur];
//        NSLog(@"SNAP DETECTED!");
    }

    prevPeak = currPeak;
}

@end
