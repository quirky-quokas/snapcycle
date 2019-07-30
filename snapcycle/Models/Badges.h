//
//  Badges.h
//  snapcycle
//
//  Created by taylorka on 7/26/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Badges : PFObject<PFSubclassing>

@property (strong, nonatomic) NSNumber *numFirstPlace;
@property (strong, nonatomic) NSNumber *numSecondPlace;
@property (strong, nonatomic) NSNumber *numThirdPlace;

@end

NS_ASSUME_NONNULL_END
