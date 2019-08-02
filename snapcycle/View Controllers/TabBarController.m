//
//  TabBarController.m
//  snapcycle
//
//  Created by taylorka on 7/19/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import "TabBarController.h"
#import "SnapUser.h"
#import "AppDelegate.h"

@interface TabBarController ()

@end

@implementation TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

// Show alert with specified title and message
// Alert has ok button which dismissses it but does nothing else
- (void)showOKAlertWithTitle:(NSString*) title message:(NSString*)message {
    // Create alert controller
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message preferredStyle:UIAlertControllerStyleAlert];
    // Add ok action
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

+ (void)setSnapcycleLogoTitleForNavigationController:(UINavigationController*)navController {
    // set the navigation bar font
    UIColor *scBlue = [UIColor colorWithRed:0.0/255.0 green:112.0/255.0 blue:194.0/255.0 alpha:1.0];
    [navController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:scBlue, NSFontAttributeName:[UIFont fontWithName:@"SourceSansPro-Light" size:25]}];
}

#pragma mark - Logout

/**
 Logs out user. Instance method of Tab Bar Controller so that alert can properly be shown
 */
- (void) logoutUserWithAlertIfError {
    // Logout user
    [SnapUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        if (error) {
            [self showOKAlertWithTitle:@"Error" message:error.localizedDescription];
            NSLog(@"Error logging out: %@", error.localizedDescription);
        } else {
            // Return to login screen
            // Get single instance of app delegate
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            
            // Create new instance of storyboard, starting from login screen
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UINavigationController *loginNavigationController = [storyboard instantiateInitialViewController];
            
            // Set root view controller to switch views
            appDelegate.window.rootViewController = loginNavigationController;
            NSLog(@"Logout successful");
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
