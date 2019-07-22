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
#import "MobileNetV2.h"
#import <Vision/Vision.h>
#import "Category.h"


@interface CameraViewController () <UINavigationControllerDelegate, AVCapturePhotoCaptureDelegate, DetailsViewControllerDelegate, UIGestureRecognizerDelegate>
@property (strong, nonatomic) UIImage *capturedImage;
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) AVCapturePhotoOutput *stillImageOutput;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (strong, nonatomic) AVCaptureDevice *backCamera;

// Image recognition
@property (strong, nonatomic) MLModel *model;
@property (strong, nonatomic) VNCoreMLModel *coreModel;
@property (strong, nonatomic) VNCoreMLRequest *request;

@property (strong, nonatomic) NSArray<Category*> *categories;
@property (strong, nonatomic) Category *identifiedCategory;

@end

@implementation CameraViewController

/**
 Start camera when CameraVC first loads on Camera tab.
 */
- (void)viewDidLoad {
    [super viewDidLoad];

    // instantiate the camera
    [self initializeCamera];
    
    // instantiate the gesture recognizers
    UIPinchGestureRecognizer *pinchGR = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchZoom:)];
    [self.previewView addGestureRecognizer:pinchGR];
    self.previewView.userInteractionEnabled = YES;
    pinchGR.cancelsTouchesInView = NO;
    pinchGR.delegate = self;
    
    // Fetch categories
    PFQuery *categoryQuery = [Category query];
    [categoryQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        self.categories = (NSArray<Category*>*)objects;
    }];
    
    [self setUpImageRecognition];
}

- (void) setUpImageRecognition {
    self.model = [[[MobileNetV2 alloc] init] model];
    self.coreModel = [VNCoreMLModel modelForMLModel:self.model error:nil];
    
    // Request to process image. completion handler will be called when a request handler is called with this request
    self.request = [[VNCoreMLRequest alloc] initWithModel: self.coreModel completionHandler: (VNRequestCompletionHandler) ^(VNRequest *request, NSError *error){
        // TODO: why does this need to be in the dispatch thing?
        dispatch_async(dispatch_get_main_queue(), ^{
            // Default to "Other" category if no matches are found
            // TODO: Assumes that Other will be the last category, which doesn't seem like a good practice, but don't want to make another request
            self.identifiedCategory = self.categories[self.categories.count - 1];
            
            BOOL categoryIdentified = NO;
            int i = 0;
            const int NUM_GUESSES_TO_CONSIDER = 10;
            
            // While we have yet to pick a guess and have not met threshold
            while (!categoryIdentified && i < NUM_GUESSES_TO_CONSIDER) {
                // Consider each guess in order (starting from highest confidence)
                VNClassificationObservation *result = request.results[i];
                NSString *guess = result.identifier;
                NSLog(@"%@", guess);
                
                // Check to see if guess matches one of the categories
                int j = 0;
                while (!categoryIdentified && j < self.categories.count) {
                    Category *category = self.categories[j];
                    if ([guess localizedCaseInsensitiveContainsString:category.name]) {
                        NSLog(@"Match found! Guess: %@, Category: %@", guess, category.name);
                        self.identifiedCategory = category;
                        categoryIdentified = YES;
                    }
                }
            }
            
            // Segue to details view
            [self performSegueWithIdentifier:@"segueToDetailsVC" sender:self];
        });
    }];
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
- (void)initializeCamera {
    // setup a new session
    self.session = [AVCaptureSession new];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];

    // select input device
    self.backCamera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!self.backCamera) {
        [(TabBarController*)self.tabBarController showOKAlertWithTitle:@"Error" message:@"Unable to access back camera"];
        NSLog(@"Unable to access back camera");
    }
    
    // prepare the input and output
    NSError *error;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:self.backCamera error:&error];
    if (error) {
        [(TabBarController*)self.tabBarController showOKAlertWithTitle:@"Error" message:error.localizedDescription];
        NSLog(@"Error: Unable to initialize back camera: %@", error.localizedDescription);
    } else {
        self.stillImageOutput = [AVCapturePhotoOutput new];
        
        // attach the input and output
        if ([self.session canAddInput:input] && [self.session canAddOutput:self.stillImageOutput]) {
            [self.session addInput:input];
            [self.session addOutput:self.stillImageOutput];
            [self setupLivePreview];
        }
    }
}

/**
 Configures the live preview to display the camera's view on the screen.
 */
- (void)setupLivePreview {
    self.videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    
    if (self.videoPreviewLayer) {
        self.videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.videoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait; //TODO: make landscape compatible?
        [self.previewView.layer addSublayer:self.videoPreviewLayer];
        
        // start the session on the background thread (startRunning will block the UI if it's running on the main thread)
        dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_async(globalQueue, ^{
            [self.session startRunning];
            
            // set preview layer to fit previewView
            dispatch_async(dispatch_get_main_queue(), ^{
                self.videoPreviewLayer.frame = self.previewView.bounds;
            });
        });
    }
}

/**
 Enables zoom in/out for the live preview.
 */
- (void)handlePinchZoom:(UIPinchGestureRecognizer *)pinchGR {
    const CGFloat pinchVelocityDividerFactor = 5.0f;
    
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
 The user tapped the "Take photo" button.
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
        [self recognizeImage];
        
        // segue to detailsVC
        //self performSegueWithIdentifier:@"segueToDetailsVC" sender:self];
    }
}

/**
 Process image for image recognition
 */
- (void)recognizeImage {
    // Convert to CI image so that image recognition can analyze it
    CIImage *ciImage = [[CIImage alloc] initWithCGImage:self.capturedImage.CGImage];
    
    NSDictionary *options = [[NSDictionary alloc] init];
    NSArray *requestArray = @[self.request];
    
    // Create image recognition request for iamge
    VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithCIImage:ciImage options:options];
    
    // TODO: should this be synchronous or a sync?
    dispatch_async(dispatch_get_main_queue(), ^{
        [handler performRequests:requestArray error:nil];
    });
}

#pragma mark - Navigation

/**
 Prepare for segue to DetailsVC with data to send.
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog("SEgueing");
    DetailsViewController *detailsViewController = [segue destinationViewController];
    
    /*
    PFQuery *categoryQuery = [PFQuery queryWithClassName:@"Category"];
    detailsViewController.category = [categoryQuery getObjectWithId:@"u42Xiik8ok"];
     */
    
    detailsViewController.category = self.identifiedCategory;
    
    
    detailsViewController.image = self.capturedImage;
    detailsViewController.delegate = self;
}
 
/**
 DetailsViewControllerDelegate method. Posts an alert to show trash was posted successfully.
 */
- (void)postedTrash:(nonnull NSString *)message {
    [(TabBarController*)self.tabBarController showOKAlertWithTitle:@"Good work!" message:message];
}

@end
