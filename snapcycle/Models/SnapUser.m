//
//  SnapUser.m
//  snapcycle
//
//  Created by kfullen on 7/16/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import "SnapUser.h"

@implementation SnapUser

@dynamic username;
@dynamic password;
@dynamic email;
@dynamic profImage;
@dynamic trashArray;

+ (nonnull NSString *)parseClassName {
    return @"SnapUser";
}

@end
