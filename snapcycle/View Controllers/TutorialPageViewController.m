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

//@property (strong, nonatomic) NSArray *backdrops;
@property (strong, nonatomic) NSArray *gifs;
@property (strong, nonatomic) NSArray *titles;
@property (strong, nonatomic) NSArray *info;

@end

@implementation TutorialPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIPageControl appearance] setPageIndicatorTintColor: [UIColor whiteColor]];
    UIColor *scGreen = [UIColor colorWithRed:148.0/255.0 green:200.0/255.0 blue:61.0/255.0 alpha:1.0];
    UIColor *scBlue = [UIColor colorWithRed:0.0/255.0 green:112.0/255.0 blue:194.0/255.0 alpha:1.0];
    [[UIPageControl appearance] setCurrentPageIndicatorTintColor:scBlue];
    [[UIPageControl appearance] setTintColor: [UIColor whiteColor]];
//    column1.color = [[HIColor alloc] initWithHexValue:@"ADDEE5"];
//
    UIColor *skyBlue = [UIColor colorWithRed:153.0/255.0 green:217.0/255.0 blue:229.0/255.0 alpha:1.0];
    [[UIPageControl appearance] setBackgroundColor:skyBlue];
    
    self.dataSource = self;
    self.titles = @[@"Welcome to Snapcycle!", @"Snap your trash.", @"Check your progress!", @"Compete with friends.", @"Go save the world!"];
//    self.backdrops = @[@"nature-backdrop",@"nature-backdrop",@"nature-backdrop",@"nature-backdrop",@"nature-backdrop"];
    self.gifs = @[@"https://media.giphy.com/media/l1KVcrdl7rJpFnY2s/giphy.gif",@"https://gifsstore.com/public/upload/gifs/15653843891565384386.gif",@"https://gifsstore.com/public/upload/gifs/15653871041565387101.gif",@"https://cdn.dribbble.com/users/42976/screenshots/1912873/animation.gif", @"https://www.arborday.org/kids/photosynthesis/images/7.gif"];
    // https://media.giphy.com/media/3o7TKJr0rcnn2TswAU/giphy.gif
    // https://media.giphy.com/media/NVmUrHjkO1Af5mPVBq/giphy.gif
    // https://media.giphy.com/media/l378c04F2fjeZ7vH2/giphy.gif
    // https://i.gifer.com/OZm.gif
    // https://media.giphy.com/media/J2JZ5XTY0JtKpAWx2t/giphy.gif
    self.info = @[@"Thank you for choosing to save the world! Our goal is to help you become a more environmentally-conscious citizen of the Earth, one piece of trash at a time.", @"Tip: You can look up your piece of trash without a camera using our Search tab.", @"Use to: \n \u2022 \t Learn better habits \n \u2022 \t Track your trash \n \u2022 \t Learn where your trash goes", @"Participate in daily and global Snapcycle competitions! Winners earn badges!", @"Now you're ready to go! Click the button below to begin! Good luck and happy snapcycling!"];
    // Thank you for choosing to save the world one piece of trash at a time. Our goal is to help you on your journey to becoming a more sustainable and environmentally-conscious citizen of the Earth. We hope you'll find it rewarding :) So let's start!
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
    
    if (index == self.titles.count) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index {
    TutChildViewController *childViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TutorialPage"];
    childViewController.index = index;
//    childViewController.backdropImageStr = self.backdrops[index];
    childViewController.tutorialImageStr = self.gifs[index];
    childViewController.titleText = self.titles[index];
    childViewController.infoText = self.info[index];
    
    if (index == self.titles.count-1){
        childViewController.lastPage = YES;
    }
    else{
        childViewController.lastPage = NO;
    }
    
    return childViewController;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return self.titles.count;
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

