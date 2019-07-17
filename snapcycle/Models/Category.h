//
//  Category.h
//  snapcycle
//
//  Created by kfullen on 7/16/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Category : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *info;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) PFFileObject *image;

+ (void) makeCategory;

@end

NS_ASSUME_NONNULL_END

