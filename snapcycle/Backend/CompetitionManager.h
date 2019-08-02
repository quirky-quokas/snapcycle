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

@protocol CurrentCompetitionDisplayer

// YES- user score has changed (they have thrown away a landfill item)
// NO- user score has not changed, no need to refresh stats
@property BOOL userScoreChanged;

// Passed an array of Competitors sorted in ascending order by score
- (void)showCurrentCompetitionView:(NSArray<Competitor*>* _Nullable)sorted;

@end

@protocol PreviousResultsDisplayer

// Passed an array of Competitors sorted in ascending order by score
// If array is null, then there were no winners/participants
- (void)showPreviousResults:(NSArray<Competitor*>* _Nullable)sorted;

@end

@interface CompetitionManager : NSObject

@property (weak, nonatomic) id<CurrentCompetitionDisplayer> currentCompetitionDisplayer;
@property (weak, nonatomic) id<PreviousResultsDisplayer> previousResultsDisplayer;

+ (instancetype)shared;

#pragma mark - Current Competition

// Checks for new day/ new competition
- (void)refreshCurrentCompetition;

// Adds user to current competition competitors
- (void)addUserToCurrentCompetition;

// Increasees user's score by 1 in current competition
// If user is not in current competition, then nothing happens
- (void)incrementUserLandfillScore;

#pragma mark - Previous Competition
- (void)refreshYesterdayCompetition;

@end

NS_ASSUME_NONNULL_END
