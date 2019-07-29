//
//  CompContainerViewController.m
//  snapcycle
//
//  Created by emilyabest on 7/26/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import "CompContainerViewController.h"
#import "CompPageViewController.h"

@interface CompContainerViewController ()
@property (weak, nonatomic) IBOutlet UIView *container;
@property (strong, nonatomic) CompPageViewController *compPVC;

@end

@implementation CompContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        // Do any additional setup after loading the view.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([[segue identifier] isEqualToString:@"segueToCompPVC"]) {
//        self.compPVC = [segue destinationViewController];
//
//        [self addChildViewController:self.compPVC];
//        [self.view addSubview:self.compPVC.view];
//        [self.container = self.compPVC.view];
//        [self.compPVC didMoveToParentViewController: self];
//    }
}

@end
