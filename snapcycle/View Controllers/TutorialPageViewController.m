//
//  TutorialPageViewController.m
//  snapcycle
//
//  Created by kfullen on 7/31/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import "TutorialPageViewController.h"
#import "TutChildViewController.h"

@interface TutorialPageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (strong, nonatomic) NSArray *backdrops;
@property (strong, nonatomic) NSArray *gifs;
@property (strong, nonatomic) NSArray *titles;
@property (strong, nonatomic) NSArray *info;

@end

@implementation TutorialPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    self.dataSource = self;
    self.titles = @[@"Welcome to Snapcycle!", @"Take a photo", @"Track your trash stats!"];
    self.backdrops = @[@"background-1",@"background-2",@"background-3"];
    self.gifs = @[@"first-place",@"second-place",@"third-place"];
    self.info = @[@"Get ready to begin your journey to become a more sustainable and environmentally-conscious", @"Hello this is a test", @"Yoooo this is another test"];
    TutChildViewController *initialViewController = (TutChildViewController*)[self viewControllerAtIndex:0];
    
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    [self setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    NSUInteger index = ((TutChildViewController*) viewController).index;
    
    if (index == 0) {
        return nil;
    }
    
    index--;
    
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    
    NSUInteger index = ((TutChildViewController*) viewController).index;
    
    index++;
    
    if (index == self.backdrops.count) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index {
    TutChildViewController *childViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TutorialPage"];
    childViewController.index = index;
    childViewController.backdropImageStr = self.backdrops[index];
    childViewController.tutroialImageStr = self.gifs[index];
    childViewController.titleText = self.titles[index];
    childViewController.infoText = self.info[index];
    if (index == self.backdrops.count-1){
        childViewController.lastPage = YES;
    }
    else{
        childViewController.lastPage = NO;
    }
    
    return childViewController;
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
