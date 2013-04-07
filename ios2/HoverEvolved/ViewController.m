//
//  ViewController.m
//  HoverEvolved
//
//  Created by Brandon Millman on 4/6/13.
//  Copyright (c) 2013 Equinox. All rights reserved.
//

#import "ViewController.h"
#import "GPUImage.h"

@interface ViewController ()
@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, strong) GPUImageView *filteredVideoView;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
    
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
    
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;

    CGRect mainScreenFrame = [[UIScreen mainScreen] applicationFrame];
	self.filteredVideoView = [[GPUImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, mainScreenFrame.size.width, mainScreenFrame.size.height)];
    [self.view addSubview:self.filteredVideoView];
    
    
    GPUImageMotionDetector *detector = [[GPUImageMotionDetector alloc] init];
    detector.motionDetectionBlock = ^(CGPoint motionCentroid, CGFloat motionIntensity, CMTime frameTime) {
        if (!isnan(motionCentroid.x) && !isnan(motionCentroid.y)) {
            NSLog(@"%@", NSStringFromCGPoint(motionCentroid));
        }
    };
    
    [self.videoCamera addTarget:detector];
    
    [self.videoCamera addTarget:self.filteredVideoView];
    [self.videoCamera startCameraCapture];


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
