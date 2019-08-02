//
//  TutorialViewController.m
//  snapcycle
//
//  Created by kfullen on 7/31/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import "TutorialViewController.h"
#import "TutorialPageViewController.h"

@interface TutorialViewController ()



@end

@implementation TutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     TutorialPageViewController *tutPageVC = [segue destinationViewController];
     tutPageVC.dismissToExit = self.dismissToExit;
 }


@end

