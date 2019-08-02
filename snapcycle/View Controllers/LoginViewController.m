//
//  LoginViewController.m
//  snapcycle
//
//  Created by emilyabest on 7/16/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import "LoginViewController.h"
#import "SnapUser.h"
#import "TabBarController.h"

@interface LoginViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.passwordField.delegate = self;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOffKeyboard:)];
    [self.view setUserInteractionEnabled:YES];
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

/**
 User tapped the login button. Log in the user and segue to CameraVC.
 */
- (IBAction)didTapLogin:(id)sender {
    // Get info user entered
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    // Make login request
    [SnapUser logInWithUsernameInBackground:username password:password block:^(PFUser * _Nullable user, NSError * _Nullable error) {
        if (error) {
            UIAlertController *alert = [LoginViewController createErrorAlertWithOKAndMessage:error.localizedDescription];
            [self presentViewController:alert animated:YES completion:nil];
            NSLog(@"%@", error.localizedDescription);
        } else {
            NSLog(@"user logged in successfully");
            [self performSegueWithIdentifier:@"loggedInSegue" sender:self];
        }
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.passwordField) {
        [textField resignFirstResponder];
        [self didTapLogin:self.passwordField];
        return NO;
    }
    
    return YES;
}

- (IBAction)didTapForgotPassword:(UIButton *)sender {
    // Create alert controller
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Forgot password?" message:@"Look for an email with a link to reset your password." preferredStyle:UIAlertControllerStyleAlert];
    // Add ok action
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
    
    NSLog(@"action received");
}

- (IBAction)tapOffKeyboard:(id)sender {
    [self.view endEditing:YES];
}

// Show alert with title "Error" and given message
// OK button dismisses alert
+ (UIAlertController*)createErrorAlertWithOKAndMessage:(NSString*)message {
    // Create alert controller
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:message preferredStyle:UIAlertControllerStyleAlert];
    // Add ok action
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    return alert;
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
