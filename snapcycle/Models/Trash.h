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

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) PFFileObject *image;
@property (nonatomic, strong) SnapUser *user;

+ (void) postTrash:(Category*)category withImage:(UIImage * _Nullable )image withCompletion: (PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
