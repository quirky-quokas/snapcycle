//
//  Competition.m
//  snapcycle
//
//  Created by emilyabest on 7/22/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import "Competition.h"
#import "Parse/Parse.h"

@implementation Competition
@dynamic participantArray;
@dynamic startDate;
@dynamic endDate;
@dynamic rankingArray;

+ (nonnull NSString *)parseClassName {
    return @"Competition";
}

@end



