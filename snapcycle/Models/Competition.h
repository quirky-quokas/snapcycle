//
//  Competition.h
//  snapcycle
//
//  Created by emilyabest on 7/22/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

// Fix import cycle between Competition and Competitor
@class Competitor;

@interface Competition : PFObject<PFSubclassing>

@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong, readonly) NSMutableArray<Competitor*> *competitorArray;

@end

NS_ASSUME_NONNULL_END
