//
//  CompetitionViewController.m
//  snapcycle
//
//  Created by emilyabest on 7/22/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import "CompetitionViewController.h"
#import "Competition.h"
#import "SnapUser.h"
#import <Highcharts/Highcharts.h>
#import "Ranking.h"

@interface CompetitionViewController ()

@property (strong, nonatomic) Competition *currentComp;
@property (strong, nonatomic) Competition *previousComp;
@property (strong, nonatomic) NSCalendar *cal;
@property (strong, nonatomic) NSDate *today;

@property (weak, nonatomic) IBOutlet UIView *leaderboardView;
@property (weak, nonatomic) IBOutlet UILabel *joinPromptLabel;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;
@property (weak, nonatomic) IBOutlet UILabel *leaderboardHeaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *leaderboardStatsLabel;

@property (weak, nonatomic) IBOutlet UILabel *previousWinnerLabel;
@property (weak, nonatomic) IBOutlet UILabel *previousUserRankLabel;

//TODO: use usernames or SnapUsers as keys??
//Concern with SnapUsers: mutable!
@property (strong, nonatomic) NSMutableDictionary<NSString*, NSNumber*> *usernameScores;
@end

@implementation CompetitionViewController

#pragma mark - Load and refresh views
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // UIPageViewController

    self.pageIndex = 1;
    
    
    ///////
    
    self.cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    self.cal.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"PDT"];
    [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PDT"]];
    self.today = [NSDate date];
    
    self.usernameScores = [[NSMutableDictionary alloc] init];

    [self getCurrentCompetition];
    [self showPreviousResults];
}

- (void)viewDidAppear:(BOOL)animated {
    // Update current date
    self.today = [NSDate date];
    
    // If it's a different day from when we last fetched competition
    if (self.currentComp && [self.currentComp.endDate compare:self.today] == NSOrderedAscending) {
        NSLog(@"It's a new day, refetching competition");
        // Reset cached scores bc we are no longer displaying the same competition
        self.usernameScores = [[NSMutableDictionary alloc] init];

        [self getCurrentCompetition];
        [self showPreviousResults];
    } else {
        // TODO: only refresh stats if user is currently in competition
        [self refreshCompetitionStats];
    }
}

#pragma mark - Current Competition

// Fetch current daily competition, or create a new one if there is none
- (void)getCurrentCompetition {
    // Check if there is currently a competition (current date is between start and end date)
    PFQuery *competitionQuery = [Competition query];
    [competitionQuery whereKey:@"startDate" lessThanOrEqualTo:self.today];
    [competitionQuery whereKey:@"endDate" greaterThanOrEqualTo:self.today];
    [competitionQuery getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable competition, NSError * _Nullable error) {
        if (competition) {
            // There is an ongoing competition
            NSLog(@"there is a current competition");
            self.currentComp = (Competition*)competition;
            [self checkIfUserIsInCurrentComp]; // TODO: move this logic out of if/else with dispatch group?
        } else  {
            // No current competition, make one
            NSLog(@"no current competition, creating one");
            [self makeCompetition];
        }
    }];
}

// Check if user is in current competition and refresh view
- (void)checkIfUserIsInCurrentComp {
    PFQuery *participantQuery = [self.currentComp.participantArray query];
    [participantQuery whereKey:@"objectId" equalTo:[SnapUser currentUser].objectId];
    
    [participantQuery countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error fetching participants: %@", error.localizedDescription);
        } else if (number == 0) {
            // User is not in competition
            [self refreshViewWithStatusInComp:NO];
        } else {
            // User is in competion
            [self refreshViewWithStatusInComp:YES];
        }
    }];
}

// Refresh display based on whether user is currently in competition
- (void)refreshViewWithStatusInComp:(BOOL)userInComp {
    if (userInComp) {
        // User has already joined current competition
        self.joinPromptLabel.hidden = YES;
        self.joinButton.hidden = YES;
        self.leaderboardStatsLabel.hidden = NO;
        self.leaderboardHeaderLabel.hidden = NO;
        [self refreshCompetitionStats];
    } else {
        // User hasn't joined current competition
        self.joinPromptLabel.hidden = NO;
        self.joinButton.hidden = NO;
        self.leaderboardStatsLabel.hidden = YES;
        self.leaderboardHeaderLabel.hidden = YES;
    }
}

// Fetch competition stats and reload leaderboard
- (void)refreshCompetitionStats {
    dispatch_group_t group = dispatch_group_create();
    
    // Fetch all participants
    PFQuery *participantQuery = [self.currentComp.participantArray query];
    [participantQuery findObjectsInBackgroundWithBlock:^(NSArray<SnapUser*> * _Nullable participants, NSError * _Nullable error) {
        // TODO: optimize
        // Find number of landfill items today for each user
        for (SnapUser *participant in participants) {
            PFQuery *landfillItemsQuery = [participant.trashArray query];
            [landfillItemsQuery whereKey:@"userAction" equalTo:@"landfill"];
            [landfillItemsQuery whereKey:@"createdAt" greaterThanOrEqualTo:self.currentComp.startDate];
            [landfillItemsQuery whereKey:@"createdAt" lessThanOrEqualTo:self.currentComp.endDate];
            
            dispatch_group_enter(group);
            [landfillItemsQuery countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
                [self.usernameScores setValue:@(number) forKey:participant.username];
                dispatch_group_leave(group);
            }];
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            // Order from least to most items and print
            NSArray<NSString*> *sorted = [self.usernameScores keysSortedByValueUsingSelector:@selector(compare:)];
            NSMutableString *stats = [[NSMutableString alloc] init];
            
            int rank = 0;
            NSNumber *prevUserItems = @(-1);
            
            for (NSString* username in sorted) {
                NSNumber *userItems = [self.usernameScores objectForKey:username];
                
                // Check for ties. Rank should only increase if the current user has a different score than the
                // previous user since the users are sorted
                if (![prevUserItems isEqualToNumber:userItems]) {
                    rank++;
                }
                
                [stats appendFormat:@"#%i %@ : %@ items in the landfill today\n", rank, username, userItems];
                
                // Update prevUserItems for next iteration of loop
                prevUserItems = userItems;
            }
            self.leaderboardStatsLabel.text = stats;
            [self.leaderboardStatsLabel sizeToFit];
        });
    }];
}


#pragma mark - Previous Competition Results

- (void) showPreviousResults {
    // TODO: can add competitions from other days
    [self getYesterdayCompetition];
}

// TODO: assumes there was always a competition yesterday, which isn't true if no one opened the app yesterday
- (void) getYesterdayCompetition {
    NSLog(@"getting yesterday's competition");
    // Yesterday
    NSDateComponents *minusOneDay = [[NSDateComponents alloc] init];
    [minusOneDay setDay:-1];
    NSDate *yesterday = [self.cal dateByAddingComponents:minusOneDay toDate:self.today options:0];
    
    // TODO: abstract out, can share with current comp query --> competition for day
    PFQuery *yesterdayCompQuery = [Competition query];
    [yesterdayCompQuery whereKey:@"startDate" lessThanOrEqualTo:yesterday];
    [yesterdayCompQuery whereKey:@"endDate" greaterThanOrEqualTo:yesterday];
    [yesterdayCompQuery getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (object) {
            self.previousComp = (Competition*)object;
            [self checkPreviousRanking];
        } else {
            NSLog(@"no competition yesterday");
        }
    }];
}

- (void) checkPreviousRanking {
    PFQuery *rankingQuery = [self.previousComp.rankingArray query];
    // TODO: change this to count? which is better? really just want to check if it's empty
    [rankingQuery getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (!object) {
            NSLog(@"rankings have not yet been calculated");
            [self calculateAndPostPreviousRanking];
        } else if (object) {
            NSLog(@"rankings have already been calculated, pull rankings");
            // in both cases we need to do this, figure out how to pull out but problems because of asyc
            [self loadPreviousWinner];
            [self loadPreviousUserRank];
        } else {
            NSLog(@"%@", error);
        }
    }];
}

- (void) calculateAndPostPreviousRanking {
    // TODO: abstract out with current comp code
    NSLog(@"calculating rankings");
    dispatch_group_t group = dispatch_group_create();
    
    // Fetch all participants
    PFQuery *participantQuery = [self.previousComp.participantArray query];
    [participantQuery findObjectsInBackgroundWithBlock:^(NSArray<SnapUser*> * _Nullable participants, NSError * _Nullable error) {
        
        // Find number of landfill items today for each user
        for (SnapUser *participant in participants) {
            PFQuery *landfillItemsQuery = [participant.trashArray query];
            [landfillItemsQuery whereKey:@"userAction" equalTo:@"landfill"];
            [landfillItemsQuery whereKey:@"createdAt" greaterThanOrEqualTo:self.previousComp.startDate];
            [landfillItemsQuery whereKey:@"createdAt" lessThanOrEqualTo:self.previousComp.endDate];
            
            dispatch_group_enter(group);
            [landfillItemsQuery countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
                Ranking *rank = [Ranking new];
                rank.user = participant;
                rank.score = @(number);
                
                [rank saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    [self.previousComp.rankingArray addObject:rank];
                    dispatch_group_leave(group);
                }];
            }];
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            // Order from least to most items and print
            NSLog(@"Posting rankings");
            [self.previousComp saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                PFQuery *rankQuery = [self.previousComp.rankingArray query];
                [rankQuery orderByAscending:@"score"];
                
                // TODO: similar to refresh competition stats
                [rankQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable sorted, NSError * _Nullable error) {
                    NSLog(@"sorting rankings");
                    int rank = 0;
                    NSNumber *prevUserItems = @(-1);
                    
                    for (Ranking* ranking in sorted) {
                        NSNumber *userItems = ranking.score;
                        
                        // Check for ties. Rank should only increase if the current user has a different score than the
                        // previous user since the users are sorted
                        if (![prevUserItems isEqualToNumber:userItems]) {
                            rank++;
                        }
                        
                        ranking.rank = @(rank);
                        [ranking saveInBackground];
                        
                        // Update prevUserItems for next iteration of loop
                        prevUserItems = userItems;
                    }
                    
                    [self loadPreviousWinner];
                    [self loadPreviousUserRank];
                }];
            }];
        });
    }];
}

- (void) loadPreviousWinner {
    PFQuery *winnerQuery = [self.previousComp.rankingArray query];
    [winnerQuery whereKey:@"rank" equalTo:@(1)];
    [winnerQuery includeKey:@"user"];
    [winnerQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        NSMutableString *results = [NSMutableString stringWithString:@"Winner(s): "];
        if (objects.count != 0) {
            NSArray<Ranking*> *winners = (NSArray<Ranking*>*)objects;
            [results appendString: winners[0].user.username];
            for (int i = 1; i < winners.count; i++) {
                [results appendFormat:@", %@", winners[i].user.username];
            }
            [results appendFormat:@" with %@ items in the landfill", winners[0].score];
            self.previousWinnerLabel.text = results;
            
        } else {
            [results appendString: @"no winner"];
        }
        self.previousWinnerLabel.text = results;
    }];
    
}

- (void) loadPreviousUserRank {
    PFQuery *userRankQuery = [self.previousComp.rankingArray query];
    [userRankQuery whereKey:@"user" equalTo:[SnapUser currentUser]];
    [userRankQuery getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (!object) {
            // User did not participate in yesterday's competition
            self.previousUserRankLabel.hidden = YES;
        } else if (error) {
            NSLog(@"%@", error.localizedDescription);
        } else {
            // User participated in yesterday's competition
            Ranking *userRank = (Ranking*)object;
            
            if ([userRank.rank isEqualToNumber:@(1)]) {
                self.previousUserRankLabel.text = @"Congrats, you're a winner! Thanks for snapcycling!";
            } else {
                self.previousUserRankLabel.text = [NSString stringWithFormat:@"You ranked #%@ with %@ items in the landfill. Thanks for snapcycling!", userRank.rank, userRank.score];
            }
            self.previousUserRankLabel.hidden = NO;
        }
    }];
}

#pragma mark - Organize competitions

/**
 Make the daily competition.
 TODO: change this to weekly?
 TODO: PDT
 */
- (void)makeCompetition {
    Competition *newCompetition = [Competition new];
    
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
            [self refreshViewWithStatusInComp:NO];
        }
    }];
}


#pragma mark - User Actions
- (IBAction)onJoinTap:(id)sender {
    [self.currentComp.participantArray addObject:[SnapUser currentUser]];
    [self.currentComp saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            // TODO: error
            NSLog(@"Error joining: %@", error.localizedDescription);
        } else {
            [self refreshViewWithStatusInComp:YES];
        }
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
