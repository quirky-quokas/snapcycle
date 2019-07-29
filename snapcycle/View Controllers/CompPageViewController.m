//
//  CompPageViewController.m
//  snapcycle
//
//  Created by emilyabest on 7/26/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import "CompPageViewController.h"

@interface CompPageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (strong, nonatomic) UIPageViewController *pageVC;
@property (strong, nonatomic) NSMutableArray *pages;

@end

@implementation CompPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    self.pageVC.delegate = self;
    self.pageVC.dataSource = self;
    
    self.pages = [NSMutableArray new];
    
    // get view controllers
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc1 = [storyboard instantiateViewControllerWithIdentifier:@"compVC1"];
    UIViewController *vc2 = [storyboard instantiateViewControllerWithIdentifier:@"compVC2"];
    UIViewController *vc3 = [storyboard instantiateViewControllerWithIdentifier:@"compVC3"];
    UIViewController *vc4 = [storyboard instantiateViewControllerWithIdentifier:@"compVC4"];

    [self.pages addObject:vc1];
    [self.pages addObject:vc2];
    [self.pages addObject:vc3];
    [self.pages addObject:vc4];
    
    [self.pageVC setViewControllers:self.pages[0] direction:UIPageViewControllerNavigationDirectionForward animated:false completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

/**
 UIPageViewControllerDelegate method. Returns the previous page.
 */
- (nullable UIViewController *)pageViewController:(nonnull UIPageViewController *)pageViewController viewControllerBeforeViewController:(nonnull UIViewController *)viewController {
    NSUInteger currIndex = [self.pages indexOfObject:viewController];

    // stop circular scroll
//    if (currIndex == 0) {
//        return nil;
//    }

    NSUInteger prevIndex = currIndex - 1;
    return self.pages[prevIndex];
}

/**
 UIPageViewControllerDelegate method. Returns the next page.
 */
- (nullable UIViewController *)pageViewController:(nonnull UIPageViewController *)pageViewController viewControllerAfterViewController:(nonnull UIViewController *)viewController {
    NSUInteger currIndex = [self.pages indexOfObject:viewController];

//    // stop circular scroll
//    if (currIndex == (self.pages.count - 1)) {
//        return nil;
//    }

    NSUInteger nextIndex = currIndex + 1;
    return self.pages[nextIndex];
}

//- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
//    <#code#>
//}
//
//- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection {
//    <#code#>
//}
//
//- (void)preferredContentSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
//    <#code#>
//}
//
//- (CGSize)sizeForChildContentContainer:(nonnull id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize {
//    <#code#>
//}
//
//- (void)systemLayoutFittingSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
//    <#code#>
//}
//
//- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
//    <#code#>
//}
//
//- (void)willTransitionToTraitCollection:(nonnull UITraitCollection *)newCollection withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
//    <#code#>
//}
//
//- (void)didUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context withAnimationCoordinator:(nonnull UIFocusAnimationCoordinator *)coordinator {
//    <#code#>
//}
//
//- (void)setNeedsFocusUpdate {
//    <#code#>
//}
//
//- (BOOL)shouldUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context {
//    <#code#>
//}
//
//- (void)updateFocusIfNeeded {
//    <#code#>
//}

@end
