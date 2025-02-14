//
//  DetailsViewController.h
//  snapcycle
//
//  Created by emilyabest on 7/16/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Category.h"
#import "Trash.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DetailsViewControllerDelegate
- (void) postedTrashWithMessage:(NSString*)message withTitle:(NSString*)title;
@end

@interface DetailsViewController : UIViewController
@property (nonatomic, strong) Category *category;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, weak) id<DetailsViewControllerDelegate> delegate;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToFillSize:(CGSize)size;
@end

NS_ASSUME_NONNULL_END

