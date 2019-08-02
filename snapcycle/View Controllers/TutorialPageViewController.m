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
    self.titles = @[@"Welcome to Snapcycle!", @"Snap a photo to know where your trash goes", @"Check your progress!", @"Take your learnings to the stage!", @"Go and save the world!"];
    self.backdrops = @[@"nature-backdrop",@"nature-backdrop",@"nature-backdrop",@"nature-backdrop",@"nature-backdrop"];
    self.gifs = @[@"https://media.giphy.com/media/3o7TKJr0rcnn2TswAU/giphy.gif",@"https://media.giphy.com/media/NVmUrHjkO1Af5mPVBq/giphy.gif",@"https://media.giphy.com/media/l378c04F2fjeZ7vH2/giphy.gif",@"https://i.gifer.com/OZm.gif", @"https://media.giphy.com/media/J2JZ5XTY0JtKpAWx2t/giphy.gif"];
    self.info = @[@"Thank you for choosing to save the world one piece of trash at a time. Our goal is to help you on your journey to becoming a more sustainable and environmentally-conscious citizen of the Earth. We hope you'll find it rewarding :) So let's start!", @"Tip: You can look up your piece of trash w/o a camera using our Search tab", @"Use to: Track your trash, Learn more about your trash and where it goes, Learn better habits", @"Participate in daily and global Snapcycle competitions! Winners can earn badges!", @"Now you're ready to go! Click the button below to begin! Good luck and happy snapcycling!"];
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
        NSLog(@"At last page");
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

