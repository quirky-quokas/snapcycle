//
//  Competition.h
//  snapcycle
//
//  Created by emilyabest on 7/22/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Competition : PFObject<PFSubclassing>
@property (nonatomic, strong, readonly) PFRelation *userArray;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;

@end

NS_ASSUME_NONNULL_END
