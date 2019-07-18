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

@interface CameraViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) UIImage *chosenImage;
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIImageView *captureImageView;
@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) AVCapturePhotoOutput *stillImageOutput;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // open the camera
    [self initializeCamera];
}

/**
 The user tapped the "Take photo" button.
 */
- (IBAction)didTakePhoto:(UIButton *)sender {
}

/**
 Opens a custom camera
 */
- (void)initializeCamera {
    // setup a new session
    self.session = [AVCaptureSession new];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];

    // select input device
    AVCaptureDevice *backCamera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!backCamera) {
        // use camera roll?
        NSLog(@"Unable to access back camera");
    }
    
    // prepare and attach the input and output
    NSError *error;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];
    if (error) {
        NSLog(@"Error: Unable to initialize back camera: %@", error.localizedDescription);
    } else {
        self.stillImageOutput = [AVCapturePhotoOutput new];
        
        if ([self.session canAddInput:input] && [self.session canAddOutput:self.stillImageOutput]) {
            [self.session addInput:input];
            [self.session addOutput:self.stillImageOutput];
        }
    }
    
    // attach the input and output
    
}

/**
 Opens a camera/camera roll.
 */
- (void)initializeCamera1 {
    // instantiate a UIImagePickerController
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;

    // check if camera is supported
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
}

/**
 The delegate method for UIImagePickerControllerDelegate. Picks the selected image.
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *, id> *)info {
//    SnapUser *currUser = [SnapUser currentUser];

    // get image
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    self.chosenImage = editedImage;

    // dismiss UIImagePickerController to go back to ComposeVC
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 Gets and returns a PFFile of a UIImage.
 */
- (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image {
    if (!image) {
        return nil;
    }

    NSData *imageData = UIImagePNGRepresentation(image);

    if (!imageData) {
        return nil;
    }

    return [PFFileObject fileObjectWithName:@"image.png" data:imageData];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
