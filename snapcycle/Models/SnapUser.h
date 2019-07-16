//
//  SnapUser.h
//  snapcycle
//
//  Created by kfullen on 7/16/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface SnapUser : PFUser <PFSubclassing>
//@property (nonatomic, strong) NSString *username;
//@property (nonatomic, strong) NSString *password;
//@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) PFRelation *trashArray;
@property (nonatomic, strong) PFFileObject *profImage;
@end

NS_ASSUME_NONNULL_END
