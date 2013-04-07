//
//  DetailViewController.m
//  OpenCV Tutorial
//
//  Created by BloodAxe on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"
#import "VideoViewController.h"
#import "ImageViewController.h"
#import "NSString+StdString.h"
#import "ZBarReaderViewController.h"
#import "GestureEngine.h"

@interface DetailViewController () <ZBarReaderDelegate>

@property (strong, nonatomic) UIPopoverController *masterPopoverController;

@property (weak, nonatomic) ImageViewController * activeImageController;
@property (weak, nonatomic) VideoViewController * activeVideoController;

- (void)configureView;
@end

@implementation DetailViewController
@synthesize sampleIconView;
@synthesize sampleDescriptionTextView;
@synthesize runOnImageButton;
@synthesize runOnVideoButton;
@synthesize masterPopoverController = _masterPopoverController;

#pragma mark - Managing the detail item

- (void)setDetailItem:(SampleFacade*) sample
{
    if (currentSample != sample)
    {
        currentSample = sample;
        [self configureView];
    }
    
    if (self.masterPopoverController != nil)
    {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.
    
    if (currentSample)
    {
        self.sampleDescriptionTextView.text = [currentSample description];
        self.title = [currentSample title];
        self.sampleIconView.image = [currentSample largeIcon];
        
        if (self.activeImageController)
            [self.activeImageController setSample:currentSample];
        
        if (self.activeVideoController)
            [self.activeVideoController setSample:currentSample];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *connectButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(connectButtonPressed:)];
    self.navigationItem.rightBarButtonItem = connectButton;
    
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)connectButtonPressed:(id)sender {
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

#pragma mark - ZBarReaderDelegate

- (void)imagePickerController:(UIImagePickerController*)reader didFinishPickingMediaWithInfo:(NSDictionary*)info
{
    
    ZBarSymbolSet *symbols = [info objectForKey: ZBarReaderControllerResults];
    for (ZBarSymbol *symbol in symbols) {
        //NSLog(symbol.data);
        NSString* code = symbol.data;
        
        [[GestureEngine sharedEngine] enableSocketWithCode:code];
    }
    
    [self dismissViewControllerAnimated:YES completion:^{}];
    
    
    
}

- (void)viewDidUnload
{
    [self setSampleIconView:nil];
    [self setSampleDescriptionTextView:nil];
    [self setRunOnImageButton:nil];
    [self setRunOnVideoButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark - Run Sample

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"processVideo"])
    {
        VideoViewController * sampleController = [segue destinationViewController];
        [sampleController setSample:currentSample];
        self.activeVideoController = sampleController;
    }
    else if ([[segue identifier] isEqualToString:@"processImage"])
    {
        ImageViewController * sampleController = [segue destinationViewController];
        [sampleController setSample:currentSample];
        self.activeImageController = sampleController;
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"Detail view is going to appear");
    
    self.activeVideoController = nil;
    self.activeImageController = nil;
}



@end
