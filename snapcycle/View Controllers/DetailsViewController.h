//
//  DetailsViewController.h
//  snapcycle
//
//  Created by emilyabest on 7/16/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Category.h"

NS_ASSUME_NONNULL_BEGIN

@interface DetailsViewController : UIViewController
@property (nonatomic, strong) Category *category;
@end

NS_ASSUME_NONNULL_END

