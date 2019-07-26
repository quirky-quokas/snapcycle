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

@property (nonatomic, strong, readonly) PFRelation *trashArray;
@property (nonatomic, strong) PFFileObject *profImage;
@property (nonatomic, strong) NSNumber *numBadges;

@end

NS_ASSUME_NONNULL_END
