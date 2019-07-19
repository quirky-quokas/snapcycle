//
//  DetailsViewController.m
//  snapcycle
//
//  Created by emilyabest on 7/16/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import "DetailsViewController.h"
#import "CameraViewController.h"
#import "CategoriesViewController.h"
#import "RegisterViewController.h"
#import "SnapUser.h"
#import "Trash.h"
#import "TabBarController.h"

@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *categoryImageView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIButton *recycleButton;
@property (weak, nonatomic) IBOutlet UIButton *compostButton;
@property (weak, nonatomic) IBOutlet UIButton *landfillButton;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.nameLabel.text = self.category.name;
    self.infoLabel.text = self.category.info;
    
    if ([(NSObject*)self.delegate isKindOfClass:[CategoriesViewController class]]) {
        PFFileObject *image = self.category.image;
        [image getDataInBackgroundWithBlock:^(NSData * data, NSError * error) {
            if (!error) {
                UIImage *imageToLoad = [UIImage imageWithData:data];
                [self.categoryImageView setImage:imageToLoad];
            }
            else {
                NSLog(@"%@",error.localizedDescription);
                [(TabBarController*)self.tabBarController showOKAlertWithTitle:@"Error" message:error.localizedDescription];
            }
            
        }];
    }
    else {
        self.categoryImageView.image = self.image;
    }
}

- (IBAction)recycleTrash:(id)sender {
    self.landfillButton.enabled = NO;
    Trash *newTrash = [Trash new];
    
    newTrash.category = self.category;
    newTrash.userAction = @"recycling";
    newTrash.user = [SnapUser currentUser];
    if ([(NSObject*)self.delegate isKindOfClass:[CategoriesViewController class]]) {
        newTrash.image = self.category.image;
    }
    else {
        CGFloat imageWidth = [UIScreen mainScreen].bounds.size.width/3;
        CGFloat imageHeight = [UIScreen mainScreen].bounds.size.height/3;
        CGSize size = CGSizeMake(imageWidth, imageHeight);
        UIImage *resizedImage = [DetailsViewController imageWithImage:self.image scaledToFillSize:size];
        newTrash.image = [RegisterViewController getPFFileFromImage:resizedImage];
    }
    
    [newTrash saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            SnapUser *user = [SnapUser currentUser];
            [user.trashArray addObject:newTrash];
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            }];
            [self.navigationController popViewControllerAnimated:YES];
            NSString* message = @"You've successfully recycled your trash";
            [self.delegate postedTrash:message];
        }
        else {
            [(TabBarController*)self.tabBarController showOKAlertWithTitle:@"Could not recycle trash" message:error.localizedDescription];
        }
        self.landfillButton.enabled = YES;
    }];
}

- (IBAction)compostTrash:(id)sender {
    self.landfillButton.enabled = NO;
    Trash *newTrash = [Trash new];
    
    newTrash.category = self.category;
    newTrash.userAction = @"compost";
    newTrash.user = [SnapUser currentUser];
    if ([(NSObject*)self.delegate isKindOfClass:[CategoriesViewController class]]) {
        newTrash.image = self.category.image;
    }
    else {
        CGFloat imageWidth = [UIScreen mainScreen].bounds.size.width/3;
        CGFloat imageHeight = [UIScreen mainScreen].bounds.size.height/3;
        CGSize size = CGSizeMake(imageWidth, imageHeight);
        UIImage *resizedImage = [DetailsViewController imageWithImage:self.image scaledToFillSize:size];
        newTrash.image = [RegisterViewController getPFFileFromImage:resizedImage];
    }
    
    [newTrash saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            SnapUser *user = [SnapUser currentUser];
            [user.trashArray addObject:newTrash];
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            }];
            [self.navigationController popViewControllerAnimated:YES];
            NSString* message = @"You've successfully composted your trash";
            [self.delegate postedTrash:message];
        }
        else {
            [(TabBarController*)self.tabBarController showOKAlertWithTitle:@"Could not compost trash" message:error.localizedDescription];
        }
        self.landfillButton.enabled = YES;
    }];
}

- (IBAction)throwAwayTrash:(id)sender {
    self.landfillButton.enabled = NO;
    Trash *newTrash = [Trash new];
    
    newTrash.category = self.category;
    newTrash.userAction = @"landfill";
    newTrash.user = [SnapUser currentUser];
    if ([(NSObject*)self.delegate isKindOfClass:[CategoriesViewController class]]) {
        newTrash.image = self.category.image;
    }
    else {
        CGFloat imageWidth = [UIScreen mainScreen].bounds.size.width/3;
        CGFloat imageHeight = [UIScreen mainScreen].bounds.size.height/3;
        CGSize size = CGSizeMake(imageWidth, imageHeight);
        UIImage *resizedImage = [DetailsViewController imageWithImage:self.image scaledToFillSize:size];
        newTrash.image = [RegisterViewController getPFFileFromImage:resizedImage];

    }
    
    [newTrash saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            SnapUser *user = [SnapUser currentUser];
            [user.trashArray addObject:newTrash];
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            }];
            [self.navigationController popViewControllerAnimated:YES];
            NSString* message = @"You've successfully thrown away your trash";
            [self.delegate postedTrash:message];
        }
        else {
            [(TabBarController*)self.tabBarController showOKAlertWithTitle:@"Could not throw away trash" message:error.localizedDescription];
        }
        self.landfillButton.enabled = YES;
    }];
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToFillSize:(CGSize)size
{
    CGFloat scale = MAX(size.width/image.size.width, size.height/image.size.height);
    CGFloat width = image.size.width * scale;
    CGFloat height = image.size.height * scale;
    CGRect imageRect = CGRectMake((size.width - width)/2.0f,
                                  (size.height - height)/2.0f,
                                  width,
                                  height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [image drawInRect:imageRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
