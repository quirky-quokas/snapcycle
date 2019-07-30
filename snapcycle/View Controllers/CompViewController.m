//
//  CompViewController.m
//  snapcycle
//
//  Created by emilyabest on 7/29/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import "CompViewController.h"
#import "TodayCompViewController.h"
#import "YesterdayCompViewController.h"

@interface CompViewController ()
@property BOOL isReload;

@end

@implementation CompViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/**
 XLPagerTabStripViewControllerDataSource
 */
-(NSArray *)childViewControllersForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController {
    // create child view controllers that will be managed by XLPagerTabStripVC
    TodayCompViewController *todayVC = [[TodayCompViewController alloc] init];
    YesterdayCompViewController *yestVC = [[YesterdayCompViewController alloc] init];
    
    if (!self.isReload) {
        return @[todayVC, yestVC];
    }
    
    NSMutableArray *childVCs = [NSMutableArray arrayWithObjects:todayVC, yestVC, nil];
    NSUInteger count = [childVCs count];
    for (NSUInteger i = 0; i < count; i++) {
        // select a random element between i and end of array to swap with -> WHY?
        NSUInteger nElements = count - i;
        NSUInteger n = (arc4random() % nElements) + 1;
        [childVCs exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    NSUInteger nItems = 1 + (rand() % 4);
    return [childVCs subarrayWithRange:NSMakeRange(0, nItems)];
}

-(void)reloadPagerTabStripView {
    self.isReload = YES;
    self.isProgressiveIndicator = (rand() % 2 == 0);
    self.isElasticIndicatorLimit = (rand() % 2 == 0);
    [super reloadPagerTabStripView];
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
