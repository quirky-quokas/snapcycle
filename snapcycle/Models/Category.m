//
//  Category.m
//  snapcycle
//
//  Created by kfullen on 7/16/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import "Category.h"

@implementation Category

@dynamic name;
@dynamic description;
@dynamic type;
@dynamic image;

+ (nonnull NSString *)parseClassName {
    return @"Category";
}

@end
