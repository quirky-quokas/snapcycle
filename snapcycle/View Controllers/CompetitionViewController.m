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
#import "Competitor.h"

@interface CompetitionViewController ()

/*
@property (strong, nonatomic) Competition *currentComp;
@property (strong, nonatomic) Competition *previousComp;
@property (strong, nonatomic) NSCalendar *cal;
@property (strong, nonatomic) NSDate *today;
 */

@property (weak, nonatomic) IBOutlet UIView *leaderboardView;
@property (weak, nonatomic) IBOutlet UILabel *joinPromptLabel;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;
@property (weak, nonatomic) IBOutlet UILabel *leaderboardHeaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *leaderboardStatsLabel;

@property (weak, nonatomic) IBOutlet UILabel *previousWinnerLabel;
@property (weak, nonatomic) IBOutlet UILabel *previousUserRankLabel;

@property (strong, nonatomic) CompetitionManager *manager;

/*
//TODO: use usernames or SnapUsers as keys??
//Concern with SnapUsers: mutable!
@property (strong, nonatomic) NSMutableDictionary<NSString*, NSNumber*> *usernameScores;
*/

@end

@implementation CompetitionViewController

#pragma mark - Load and refresh views
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // TODO: remove
    // self.usernameScores = [[NSMutableDictionary alloc] init];
    
    self.manager = [CompetitionManager shared];
    self.manager.delegate = self;
    
    // Will call back self to update view
    [self.manager refreshCurrentCompetition];

    [self.manager refreshYesterdayCompetition];
}

// TODO: pull to refresh instead
- (void)viewDidAppear:(BOOL)animated {
    /*
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
     */
}

#pragma mark - Current Competition

// Passed an array of Competitors sorted in ascending order by score
// If array is null, then the user is not in the compeition and the join screen should be displayed instead
- (void)showCurrentCompetitionView:(NSArray<Competitor*>* _Nullable)sorted {
    if (sorted) {
        // User is in current competition
        self.joinPromptLabel.hidden = YES;
        self.joinButton.hidden = YES;
        self.leaderboardStatsLabel.hidden = NO;
        self.leaderboardHeaderLabel.hidden = NO;
        
        [self showCompetitionStats:sorted];
    } else {
        // User is not in current competition
        self.joinPromptLabel.hidden = NO;
        self.joinButton.hidden = NO;
        self.leaderboardStatsLabel.hidden = YES;
        self.leaderboardHeaderLabel.hidden = YES;
    }
}

// Load leaderboard
- (void)showCompetitionStats:(NSArray<Competitor*>*)sorted {
    NSMutableString *stats = [[NSMutableString alloc] init];
    
    int rank = 0;
    NSNumber *prevUserItems = @(-1);
    
    for (Competitor* competitor in sorted) {
        NSNumber *userItems = competitor.score;
        
        // Check for ties. Rank should only increase if the current user has a different score than the
        // previous user since the users are sorted
        if (![prevUserItems isEqualToNumber:userItems]) {
            rank++;
        }
        
        [stats appendFormat:@"#%i %@ : %@ items in the landfill today\n", rank, competitor.user.username, userItems];
        // Update prevUserItems for next iteration of loop
        prevUserItems = userItems;
    }
    self.leaderboardStatsLabel.text = stats;
    [self.leaderboardStatsLabel sizeToFit];
}

#pragma mark - Previous Competition Results

- (void)showPreviousWinners:(NSArray<Competitor*>* _Nullable)sorted {
    // TODO: implement view
}

/*
- (void) showPreviousResults {
    // TODO: can add competitions from other days
    [self getYesterdayCompetition];
}


- (void) loadPreviousWinner {
    PFQuery *winnerQuery = [self.previousComp.rankingArray query];
    [winnerQuery whereKey:@"rank" equalTo:@(1)];
    [winnerQuery includeKey:@"user"];
    [winnerQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        NSMutableString *results = [NSMutableString stringWithString:@"Winner(s): "];
        if (objects.count != 0) {
            NSArray<Competitor*> *winners = (NSArray<Competitor*>*)objects;
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
            Competitor *userRank = (Competitor*)object;
            
            if ([userRank.rank isEqualToNumber:@(1)]) {
                self.previousUserRankLabel.text = @"Congrats, you're a winner! Thanks for snapcycling!";
            } else {
                self.previousUserRankLabel.text = [NSString stringWithFormat:@"You ranked #%@ with %@ items in the landfill. Thanks for snapcycling!", userRank.rank, userRank.score];
            }
            self.previousUserRankLabel.hidden = NO;
        }
    }];
}
 */

#pragma mark - User Actions
- (IBAction)onJoinTap:(id)sender {
    [self.manager addUserToCurrentCompetition];
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
