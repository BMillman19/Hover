//
//  ViewController.m
//  HoverEvolved
//
//  Created by Brandon Millman on 4/6/13.
//  Copyright (c) 2013 Equinox. All rights reserved.
//

#import "ViewController.h"
#import "GPUImage.h"
#import "ZBarReaderViewController.h"
#import "GestureEngine.h"
#import "UIColor+CreateMethods.h"
#import "MLPSpotlight.h"
#import "FontasticIcons.h"

@interface ViewController () <ZBarReaderDelegate, GestureEngineDelegate>
@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, strong) GPUImageView *filteredVideoView;
@property (nonatomic, strong) IBOutlet UIView *tipView;
@property (nonatomic, strong) IBOutlet UIView *backgroundView;
@property (nonatomic, strong) IBOutlet FIIconView *startIcon;
@property (nonatomic, strong) IBOutlet FIIconView *scanIcon;
@property (nonatomic, strong) IBOutlet FIIconView *micIcon;
@property (nonatomic, strong) IBOutlet FIIconView *upIcon;
@property (nonatomic, strong) IBOutlet FIIconView *downIcon;
@property (nonatomic, strong) IBOutlet FIIconView *leftIcon;
@property (nonatomic, strong) IBOutlet FIIconView *rightIcon;
@property (nonatomic, strong) IBOutlet FIIconView *resetIcon;

@property (nonatomic, copy) NSString *code;
@property (nonatomic, assign) BOOL voiceMode;
@end

@implementation ViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.voiceMode = NO;
    
    self.backgroundView.backgroundColor = [UIColor colorWithHex:@"#E74C3C" alpha:1.0f];
    [MLPSpotlight addSpotlightInView:self.backgroundView atPoint:self.backgroundView.center];
    self.tipView.alpha = 0.0f;    
    
    self.startIcon.backgroundColor = [UIColor clearColor];
    self.startIcon.padding = 5.0f;
    self.startIcon.iconColor = [UIColor whiteColor];
    self.startIcon.icon = [FIEntypoIcon playIcon];
    self.startIcon.alpha = 0.0f;
    UITapGestureRecognizer *startRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startButtonPressed:)];
    [self.startIcon addGestureRecognizer:startRecognizer];
    
    self.scanIcon.backgroundColor = [UIColor clearColor];
    self.scanIcon.padding = 5.0f;
    self.scanIcon.iconColor = [UIColor whiteColor];
    self.scanIcon.icon = [FIEntypoIcon cameraIcon];
    UITapGestureRecognizer *scanRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scanButtonPressed:)];
    [self.scanIcon addGestureRecognizer:scanRecognizer];
    
    self.resetIcon.backgroundColor = [UIColor clearColor];
    self.resetIcon.padding = 5.0f;
    self.resetIcon.iconColor = [UIColor whiteColor];
    self.resetIcon.icon = [FIEntypoIcon crossIcon];
    self.resetIcon.alpha = 0.0f;
    UITapGestureRecognizer *resetRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetButtonPressed:)];
    [self.resetIcon addGestureRecognizer:resetRecognizer];
    
    self.micIcon.backgroundColor = [UIColor clearColor];
    self.micIcon.padding = 5.0f;
    self.micIcon.iconColor = [UIColor whiteColor];
    self.micIcon.icon = [FIEntypoIcon micIcon];
    self.micIcon.alpha = 0.0f;
    
    self.upIcon.backgroundColor = [UIColor clearColor];
    self.upIcon.padding = 5.0f;
    self.upIcon.iconColor = [UIColor whiteColor];
    self.upIcon.icon = [FIEntypoIcon upIcon];
    self.upIcon.alpha = 0.0f;
    
    self.downIcon.backgroundColor = [UIColor clearColor];
    self.downIcon.padding = 5.0f;
    self.downIcon.iconColor = [UIColor whiteColor];
    self.downIcon.icon = [FIEntypoIcon downIcon];
    self.downIcon.alpha = 0.0f;
    
    self.leftIcon.backgroundColor = [UIColor clearColor];
    self.leftIcon.padding = 5.0f;
    self.leftIcon.iconColor = [UIColor whiteColor];
    self.leftIcon.icon = [FIEntypoIcon leftIcon];
    self.leftIcon.alpha = 0.0f;
    
    self.rightIcon.backgroundColor = [UIColor clearColor];
    self.rightIcon.padding = 5.0f;
    self.rightIcon.iconColor = [UIColor whiteColor];
    self.rightIcon.icon = [FIEntypoIcon rightIcon];
    self.rightIcon.alpha = 0.0f;
    
    ///
    
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
    
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
    
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;

    CGRect mainScreenFrame = [[UIScreen mainScreen] applicationFrame];
	self.filteredVideoView = [[GPUImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, mainScreenFrame.size.width, mainScreenFrame.size.height)];
    //[self.view addSubview:self.filteredVideoView];
    
    
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return (interfaceOrientation == UIInterfaceOrientationMaskLandscapeLeft);
}

#pragma mark - Actions

- (IBAction)scanButtonPressed:(id)sender {
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    
    ZBarImageScanner *scanner = reader.scanner;
    // TODO: (optional) additional reader configuration here
    
    // EXAMPLE: disable rarely used I2/5 to improve performance
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    
    
    
    CGFloat cameraTransformX = 1.0;
    CGFloat cameraTransformY = 1.12412;
    
    reader.cameraViewTransform = CGAffineTransformScale(reader.cameraViewTransform, cameraTransformX, cameraTransformY);
    
    // present and release the controller
    [self presentViewController:reader animated:NO completion:nil];    
}

-(IBAction)startButtonPressed:(id)sender {
    //[[GestureEngine sharedEngine] enableSocketWithCode:self.code];
    
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.tipView.alpha = 0.0f;
                         self.startIcon.alpha = 0.0f;
                         self.backgroundView.backgroundColor = [UIColor colorWithHex:@"#3498DB" alpha:1.0f];
                         
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.5f
                                               delay:0.0f
                                             options:UIViewAnimationOptionCurveLinear
                                          animations:^{
                                              self.resetIcon.alpha = 1.0f;
                                          }
                                          completion:^(BOOL finished){
                                          }
                          ];
                     }
     ];
}

-(IBAction)resetButtonPressed:(id)sender {
    //[[GestureEngine sharedEngine] reset];
    
    self.voiceMode = NO;
    
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.resetIcon.alpha = 0.0f;
                         self.backgroundView.backgroundColor = [UIColor colorWithHex:@"#E74C3C" alpha:1.0f];
                         
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.5f
                                               delay:0.0f
                                             options:UIViewAnimationOptionCurveLinear
                                          animations:^{
                                              self.scanIcon.alpha = 1.0f;
                                          }
                                          completion:^(BOOL finished){
                                          }
                          ];
                     }
     ];
}

#pragma mark - ZBarReaderDelegate

- (void)imagePickerController:(UIImagePickerController*)reader didFinishPickingMediaWithInfo:(NSDictionary*)info
{
    
    ZBarSymbolSet *symbols = [info objectForKey: ZBarReaderControllerResults];
    for (ZBarSymbol *symbol in symbols) {
        //NSLog(symbol.data);
        self.code = symbol.data;
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        [UIView animateWithDuration:0.5f animations:^{
            self.tipView.alpha = 1.0f;
        }];
        
        [UIView animateWithDuration:0.5f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             self.scanIcon.alpha = 0.0f;
                             self.backgroundView.backgroundColor = [UIColor colorWithHex:@"#9B59B6" alpha:1.0f];

                         }
                         completion:^(BOOL finished){
                             [UIView animateWithDuration:0.5f
                                                   delay:0.0f
                                                 options:UIViewAnimationOptionCurveLinear
                                              animations:^{
                                                  self.startIcon.alpha = 1.0f;
                                                  self.tipView.alpha = 1.0f;
                                              }
                                              completion:^(BOOL finished){
                                              }
                              ];
                         }
         ];
    }];
}

#pragma mark - GestureEngineDelegate

- (void)gestureRecognized:(GestureType)type {
    
    switch (type) {
        case kSnap:
            if (self.voiceMode) {
                self.voiceMode = NO;
                [UIView animateWithDuration:0.5f
                                      delay:0.0f
                                    options:UIViewAnimationOptionCurveLinear
                                 animations:^{
                                     self.micIcon.alpha = 0.0f;
                                     self.backgroundView.backgroundColor = [UIColor colorWithHex:@"#3498DB" alpha:1.0f];
                                     
                                 }
                                 completion:^(BOOL finished){}
                 ];

            } else {
                self.voiceMode = YES;
                [UIView animateWithDuration:0.5f
                                      delay:0.0f
                                    options:UIViewAnimationOptionCurveLinear
                                 animations:^{
                                     self.micIcon.alpha = 1.0f;
                                     self.backgroundView.backgroundColor = [UIColor colorWithHex:@"#1ABC9C" alpha:1.0f];
                                     
                                 }
                                 completion:^(BOOL finished){}
                ];
            }
            break;
            
        default:
            break;
    }
    
}

@end
