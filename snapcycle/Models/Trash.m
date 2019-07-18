//
//  Trash.m
//  snapcycle
//
//  Created by kfullen on 7/16/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import "Trash.h"
#import "Category.h"
#import "RegisterViewController.h"
#import "SnapUser.h"

@implementation Trash

@dynamic category;
@dynamic userAction;
@dynamic image;
@dynamic user;

+ (nonnull NSString *)parseClassName {
    return @"Trash";
}

@end
