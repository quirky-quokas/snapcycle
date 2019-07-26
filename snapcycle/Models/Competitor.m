//
//  Ranking.m
//  snapcycle
//
//  Created by taylorka on 7/24/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import "Competitor.h"

@implementation Competitor

@dynamic user;
@dynamic score;
@dynamic competition;
@dynamic rank;

+ (nonnull NSString *)parseClassName {
    return @"Competitor";
}

@end
