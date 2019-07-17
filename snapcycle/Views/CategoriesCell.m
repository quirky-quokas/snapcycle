//
//  CategoriesCell.m
//  snapcycle
//
//  Created by kfullen on 7/17/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import "CategoriesCell.h"
#import "Category.h"

@implementation CategoriesCell

- (void)setCategory:(Category *)category {
    
    self.categoryLabel.text = category.name;
    
    PFFileObject *image = category.image;
    [image getDataInBackgroundWithBlock:^(NSData * data, NSError * error) {
        if (!error) {
            UIImage *imageToLoad = [UIImage imageWithData:data];
            [self.categoryImageView setImage:imageToLoad];
        }
        else {
            NSLog(@"%@",error.localizedDescription);
        }
        
    }];
    
}

@end

