//
//  SnapEngine.h
//  OpenCV Tutorial
//
//  Created by Ashley Chou on 4/6/13.
//
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

@protocol SnapEngineDelegate <NSObject>

-(void) snapDidOccur;

@end

@interface SnapEngine : NSObject {
    AVAudioRecorder *recorder; // Set up AVAudioRecorder instance variable
    NSTimer *levelTimer;
}

-(void) start;
-(void) stop;


@property (nonatomic, weak) id <SnapEngineDelegate> delegate;

@end
