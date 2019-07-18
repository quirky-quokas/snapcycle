//
//  Trash.h
//  snapcycle
//
//  Created by kfullen on 7/16/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import <Parse/Parse.h>
#import "SnapUser.h"
#import "Category.h"

NS_ASSUME_NONNULL_BEGIN

@interface Trash : PFObject<PFSubclassing>

@property (nonatomic, strong) Category *category;
@property (nonatomic, strong) NSString *userAction;
@property (nonatomic, strong) PFFileObject *image;
@property (nonatomic, strong) SnapUser *user;

@end

NS_ASSUME_NONNULL_END
