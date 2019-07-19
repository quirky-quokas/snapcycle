//
//  TabBarController.m
//  snapcycle
//
//  Created by taylorka on 7/19/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import "TabBarController.h"

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
