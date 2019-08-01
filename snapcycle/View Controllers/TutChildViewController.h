//
//  TutChildViewController.h
//  snapcycle
//
//  Created by kfullen on 7/31/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TutChildViewController : UIViewController

@property (assign, nonatomic) NSInteger index;
@property (strong, nonatomic) NSString *backdropImageStr;
@property (strong, nonatomic) NSString *tutroialImageStr;
@property (strong, nonatomic) NSString *titleText;
@property (strong, nonatomic) NSString *infoText;

@end

NS_ASSUME_NONNULL_END
