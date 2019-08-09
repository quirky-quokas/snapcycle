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
#import "TabBarController.h"

@interface TodayCompViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *joinPromptLabel;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;

@property (strong, nonatomic) CompetitionManager *manager;

@property (strong, nonatomic) NSArray<Competitor*> *currentStats;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (weak, nonatomic) IBOutlet UILabel *competitionDescriptionLabel;
@property (weak, nonatomic) IBOutlet RankingCell *currentUserRankView;
@property (weak, nonatomic) IBOutlet UIView *joinCompView;

// Error handling
@property BOOL errorPresentedOnThisAppear;

@end

@implementation TodayCompViewController

@synthesize userScoreChanged;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.errorPresentedOnThisAppear = NO;
    
    // Set up Table View
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // Set up Competition Manager
    self.manager = [CompetitionManager shared];
    self.manager.currentCompetitionDisplayer = self;
    
    // Set up refresh control
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self.manager action:@selector(refreshCurrentCompetition) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    // Will call back self to update view
    [self.manager refreshCurrentCompetition];
}

// TODO: pull to refresh instead
- (void)viewDidAppear:(BOOL)animated {
    self.errorPresentedOnThisAppear = NO;
    
    if (userScoreChanged) {
        // TODO: only regrab stats array?
        // Will call back self to update view
        [self.manager refreshCurrentCompetition];
        self.userScoreChanged = NO;
    }
}

#pragma mark - Current Competition

// Passed an array of Competitors sorted in ascending order by score
- (void)showCurrentCompetitionView:(NSArray<Competitor*>* _Nullable)sorted {
    [self.refreshControl endRefreshing];
    BOOL userInComp = NO;
    
    // Get users and rank, get scores
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
        
        // Show current callout if this is the current user
        if ([competitor.user.username isEqualToString:SnapUser.currentUser.username]) {
            userInComp = YES;
            [self showUserIsCompetitor:competitor];
        }
        
        // Update prevUserItems for next iteration of loop
        prevUserItems = userItems;
    }
    
    if (!userInComp) {
        [self showJoinPrompt];
    }
    
    self.currentStats = sorted;
    [self.tableView reloadData];
}

// User is in the competition, show callout
- (void)showUserIsCompetitor:(Competitor*)user {
    self.competitionDescriptionLabel.hidden = NO;
    self.joinCompView.hidden = YES;
    self.currentUserRankView.hidden = NO;
    [self.currentUserRankView setUpRankingViewForCompetitor:user isCurrentUser:YES badgesAwarded:YES];
}

// User is not in the competition, show join label instead
- (void)showJoinPrompt {
    // TODO: modify
    self.competitionDescriptionLabel.hidden = YES;
    self.joinPromptLabel.hidden = NO;
    self.joinButton.hidden = NO;
    self.currentUserRankView.hidden = YES;
}

- (IBAction)onJoinTap:(id)sender {
    [self.manager addUserToCurrentCompetition];
}

#pragma mark - Rankings table view

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.currentStats.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RankingCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"RankingCell" forIndexPath:indexPath];
    [cell setUpRankingViewForCompetitor:self.currentStats[indexPath.row] isCurrentUser:NO badgesAwarded:YES];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Live Rankings";
}

#pragma mark - Errors
- (void) showError:(NSError*)error {
    if (!self.errorPresentedOnThisAppear) {
        self.errorPresentedOnThisAppear = YES;
        [(TabBarController*)self.tabBarController showOKAlertWithTitle:@"Error loading competitions" message:error.localizedDescription];
    }
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
