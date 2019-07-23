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

@interface CompetitionViewController ()

@property (strong, nonatomic) Competition *currentComp;
@property (strong, nonatomic) NSCalendar *cal;

@property (weak, nonatomic) IBOutlet UIView *compView;
@property (weak, nonatomic) IBOutlet UILabel *joinPromptLabel;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;


@end

@implementation CompetitionViewController

#pragma mark - Load and refresh views
- (void)viewDidLoad {
    [super viewDidLoad];
    self.cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    self.cal.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"PDT"];
    [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PDT"]];

    // TODO: refresh on a new day??
    // Check if there is currently a competition (current date is between start and end date)
    PFQuery *competitionQuery = [Competition query];
    [competitionQuery whereKey:@"startDate" lessThanOrEqualTo:[NSDate date]];
    [competitionQuery whereKey:@"endDate" greaterThanOrEqualTo:[NSDate date]];
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

- (void)refreshViewWithStatusInComp:(BOOL)userInComp {
    if (userInComp) {
        // User has already joined current competition
        self.joinPromptLabel.hidden = YES;
        self.joinButton.hidden = YES;
        [self refreshCompetitionStats];
    } else {
        // User hasn't joined current competition
        self.joinPromptLabel.hidden = NO;
        self.joinButton.hidden = NO;
    }
}


- (void)refreshCompetitionStats {
    // Fetch all participants
    PFQuery *participantQuery = [self.currentComp.participantArray query];
    [participantQuery findObjectsInBackgroundWithBlock:^(NSArray<SnapUser*> * _Nullable participants, NSError * _Nullable error) {
        // TODO: optimize
        for (SnapUser *participant in participants) {
            PFQuery *landfillItemsQuery = [participant.trashArray query];
            [landfillItemsQuery whereKey:@"userAction" equalTo:@"landfill"];
            [landfillItemsQuery countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
                NSLog(@"%@ : %i", participant.username, number);
            }];
        }
    }];
}

#pragma mark - Organize competitions

/**
 Make the daily competition.
 TODO: change this to weekly
 TODO: PDT
 */
- (void)makeCompetition {
    Competition *newCompetition = [Competition new];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    newCompetition.startDate = [self.cal startOfDayForDate:[NSDate date]];
    
    // Calculate 24 hours after start date (in seconds)
    int NUM_SECONDS_IN_24_HOURS = 86399;
    newCompetition.endDate = [NSDate dateWithTimeInterval:NUM_SECONDS_IN_24_HOURS sinceDate:newCompetition.startDate];
    
    [newCompetition saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else  {
            self.currentComp = newCompetition;
            [self checkIfUserIsInCurrentComp];
        }
    }];
}


#pragma mark - User Actions
- (IBAction)onJoinTap:(id)sender {
    [self.currentComp.participantArray addObject:[SnapUser currentUser]];
    [self.currentComp saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            // TODO: error
            NSLog(@"%@", error.localizedDescription);
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
