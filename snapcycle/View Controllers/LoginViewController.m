//
//  LoginViewController.m
//  snapcycle
//
//  Created by emilyabest on 7/16/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import "LoginViewController.h"
#import "SnapUser.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.    
}

/**
 User tapped the login button. Log in the user and segue to CameraVC.
 */
- (IBAction)didTapLogin:(UIButton *)sender {
    // Get info user entered
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    // Make login request
    [SnapUser logInWithUsernameInBackground:username password:password block:^(PFUser * _Nullable user, NSError * _Nullable error) {
        if (error) {
            //TODO: display error messages
            NSLog(@"%@", error.localizedDescription);
        } else {
            NSLog(@"user logged in successfully");
            [self performSegueWithIdentifier:@"loggedInSegue" sender:self];
        }
    }];
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
