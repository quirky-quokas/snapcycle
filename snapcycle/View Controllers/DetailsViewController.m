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
#import "CompetitionManager.h"
#import "SoundManager.h"

@interface DetailsViewController () <UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *categoryImageView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UILabel *moreInfoLabel;
@property (weak, nonatomic) IBOutlet UIButton *recycleButton;
@property (weak, nonatomic) IBOutlet UIButton *compostButton;
@property (weak, nonatomic) IBOutlet UIButton *landfillButton;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.nameLabel.text = self.category.name;
    self.moreInfoLabel.text = self.category.moreInfo;
    [self.moreInfoLabel sizeToFit];
    
    // set up info label
    NSString *infoString = self.category.info;
    infoString = [infoString stringByReplacingOccurrencesOfString:@", " withString:@",\n"];
    NSMutableAttributedString *infoAttributedString = [[NSMutableAttributedString alloc] initWithString:infoString];
    if ([self.category.info containsString:@"recycle bin"]) {
        NSRange foundRange = [infoString rangeOfString:@"recycle bin"];
        UIColor *scBlue = [UIColor colorWithRed:0.0/255.0 green:112.0/255.0 blue:194.0/255.0 alpha:1.0];
        [infoAttributedString addAttribute:NSForegroundColorAttributeName value:scBlue range:foundRange];
    }
    if ([self.category.info containsString:@"compost bin"]) {
        NSRange foundRange = [infoString rangeOfString:@"compost bin"];
        UIColor *scGreen = [UIColor colorWithRed:148.0/255.0 green:200.0/255.0 blue:61.0/255.0 alpha:1.0];
        [infoAttributedString addAttribute:NSForegroundColorAttributeName value:scGreen range:foundRange];
    }
    if ([self.category.info containsString:@"landfill"]) {
        NSRange foundRange = [infoString rangeOfString:@"landfill"];
        UIColor *scBrown = [UIColor colorWithRed:150.0/255.0 green:75.0/255.0 blue:0.0/255.0 alpha:1.0];
        [infoAttributedString addAttribute:NSForegroundColorAttributeName value:scBrown range:foundRange];
    }
    
    [self.infoLabel setAttributedText:infoAttributedString];
    [self.infoLabel sizeToFit];
    
    if ([(NSObject*)self.delegate isKindOfClass:[CategoriesViewController class]]) {
        PFFileObject *image = self.category.image;
        [image getDataInBackgroundWithBlock:^(NSData * data, NSError * error) {
            if (!error) {
                UIImage *imageToLoad = [UIImage imageWithData:data];
                [self.categoryImageView setImage:imageToLoad];
                self.categoryImageView.contentMode = UIViewContentModeScaleAspectFit;
            }
            else {
                NSLog(@"%@",error.localizedDescription);
                [(TabBarController*)self.tabBarController showOKAlertWithTitle:@"Error" message:error.localizedDescription];
            }
        }];
    }
    else {
        self.categoryImageView.image = self.image;
        
        // instantiate gesture recognizer
        UITapGestureRecognizer *enlargeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapEnlarge:)];
        [self.categoryImageView addGestureRecognizer:enlargeTap];
        enlargeTap.cancelsTouchesInView = NO;
        enlargeTap.numberOfTouchesRequired = 1;
        enlargeTap.numberOfTapsRequired = 1;
        enlargeTap.delegate = self;
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
            
            NSString* message = [[NSString alloc] init];
            NSString* title = [[NSString alloc] init];
            if(newTrash.category.recycling == YES) {
                title = @"Good work!";
                message = @"You've successfully recycled your trash.";
                [SoundManager playSuccessSound];
            }
            else {
                if (newTrash.category.landfill == YES && newTrash.category.compost == YES){
                    title = @"Oops!";
                    message = @"You shouldn't have recycled that. Next time try throwing it in compost or landfill.";
                }
                else if (newTrash.category.landfill == NO && newTrash.category.compost == YES) {
                    title = @"Oops!";
                    message = @"You shouldn't have recycled that. Next time try throwing it in compost.";
                }
                else if (newTrash.category.landfill == YES && newTrash.category.compost == NO){
                    title = @"Oops!";
                    message = @"You shouldn't have recycled that. Next time try throwing it in landfill.";
                }
                else {
                    title = @"Sorry about that!";
                    message = @"We don't have info on this item at the moment, but we're working on getting it soon :)";
                }
                [SoundManager playFailureSound];
            }
            [self.delegate postedTrashWithMessage:message withTitle:title];
            
        }
        else {
            [(TabBarController*)self.tabBarController showOKAlertWithTitle:@"Could not recycle trash." message:error.localizedDescription];
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

            NSString* message = [[NSString alloc] init];
            NSString* title = [[NSString alloc] init];
            if(newTrash.category.compost == YES) {
                title = @"Good work!";
                message = @"You've successfully composted your trash.";
                [SoundManager playSuccessSound];
            }
            else {
                title = @"Oops!";
                
                if (newTrash.category.landfill == YES && newTrash.category.recycling == YES){
                    message = @"You shouldn't have composted that. Next time try throwing it in recycling or landfill.";
                }
                else if (newTrash.category.landfill == NO && newTrash.category.recycling == YES){
                    message = @"You shouldn't have composted that. Next time try throwing it in recycling.";
                }
                else if (newTrash.category.landfill == YES && newTrash.category.recycling == NO){
                    message = @"You shouldn't have composted that. Next time try throwing it in landfill.";
                }
                else {
                    title = @"Sorry about that!";
                    message = @"We don't have info on this item at the moment, but we're working on getting it soon :)";
                }
                [SoundManager playFailureSound];
            }
            [self.delegate postedTrashWithMessage:message withTitle:title];
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
            // Save landfill item to user's array
            SnapUser *user = [SnapUser currentUser];
            [user.trashArray addObject:newTrash];
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            }];
            
            // Update user score 
            [[CompetitionManager shared] incrementUserLandfillScore];
            
            [self.navigationController popViewControllerAnimated:YES];
            
            NSString *message = [[NSString alloc] init];
            NSString* title = [[NSString alloc] init];
            if(newTrash.category.landfill == YES) {
                title = @"Good work!";
                message = @"You've successfully thrown away your trash.";
                [SoundManager playSuccessSound];
            }
            else {
                title = @"Oops!";
                
                if (newTrash.category.recycling == YES && newTrash.category.compost == YES){
                    message = @"You shouldn't have thrown that in landfill. Next time try throwing it in recycling or compost.";
                }
                else if (newTrash.category.recycling == YES && newTrash.category.compost == NO) {
                    message = @"You shouldn't have thrown that in landfill. Next time try throwing it in recyling.";
                }
                else if (newTrash.category.recycling == NO && newTrash.category.compost == YES){
                    message = @"You shouldn't have thrown that in landfill. Next time try throwing it in compost.";
                }
                else {
                    title = @"Sorry about that!";
                    message = @"We don't have info on this item at the moment, but we're working on getting it soon :)";
                }
                [SoundManager playFailureSound];
            }
            [self.delegate postedTrashWithMessage:message withTitle:title];
        }
        else {
            [(TabBarController*)self.tabBarController showOKAlertWithTitle:@"Could not throw away trash." message:error.localizedDescription];
        }
        self.landfillButton.enabled = YES;
    }];
}

#pragma mark - Tap to enlarge
/**
 Allows user to tap their trash photo for an enlarged full screen view.
 */
- (void)handleTapEnlarge:(UITapGestureRecognizer *)tapGR {
    UIViewController *fullScreenVC = [[UIViewController alloc] init];
    
    // show full screen view
    UIImageView *fullScreenView = [[UIImageView alloc] initWithFrame:self.view.frame];
    fullScreenView.contentMode = UIViewContentModeScaleAspectFit;
    fullScreenView.image = self.categoryImageView.image;
    fullScreenVC.view = fullScreenView;

    [self presentViewController:fullScreenVC animated:YES completion:nil];

    // add gesture recognizer to remove full screen view
    UITapGestureRecognizer *dismissTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeFullScreen:)];
    [fullScreenVC.view addGestureRecognizer:dismissTap];
    fullScreenVC.view.userInteractionEnabled = YES;
    dismissTap.cancelsTouchesInView = NO;
    dismissTap.numberOfTouchesRequired = 1;
    dismissTap.numberOfTapsRequired = 1;
}

/**
 Removes the enlarged full screen view of the user's trash photo.
 */
- (void)removeFullScreen:(UITapGestureRecognizer *)tapGR {
    [self dismissViewControllerAnimated:YES completion:nil];
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
