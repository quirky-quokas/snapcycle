//
//  RegisterViewController.m
//  snapcycle
//
//  Created by emilyabest on 7/16/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import "RegisterViewController.h"
#import "SnapUser.h"

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
 User tapped the Sign up button. Add the new user to the database. Dismiss the RegisterVC to return to the LoginVC.
 */
- (IBAction)didTapSignup:(UIButton *)sender {
    //if (self.emailField.text.length != 0) {
    // TODO: check that they have entered email, username, confirm passwords match
    // Initialize user
    SnapUser *newUser = [SnapUser user];
    
    // Set properties
    newUser.email = self.emailField.text;
    newUser.username = self.usernameField.text;
    newUser.password = self.passwordField.text;
    
    // Set up default profile pic
    UIImage *profileImage = [UIImage imageNamed:@"profile-pic-icon"];
    PFFileObject *imageFile = [PFFileObject fileObjectWithName:@"defaultProfImage.png" data:UIImagePNGRepresentation(profileImage)];
    newUser.profImage = imageFile;
    
    // TODO: loading indicator
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            // Create alert controller
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                           message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            
            // Add ok action
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:okAction];
            
            // Show alert
            [self presentViewController:alert animated:YES completion:nil];
            NSLog(@"%@", error.localizedDescription);
        } else {
            NSLog(@"user sucessfully registered");
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
