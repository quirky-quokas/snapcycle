//
//  CategoriesCell.h
//  snapcycle
//
//  Created by kfullen on 7/17/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Category.h"

NS_ASSUME_NONNULL_BEGIN

@interface CategoriesCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *categoryImageView;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;

- (void)setCategory:(Category *)category;

@end

NS_ASSUME_NONNULL_END

