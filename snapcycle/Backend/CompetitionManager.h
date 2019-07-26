//
//  CompetitionManager.h
//  snapcycle
//
//  Created by taylorka on 7/25/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Competitor.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CompetitionDisplayer

// Passed an array of Competitors sorted in ascending order by score
// If array is null, then the user is not in the compeition and the join screen should be displayed instead
- (void)showCurrentCompetitionView:(NSArray<Competitor*>* _Nullable)sorted;

@end

@interface CompetitionManager : NSObject

@property (weak, nonatomic) id<CompetitionDisplayer> delegate;

+ (instancetype)shared;

// Current Competition
- (void)refreshCurrentCompetition;
- (void)addUserToCurrentCompetition;

// Previous Competition
- (void)refreshYesterdayCompetition;

@end

NS_ASSUME_NONNULL_END
