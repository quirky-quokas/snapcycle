//
//  Trash.m
//  snapcycle
//
//  Created by kfullen on 7/16/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import "Trash.h"

@implementation Trash

@dynamic name;
@dynamic type;
@dynamic timestamp;
@dynamic image;
@dynamic user;

+ (nonnull NSString *)parseClassName {
    return @"Trash";
}
@end
