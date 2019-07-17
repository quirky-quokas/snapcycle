//
//  RegisterViewController.m
//  snapcycle
//
//  Created by emilyabest on 7/16/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import "RegisterViewController.h"
#import "SnapUser.h"
#import "LoginViewController.h"

@interface RegisterViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordField;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/**
 User tapped the Sign up button. Add the new user to the database. Segues to logged in view
 */
- (IBAction)didTapSignup:(UIButton *)sender {
    // Confirm passwords match
    if (![self.passwordField.text isEqualToString:self.confirmPasswordField.text]) {
        UIAlertController *alert = [LoginViewController createErrorAlertWithOKAndMessage:@"passwords must match"];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        // Initialize user
        SnapUser *newUser = [SnapUser user];
        
        // Set properties
        newUser.email = self.emailField.text;
        newUser.username = self.usernameField.text;
        newUser.password = self.passwordField.text;
        
        // Set up default profile pic
        // TODO: remove redundancy- get PFFileFromImage
        UIImage *profileImage = [UIImage imageNamed:@"profile-pic-icon"];
        PFFileObject *imageFile = [PFFileObject fileObjectWithName:@"defaultProfImage.png" data:UIImagePNGRepresentation(profileImage)];
        newUser.profImage = imageFile;
        
        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (error) {
                UIAlertController *alert = [LoginViewController createErrorAlertWithOKAndMessage:error.localizedDescription];
                [self presentViewController:alert animated:YES completion:nil];
                NSLog(@"Cannot create account: %@", error.localizedDescription);
            } else {
                [self performSegueWithIdentifier:@"registeredSegue" sender:self];
                NSLog(@"user sucessfully registered");
            }
        }];
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
