//
//  TutorialPageViewController.h
//  snapcycle
//
//  Created by kfullen on 7/31/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TutorialPageViewController : UIPageViewController

// YES- tutorial launched modally from profile help, dismiss to exit
// NO - tutorial launched after register, segue to exit
@property (nonatomic) BOOL dismissToExit;

@end

NS_ASSUME_NONNULL_END

