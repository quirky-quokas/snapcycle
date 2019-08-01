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
#import "Badges.h"
#import "TutorialViewController.h"

@interface RegisterViewController () // <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
//@property (strong, nonatomic) UITextField *activeField;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    [self registerForKeyboardNotifications];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOffKeyboard:)];
    [self.view setUserInteractionEnabled:YES];
    [self.view addGestureRecognizer:tapGestureRecognizer];
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

        // Create badges object for user
        Badges *badges = [Badges new];
        badges.numFirstPlace = @(0);
        badges.numSecondPlace = @(0);
        badges.numThirdPlace = @(0);
        newUser.badges = badges;

        // Set up default profile pic
        newUser.profImage = [RegisterViewController getPFFileFromImage:[UIImage imageNamed:@"profile-pic-icon"]];

        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (error) {
                UIAlertController *alert = [LoginViewController createErrorAlertWithOKAndMessage:error.localizedDescription];
                [self presentViewController:alert animated:YES completion:nil];
                NSLog(@"Cannot create account: %@", error.localizedDescription);
            } else {
                NSLog(@"user sucessfully registered");
                //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                //TutorialViewController *tutorialViewController = [storyboard instantiateViewControllerWithIdentifier:@"TutorialViewController"];
                //[self presentViewController:tutorialViewController animated:YES completion:nil];
                [self performSegueWithIdentifier:@"registeredSegue" sender:self];
            }
        }];
    }
}

- (IBAction)tapOffKeyboard:(id)sender {
    [self.view endEditing:YES];
}

/**
 Adding scroll with keyboard
 */
- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:self.view.window];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:self.view.window];
}

/**
 Called when UIKeyboardDidShowNotification is sent
 */
- (void)keyboardWasShown:(NSNotification *)notif {
    self.scrollView.contentSize = self.view.frame.size;
}

/**
 Called when UIKeyboardWillHideNotification is sent
 */
- (void)keyboardWillBeHidden:(NSNotification *)notif {
    self.scrollView = nil;
}

// Get file from image
+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image {
    // check if image is not nil
    if (!image) {
        return nil;
    }
    
    NSData *imageData = UIImagePNGRepresentation(image);
    // get image data and check if that is not nil
    if (!imageData) {
        return nil;
    }
    
    // return object with image
    return [PFFileObject fileObjectWithName:@"image.png" data:imageData];
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
