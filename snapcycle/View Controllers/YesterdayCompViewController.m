//
//  YesterdayCompViewController.m
//  snapcycle
//
//  Created by emilyabest on 7/29/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import "YesterdayCompViewController.h"

@interface YesterdayCompViewController ()

@end

@implementation YesterdayCompViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/**
 XLPagerTAbStripViewControllerDelegate method
 */
- (NSString *)titleForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController {
    return @"Yesterday";
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
