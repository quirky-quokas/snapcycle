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

@dynamic name;
@dynamic type;
@dynamic image;
@dynamic user;

+ (nonnull NSString *)parseClassName {
    return @"Trash";
}

+ (void) postTrash:(Category*)category withImage:(UIImage * _Nullable )image withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    Trash *newTrash = [Trash new];
    
    newTrash.name = category.name;
    newTrash.type = category.type;
    newTrash.user = [SnapUser currentUser];
    
    if (image){
        newTrash.image = [RegisterViewController getPFFileFromImage:image];
    }
    else {
        
        newTrash.image = category.image;
    }
    
    [newTrash saveInBackgroundWithBlock: completion];
    
}
@end
