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
@property (nonatomic) Boolean currComp;

@end

@implementation CompetitionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    self.cal.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"PDT"];
    [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PDT"]];

    
    // start a competition if one is not started
//    if (!self.currComp) {
        [self makeCompetition];
//    }
    
    [self fetchParticipants];
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
 */
- (void)makeCompetition {
    Competition *newCompetition = [Competition new];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PDT"]];
    newCompetition.startDate = [self.cal startOfDayForDate:[NSDate date]];
    
    newCompetition.endDate = [NSDate date];
    
//    NSDateInterval *compDuration = [[NSDateInterval alloc] initWithStartDate:startDate duration:86400];
    
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
