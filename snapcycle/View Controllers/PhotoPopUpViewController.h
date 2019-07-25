//
//  PhotoPopUpViewController.h
//  snapcycle
//
//  Created by kfullen on 7/25/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Trash.h"

NS_ASSUME_NONNULL_BEGIN

@interface PhotoPopUpViewController : UIViewController
@property (nonatomic, strong) Trash *trash;
@property (nonatomic, strong) UIImage *convertedImage;
@end

NS_ASSUME_NONNULL_END
