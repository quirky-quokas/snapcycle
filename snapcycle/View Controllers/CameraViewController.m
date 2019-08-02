//
//  CameraViewController.m
//  snapcycle
//
//  Created by emilyabest on 7/16/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import "CameraViewController.h"
#import "Parse/Parse.h"
#import "Trash.h"
#import "AVFoundation/AVFoundation.h"
#import "DetailsViewController.h"
#import "RegisterViewController.h"
#import "TabBarController.h"
#import "FocusFrame.h"
#import "CameraView.h"

@interface CameraViewController () <UINavigationControllerDelegate, AVCapturePhotoCaptureDelegate, DetailsViewControllerDelegate, UIGestureRecognizerDelegate, CameraViewDelegate>
@property (strong, nonatomic) UIImage *capturedImage;
@property (weak, nonatomic) IBOutlet CameraView *cameraView;
@property (weak, nonatomic) IBOutlet UIView *enableCamView;
@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) AVCapturePhotoOutput *stillImageOutput;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (strong, nonatomic) AVCaptureDevice *backCamera;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;

@end

@implementation CameraViewController

/**
 Start camera when CameraVC first loads on Camera tab.
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self initializeCamera]) {
        // instantiate the camera
        [self.enableCamView setHidden:true];
        self.cameraView.delegate = self;
        [self.cameraView instantiateGR];
    } else {
        // display enable camera view, user has not allowed camera access
        [self.cameraButton setHidden:true];
        [self.cameraView setHidden:true];
        
        // NOTE: not checking AVAuthorizationStatus, will do later if time
    }


    // set the navigation bar font
    [TabBarController setSnapcycleLogoTitleForNavigationController:self.navigationController];
}

/**
 Start camera when user navigates to CameraVC on Camera tab.
 */
- (void)viewDidAppear:(BOOL)animated {
    [self.session startRunning];
}

/**
 Initializes a custom camera.
 */
- (BOOL)initializeCamera {
    // setup a new session
    self.session = [AVCaptureSession new];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];

    // select input device
    self.backCamera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!self.backCamera) {
        [(TabBarController*)self.tabBarController showOKAlertWithTitle:@"Error" message:@"Unable to access back camera"];
        NSLog(@"Unable to access back camera");
        return false;
    }
    
    // prepare the input and output
    NSError *error;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:self.backCamera error:&error];
    if (error) {
        [(TabBarController*)self.tabBarController showOKAlertWithTitle:@"Error" message:error.localizedDescription];
        NSLog(@"Error: Unable to initialize back camera: %@", error.localizedDescription);
        return false;
    } else {
        self.stillImageOutput = [AVCapturePhotoOutput new];
        
        // attach the input and output
        if ([self.session canAddInput:input] && [self.session canAddOutput:self.stillImageOutput]) {
            [self.session addInput:input];
            [self.session addOutput:self.stillImageOutput];
            [self setupLivePreview];
        }
    }
    return true;
}

/**
 Configures the live preview to display the camera's view on the screen.
 */
- (void)setupLivePreview {
    self.videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    
    if (self.videoPreviewLayer) {
        self.videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.videoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        [self.cameraView.layer addSublayer:self.videoPreviewLayer];
        
        // start the session on the background thread (startRunning will block the UI if it's running on the main thread)
        dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_async(globalQueue, ^{
            [self.session startRunning];
            
            // set preview layer to fit previewView
            dispatch_async(dispatch_get_main_queue(), ^{
                self.videoPreviewLayer.frame = self.cameraView.bounds;
            });
        });
    }
}

/**
 CameraViewDelegate method.
 Enables zoom in/out for the live preview.
 */
- (void)handlePinchZoom:(UIPinchGestureRecognizer *)pinchGR {
    const CGFloat pinchVelocityDividerFactor = 10.0f;
    
    if (pinchGR.state == UIGestureRecognizerStateChanged) {
        NSError *error = nil;
        if ([self.backCamera lockForConfiguration:&error]) {
            CGFloat desiredZoomFactor = self.backCamera.videoZoomFactor + atan2f(pinchGR.velocity, pinchVelocityDividerFactor);
            // check if desiredZoomFactor fits required range from 1.0 to activeFormat.videoMaxZoomFactor
            self.backCamera.videoZoomFactor = MAX(1.0, MIN(desiredZoomFactor, self.backCamera.activeFormat.videoMaxZoomFactor));
            [self.backCamera unlockForConfiguration];
        } else {
            NSLog(@"Error with zoom: %@", error);
        }
    }
}

/**
 CameraViewDelegate method.
 Enables tap to focus for the live preview.
 */
- (void)handleTapFocus:(UITapGestureRecognizer *)tapGR{
    // get the tapped point
    CGPoint tapPoint = [tapGR locationInView:self.cameraView];
    
    if([self.backCamera isFocusPointOfInterestSupported] && [self.backCamera isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        double screenWidth = screenRect.size.width;
        double screenHeight = screenRect.size.height;
        double focusX = tapPoint.x/screenWidth;
        double focusY = tapPoint.y/screenHeight;
        
        // set focus and exposure modes
        NSError *error = nil;
        if ([self.backCamera lockForConfiguration:&error]) {
            [self.backCamera setFocusPointOfInterest:CGPointMake(focusX, focusY)];
            [self.backCamera setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            
            if([self.backCamera isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
                [self.backCamera setExposureMode:AVCaptureExposureModeAutoExpose];
            }
            [self.backCamera unlockForConfiguration];
        }
        
        // draw frame around the tapped focus point
        [self.cameraView drawFocusFrame:tapPoint];
    }
}

/**
 The user tapped the "Snap photo" button.
 */
- (IBAction)didTakePhoto:(UIButton *)sender {
    AVCapturePhotoSettings *settings = [AVCapturePhotoSettings photoSettingsWithFormat:@{AVVideoCodecKey: AVVideoCodecTypeJPEG}];
    
    [self.stillImageOutput capturePhotoWithSettings:settings delegate:self];
}

/**
 Processes the captured photo.
 */
- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(NSError *)error {
    NSData *imageData = photo.fileDataRepresentation;
    if (imageData) {
        UIImage *image = [UIImage imageWithData:imageData];
        self.capturedImage = image;
        
        // segue to detailsVC
        [self performSegueWithIdentifier:@"segueToDetailsVC" sender:self];
    }
}

/**
 The user tapped the "Enable Camera" button. Open Settings.
 */
- (IBAction)didEnableCamera:(UIButton *)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{}                             completionHandler:^(BOOL success) {
        if (!success) {
            [(TabBarController*)self.tabBarController showOKAlertWithTitle:@"Error" message:@"Unable to open settings"];
        }
    }];
}

#pragma mark - Navigation

/**
 Prepare for segue to DetailsVC with data to send.
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    DetailsViewController *detailsViewController = [segue destinationViewController];
    
    PFQuery *categoryQuery = [PFQuery queryWithClassName:@"Category"];
    detailsViewController.category = [categoryQuery getObjectWithId:@"u42Xiik8ok"];
    detailsViewController.image = self.capturedImage;
    detailsViewController.delegate = self;
}

/**
 DetailsViewControllerDelegate method. Posts an alert to show trash was posted successfully.
 */
- (void)postedTrashWithMessage:(NSString *)message withTitle:(NSString *)title {
    [(TabBarController*)self.tabBarController showOKAlertWithTitle:title message:message];
}

#pragma mark - User actions

/**
 Logs out user
 */
- (IBAction)onLogoutTap:(id)sender {
    // Logout user
    [((TabBarController*)self.tabBarController) logoutUserWithAlertIfError];
}

@end
