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

@interface CameraViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) UIImage *chosenImage;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // open the camera
    [self initializeCamera];
}

/**
 Opens a camera/camera roll.
 */
- (void)initializeCamera {
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

    // show UIImagePickerController
    [self presentViewController:imagePickerVC animated:NO completion:nil];
}

/**
 The delegate method for UIImagePickerControllerDelegate. Picks the selected image.
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *, id> *)info {
//    SnapUser *currUser = [SnapUser currentUser];

    // get image
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    self.chosenImage = editedImage;

    // make new Trash object
    Trash *newTrash = [[Trash alloc] init];
    newTrash.user = currUser;
    //    newTrash.type = nil; // TODO: image recognition
    //    newTrash.name = nil; // TODO: image recognition
    newTrash.image = imagePFFile;

//    // make new Trash object
//    Trash *newTrash = [[Trash alloc] init];
//    newTrash.user = currUser;
//    //    newTrash.type = nil; // TODO: image recognition
//    //    newTrash.name = nil; // TODO: image recognition
//    newTrash.timestamp = [NSDate date];
//    newTrash.image = imagePFFile;
//
//    // add new Trash object to trashArray
//    PFRelation *trashArray = [currUser relationForKey:@"trashArray"];
//    [newTrash saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
//        if (!error) {
//            [trashArray addObject:newTrash];
//            [currUser saveInBackground];
//        } else {
//            NSLog(@"Error: %@", error.localizedDescription);
//        }
//    }];

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
