//
//  ProfileViewController.m
//  snapcycle
//
//  Created by emilyabest on 7/16/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import "ProfileViewController.h"
#import "Parse/Parse.h"

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set the scrollView frame
    self.scrollView.contentSize = CGSizeMake(375, 1300);
    
    // set the profile picture
    [self setProfilePicture];
    
    // set the welcome text
    self.welcomeLabel.text = [NSString stringWithFormat:@"Welcome %@!", PFUser.currentUser.username];
    
    // display a graph of their three trash piles
        
}

/**
 Sets the user's profile image. If the user does not have a profile image, the default profile image icon is used.
 */
- (void)setProfilePicture {
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
    if (PFUser.currentUser[@"profileImage"]) { //TODO: potentially update with getting profile image from SnapUser instead of Parse database...
        PFFileObject *imageFile = PFUser.currentUser[@"profileImage"];
        UIImage *image = [[UIImage alloc] initWithData:imageFile.getData];
        self.profileImage.image = image;
    }
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
