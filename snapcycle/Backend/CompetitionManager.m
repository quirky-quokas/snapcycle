//
//  CompetitionManager.m
//  snapcycle
//
//  Created by taylorka on 7/25/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import "CompetitionManager.h"
#import "Competition.h"
#import "Competitor.h"
#import "SnapUser.h"

// TODO: remove
#import "Badges.h"

@interface CompetitionManager()

// Current competition
@property (strong, nonatomic) Competition *currentComp;
@property (strong, nonatomic) NSArray *sortedCompetitors;

// Previous competition
@property (strong, nonatomic) Competition *previousComp;
@property (strong, nonatomic) NSArray *sortedPrevious;

@property (strong, nonatomic) NSCalendar *cal;
@property (strong, nonatomic) NSDate *today;

@end

@implementation CompetitionManager

+ (instancetype)shared {
    static CompetitionManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Set up time zone and date
        self.cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        self.cal.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"PDT"];
        [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PDT"]];
        self.today = [NSDate date];
        
    }
    return self;
}

- (void) updateToday {
    self.today = [NSDate date];
    // If it's a different day from when we last fetched competition
    if (self.currentComp && [self.currentComp.endDate compare:self.today] == NSOrderedAscending) {
        NSLog(@"It's a new day, refetching competition");
        [self refreshCurrentCompetition];
    }
}


#pragma mark - Current Competition

// Fetch current daily competition, or create a new one if there is none
- (void)refreshCurrentCompetition {
    // Update today
    // TODO: figure out when to update today
    self.today = [NSDate date];

    // Check if there is currently a competition (current date is between start and end date)
    [self competitionQueryForDay:self.today completion:^(PFObject * _Nullable competition, NSError * _Nullable error) {
        if (competition) {
            // There is an ongoing competition
            NSLog(@"there is a current competition");
            self.currentComp = (Competition*)competition;
            self.sortedCompetitors = [self sortCompetitors:self.currentComp.competitorArray];
            [self.currentCompetitionDisplayer showCurrentCompetitionView:self.sortedCompetitors];
        } else  {
            // No current competition, make one
            NSLog(@"no current competition, creating one");
            [self makeCompetition];
        }
    }];
}

/**
 Make the daily competition.
 TODO: change this to weekly?
 */
- (void)makeCompetition {
    Competition *newCompetition = [Competition new];
    newCompetition.rankingsFinal = NO;
    
    newCompetition.startDate = [self.cal startOfDayForDate:self.today];
    
    // Calculate 24 hours after start date (in seconds)
    int NUM_SECONDS_IN_24_HOURS = 86399;
    newCompetition.endDate = [NSDate dateWithTimeInterval:NUM_SECONDS_IN_24_HOURS sinceDate:newCompetition.startDate];
    
    [newCompetition saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error creating competition: %@", error.localizedDescription);
        } else  {
            self.currentComp = newCompetition;
            
            // User cannot already be in competition because it was just created
            [self.currentCompetitionDisplayer showCurrentCompetitionView:self.currentComp.competitorArray];
        }
    }];
}

#pragma mark - Manage user

- (void)addUserToCurrentCompetition {
    // Create Competitor object
    SnapUser *currentUser = [SnapUser currentUser];
    
    Competitor *competitor = [Competitor new];
    competitor.competition = self.currentComp;
    competitor.user = currentUser;
    
    // Calculate number of items user has thrown in landfill today --> starting score
    PFQuery *landfillItemsQuery = [currentUser.trashArray query];
    [landfillItemsQuery whereKey:@"userAction" equalTo:@"landfill"];
    [landfillItemsQuery whereKey:@"createdAt" greaterThanOrEqualTo:self.currentComp.startDate];
    [landfillItemsQuery whereKey:@"createdAt" lessThanOrEqualTo:self.currentComp.endDate];
    
    [landfillItemsQuery countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
        competitor.score = @(number);
        [competitor saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            // After successfully saved
            // TODO: error catching
            [self.currentComp addObject:competitor forKey:@"competitorArray"];
            [self.currentComp saveInBackground];
            
            // TODO: doesn't refresh other competitors
            self.sortedCompetitors = [self sortCompetitors:self.currentComp.competitorArray];
            [self.currentCompetitionDisplayer showCurrentCompetitionView:self.sortedCompetitors];
        }];
    }];
}

- (void)incrementUserLandfillScore {
    // TODO: updateToday is async.
    [self updateToday];
    
    // Update competition score
    PFQuery *competitorQuery = [Competitor query];
    [competitorQuery whereKey:@"user" equalTo:[SnapUser currentUser]];
    [competitorQuery whereKey:@"competition" equalTo:self.currentComp];
    [competitorQuery getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (error) {
            // Also catches case where user is not in competition
            NSLog(@"%@", error.localizedDescription);
        } else {
            [object incrementKey:@"score"];
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                self.currentCompetitionDisplayer.userScoreChanged = YES;
            }];
            
        }
    }];
}

# pragma mark - Previous Competition
- (void)refreshYesterdayCompetition {
    // TODO: updateToday is async.
    [self updateToday];
    
    // Yesterday
    NSDateComponents *minusOneDay = [[NSDateComponents alloc] init];
    [minusOneDay setDay:-1];
    NSDate *yesterday = [self.cal dateByAddingComponents:minusOneDay toDate:self.today options:0];
    
    [self competitionQueryForDay:yesterday completion:^(PFObject * _Nullable competition, NSError * _Nullable error) {
        if (competition) {
            self.previousComp = (Competition*)competition;
            [self checkPreviousRanking];
        } else {
            NSLog(@"no competition yesterday");
        }
    }];
}

- (void)checkPreviousRanking {
    if (self.previousComp.competitorArray && self.previousComp.competitorArray.count != 0) {
        // Competition had participants, sort them by score
        self.sortedPrevious = [self sortCompetitors:self.previousComp.competitorArray];
        
        if (self.previousComp.rankingsFinal) {
            // Competitors have already been ranked, pass results to delegate
            [self.previousResultsDisplayer showPreviousResults:self.sortedPrevious];
        } else {
            // Competitors have not yet been ranked
            [self calculateAndPostPreviousRanking];
        }
    } else {
        NSLog(@"no participants");
        [self.previousResultsDisplayer showPreviousResults:NULL];
    }
}

- (void) calculateAndPostPreviousRanking {
    self.previousComp.rankingsFinal = YES;
    [self.previousComp saveInBackground];
    
    int rank = 0;
    NSNumber *prevUserItems = @(-1);
    
    for (Competitor* competitor in self.sortedPrevious) {
        NSNumber *userItems = competitor.score;
        
        // Check for ties. Rank should only increase if the current user has a different score than the
        // previous user since the users are sorted
        if (![prevUserItems isEqualToNumber:userItems]) {
            rank++;
        }
        
        // If user is a winner, update number of badges
        if (rank == 1) {
            [competitor.user.badges incrementKey:@"numFirstPlace"];
            [competitor.user.badges saveInBackground];
        } else if (rank == 2) {
            [competitor.user.badges incrementKey:@"numSecondPlace"];
            [competitor.user.badges saveInBackground];
        } else if (rank == 3) {
            [competitor.user.badges incrementKey:@"numThirdPlace"];
            [competitor.user.badges saveInBackground];
        }
        
        competitor.rank = @(rank);
        [competitor saveInBackground];
        
        // Update prevUserItems for next iteration of loop
        prevUserItems = userItems;
    }
    // Pass results to delegate
    [self.previousResultsDisplayer showPreviousResults:self.sortedPrevious];
}

# pragma mark - Helper methods
- (NSArray<Competitor*>*)sortCompetitors:(NSArray<Competitor*>*)competitorArray {
    return [competitorArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSNumber* first = ((Competitor*)obj1).score;
        NSNumber* second = ((Competitor*)obj2).score;
        return [first compare:second];
    }];
}

- (void)competitionQueryForDay:(NSDate*)day completion:(void(^)(PFObject * _Nullable competition, NSError * _Nullable error))completion  {
    PFQuery *compQuery = [Competition query];
    [compQuery whereKey:@"startDate" lessThanOrEqualTo:day];
    [compQuery whereKey:@"endDate" greaterThanOrEqualTo:day];
    [compQuery includeKey:@"competitorArray"];
    [compQuery includeKey:@"competitorArray.user"];
    [compQuery includeKey:@"competitorArray.user.badges"];
    
    [compQuery getFirstObjectInBackgroundWithBlock:completion];
}

@end
