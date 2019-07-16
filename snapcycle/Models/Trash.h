//
//  Trash.h
//  snapcycle
//
//  Created by kfullen on 7/16/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import <Parse/Parse.h>
#import "SnapUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface Trash : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSDate *timestamp;
@property (nonatomic, strong) PFFileObject *image;
@property (nonatomic, strong) SnapUser *user;

@end

NS_ASSUME_NONNULL_END
