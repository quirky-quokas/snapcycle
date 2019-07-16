//
//  User.h
//  snapcycle
//
//  Created by kfullen on 7/16/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppUser : PFUser <PFSubclassing>

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) PFFileObject *profImage;
@property (nonatomic, strong) PFRelation *trashArray;
@property (nonatomic, strong) PFRelation *compostArray;
@property (nonatomic, strong) PFRelation *recycleArray;

@end

NS_ASSUME_NONNULL_END
