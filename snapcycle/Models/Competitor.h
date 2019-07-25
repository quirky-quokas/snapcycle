//
//  Ranking.h
//  snapcycle
//
//  Created by taylorka on 7/24/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import <Parse/Parse.h>
#import "SnapUser.h"
#import "Competition.h"

NS_ASSUME_NONNULL_BEGIN

@interface Competitor : PFObject<PFSubclassing>

@property (nonatomic, strong) SnapUser *user;
@property (nonatomic, strong) NSNumber *score;
@property (nonatomic, strong) Competition *competition;

// Should only be stored in parse after competition finishes
@property (nonatomic, strong) NSNumber *rank;


@end

NS_ASSUME_NONNULL_END
