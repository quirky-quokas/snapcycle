//
//  TodayCompViewController.m
//  snapcycle
//
//  Created by emilyabest on 7/30/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import "TodayCompViewController.h"
#import "Competition.h"
#import "SnapUser.h"
#import "Competitor.h"
#import "RankingCell.h"

@interface TodayCompViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *joinPromptLabel;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;

@property (strong, nonatomic) CompetitionManager *manager;

@property (strong, nonatomic) NSArray<Competitor*> *currentStats;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet RankingCell *currentUserRankView;

@end

@implementation TodayCompViewController

@synthesize userScoreChanged;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.manager = [CompetitionManager shared];
    self.manager.currentCompetitionDisplayer = self;
    
    // Will call back self to update view
    [self.manager refreshCurrentCompetition];
}

// TODO: pull to refresh instead
- (void)viewDidAppear:(BOOL)animated {
    if (userScoreChanged) {
        // TODO: only regrab stats array?
        // Will call back self to update view
        [self.manager refreshCurrentCompetition];
        self.userScoreChanged = NO;
    }
}

#pragma mark - Current Competition

// Passed an array of Competitors sorted in ascending order by score
// If array is null, then the user is not in the compeition and the join screen should be displayed instead
- (void)showCurrentCompetitionView:(NSArray<Competitor*>* _Nullable)sorted {
    if (sorted) {
        [self showCompetitionStats:sorted];
    }
}

- (void)showCompetitionStats:(NSArray<Competitor*>*)sorted {
    // Get users and rank, get scores
    BOOL userInComp = NO;
    
    int rank = 0;
    NSNumber *prevUserItems = @(-1);
    for (Competitor* competitor in sorted) {
        NSNumber *userItems = competitor.score;
        
        // Check for ties. Rank should only increase if the current user has a different score than the
        // previous user since the users are sorted
        if (![prevUserItems isEqualToNumber:userItems]) {
            rank++;
        }
        
        competitor.rank = @(rank);
        
        // Show current callout
        if ([competitor.user.username isEqualToString:SnapUser.currentUser.username]) {
            userInComp = YES;
            self.joinPromptLabel.hidden = YES;
            self.joinButton.hidden = YES;
            self.currentUserRankView.hidden = NO;
            [self.currentUserRankView setUpRankingViewForCompetitor:competitor isCurrentUser:YES badgesAwarded:NO];
            
            
            
        }
        
        // Update prevUserItems for next iteration of loop
        prevUserItems = userItems;
    }
    
    if (!userInComp) {
        self.joinPromptLabel.hidden = NO;
        self.joinButton.hidden = NO;
        self.currentUserRankView.hidden = YES;
    }
    
    self.currentStats = sorted;
    [self.tableView reloadData];
}


- (IBAction)onJoinTap:(id)sender {
    [self.manager addUserToCurrentCompetition];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.currentStats.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RankingCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"RankingCell" forIndexPath:indexPath];
    [cell setUpRankingViewForCompetitor:self.currentStats[indexPath.row] isCurrentUser:NO badgesAwarded:NO];
    return cell;
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
