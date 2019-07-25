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

@interface CompetitionManager()

@property (strong, nonatomic) Competition *currentComp;
@property (strong, nonatomic) Competition *previousComp;
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

#pragma mark - Current Competition

// Fetch current daily competition, or create a new one if there is none
- (void)refreshCurrentCompetition {
    // Update today
    // TODO: figure out when to update today
    self.today = [NSDate date];
    
    // Check if there is currently a competition (current date is between start and end date)
    PFQuery *competitionQuery = [Competition query];
    [competitionQuery whereKey:@"startDate" lessThanOrEqualTo:self.today];
    [competitionQuery whereKey:@"endDate" greaterThanOrEqualTo:self.today];
    
    // Also fetch all competitors, including info about users
    [competitionQuery includeKey:@"competitorArray"];
    [competitionQuery includeKey:@"competitorArray.user"];
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
    NSArray<Competitor *> *arrayToShow = NULL;
    
    PFUser *user = [SnapUser currentUser];
    
    for (Competitor *competitor in self.currentComp.competitorArray) {
        if ([competitor.user.username isEqualToString:user.username]) {
            NSLog(@"user in competition");
            arrayToShow = self.currentComp.competitorArray;
            break;
        }
    }
    [self.delegate showCurrentCompetitionView:arrayToShow];
}

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
            [self.delegate showCurrentCompetitionView:NULL];
        }
    }];
}

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
            
            // TODO: get current competitors
            [self.delegate showCurrentCompetitionView:self.currentComp.competitorArray];
        }];
    }];
    
}



@end
