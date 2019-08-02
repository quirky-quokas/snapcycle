//
//  CompTabViewController.m
//  snapcycle
//
//  Created by emilyabest on 7/30/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import "CompTabViewController.h"
#import "TodayCompViewController.h"
#import "YesterdayCompViewController.h"
#import "ViewController.h"
#import "CompTabSegControl.h"
#import "TabBarController.h"

@interface CompTabViewController ()
@property (weak, nonatomic) IBOutlet CompTabSegControl *compTab;
@property (strong, nonatomic) TodayCompViewController *todayComp;
@property (strong, nonatomic) YesterdayCompViewController *yestComp;
@property (weak, nonatomic) IBOutlet UIView *tabView;

@end

@implementation CompTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set the navigation bar font
    UIColor *scBlue = [UIColor colorWithRed:0.0/255.0 green:112.0/255.0 blue:194.0/255.0 alpha:1.0];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:scBlue, NSFontAttributeName:[UIFont fontWithName:@"SourceSansPro-Light" size:25]}];
    
    [self setupTabsDesign];
    [self instantiateVCs];
    [self setupView];
}

- (void)instantiateVCs {
    // instantiate VCs
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.todayComp = [storyboard instantiateViewControllerWithIdentifier:@"todayComp"];
    self.yestComp = [storyboard instantiateViewControllerWithIdentifier:@"yestComp"];
    
    // add VCs
    [self addChildVC:self.todayComp];
    [self addChildVC:self.yestComp];
}

- (void)setupView {
    [self setupSegmentedControl];
    [self updateView];
}

- (void)setupSegmentedControl {
    [self.compTab addTarget:self action:@selector(selectionDidChange:) forControlEvents:UIControlEventValueChanged];
    
    self.compTab.selectedSegmentIndex = 0;
}

- (void)selectionDidChange:(UISegmentedControl *)seg {
    [self updateView];
}

- (void)updateView {
    if (self.compTab.selectedSegmentIndex == 0) {
        [self removeChildVC:self.yestComp];
        [self addChildVC:self.todayComp];
    } else {
        [self removeChildVC:self.todayComp];
        [self addChildVC:self.yestComp];
    }
}

- (void)addChildVC:(UIViewController *)childVC {
    [self addChildViewController:childVC];
    [self.tabView addSubview:childVC.view];
    
    childVC.view.frame = self.tabView.bounds;
//    childVC.view.autoresizingMask = ((void)(UIViewAutoresizingFlexibleWidth), UIViewAutoresizingFlexibleHeight); // TODO: potentially this autoresizing code is incorrect
//    childVC.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
//    childVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleWidth;
    // TODO: do we want autoresizing? Or would we rather have the VC scroll? probably the scroll...
    [childVC didMoveToParentViewController:self];
}

- (void)removeChildVC:(UIViewController *)childVC {
    [childVC willMoveToParentViewController:nil]; // TODO: why must we notify before removing?
    [childVC.view removeFromSuperview];
    [childVC removeFromParentViewController];
}

-(void)setupTabsDesign {
    [self.compTab setColorAndFont];
}

/**
 Logs out user
 */
- (IBAction)onLogoutTap:(id)sender {
    // Logout user
    [((TabBarController*)self.tabBarController) logoutUserWithAlertIfError];
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
