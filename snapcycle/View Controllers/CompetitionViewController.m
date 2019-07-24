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

@interface CompetitionViewController ()

@property (strong, nonatomic) Competition *currentComp;
@property (strong, nonatomic) NSCalendar *cal;
@property (strong, nonatomic) NSDate *today;

@property (weak, nonatomic) IBOutlet UIView *leaderboardView;
@property (weak, nonatomic) IBOutlet UILabel *joinPromptLabel;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;
@property (weak, nonatomic) IBOutlet UILabel *leaderboardHeaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *leaderboardStatsLabel;

//TODO: use usernames or SnapUsers as keys??
//Concern with SnapUsers: mutable!
@property (strong, nonatomic) NSMutableDictionary<NSString*, NSNumber*> *usernameScores;
@end

@implementation CompetitionViewController

#pragma mark - Load and refresh views
- (void)viewDidLoad {
    [super viewDidLoad];
    self.cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    self.cal.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"PDT"];
    [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PDT"]];
    self.today = [NSDate date];
    
    self.usernameScores = [[NSMutableDictionary alloc] init];

    [self getCurrentCompetition];
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
            for (int i = 0; i < sorted.count; i++) {
                NSString* username = sorted[i];
                [stats appendFormat:@"#%i %@ : %@ items in the landfill today\n", i + 1, username, [self.usernameScores objectForKey:username]];
            }
            self.leaderboardStatsLabel.text = stats;
            [self.leaderboardStatsLabel sizeToFit];
        });
    }];
}

#pragma mark - Previous Competition Results

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
