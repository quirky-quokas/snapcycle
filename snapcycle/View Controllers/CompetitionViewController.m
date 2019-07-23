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
@property (strong, nonatomic) NSArray *participantArray;
@property (strong, nonatomic) NSCalendar *cal;

// TODO: remove?
@property (nonatomic) Boolean currComp;

@end

@implementation CompetitionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    self.cal.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"PDT"];
    [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PDT"]];

    // Check if there is currently a competition (current date is between start and end date)
    PFQuery *competitionQuery = [Competition query];
    [competitionQuery whereKey:@"startDate" lessThanOrEqualTo:[NSDate date]];
    [competitionQuery whereKey:@"endDate" greaterThanOrEqualTo:[NSDate date]];
    [competitionQuery getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable competition, NSError * _Nullable error) {
        if (competition) {
            // There is an ongoing competition
            NSLog(@"there is a current competition");
        } else  {
            // No current competition, make one
            NSLog(@"no current competition");
            [self makeCompetition];
        }
    }];
    
    //[self fetchParticipants];
}

/**
 Get participants for current daily competition.
 */
- (void)fetchParticipants {
    PFQuery *query = [PFQuery queryWithClassName:@"Competition"];
    [query whereKey:@"startDate" equalTo:[self.cal startOfDayForDate:[NSDate date]]];

    [query includeKey:@"participantArray"];
    [query includeKey:@"startDate"];
    [query includeKey:@"endDate"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray<SnapUser *> * _Nullable participants, NSError * _Nullable error) {
        if (participants) {
            // Store participant data in participantsArray
            self.participantArray = participants;
            NSLog(@"Success?");
        }
        else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}

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
    newCompetition.endDate = [NSDate dateWithTimeInterval:86399 sinceDate:newCompetition.startDate];
    
    [newCompetition saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
    
    self.currComp = YES;
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
