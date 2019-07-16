//
//  RegisterViewController.m
//  snapcycle
//
//  Created by emilyabest on 7/16/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import "RegisterViewController.h"

@interface RegisterViewController ()

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/**
 User tapped the cancel button. Dismiss the RegisterVC to return to the LoginVC.
 */
- (IBAction)didTapCancel:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 User tapped the Sign up button. Add the new user to the database. Dismiss the RegisterVC to return to the LoginVC.
 */
- (IBAction)didTapSignup:(UIButton *)sender {
    // TODO: add new user to database
    
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
