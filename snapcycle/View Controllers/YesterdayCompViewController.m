//
//  YesterdayCompViewController.m
//  snapcycle
//
//  Created by emilyabest on 7/30/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import "YesterdayCompViewController.h"
#import "RankingCell.h"

@interface YesterdayCompViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) CompetitionManager *manager;

@property (weak, nonatomic) IBOutlet RankingCell *previousUserRankView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray<Competitor *> * results;

@end

@implementation YesterdayCompViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.manager = [CompetitionManager shared];
    self.manager.previousResultsDisplayer = self;
    
    [self.manager refreshYesterdayCompetition];
}

- (void)showPreviousResults:(NSArray<Competitor *> * _Nullable)sorted {
    // TODO: change
    self.results = sorted;
    
    [self showPreviousWinner:sorted];
    [self showPreviousUserRank:sorted];
}

// Display winner given non-null,sorted array of Competitors
- (void) showPreviousWinner:(NSArray<Competitor*>*)sorted {
    
    // TODO: switch out table view
    [self.tableView reloadData];
}

// Display the user's rank from the previous competition given non-null, sorted array of Competitors
- (void) showPreviousUserRank:(NSArray<Competitor*>*)sorted {
    // Find user in array of competitors
    Competitor *userCompetitor = nil;
    for (Competitor *competitor in sorted) {
        // If we have found the user
        if ([competitor.user.username isEqualToString:[SnapUser currentUser].username]) {
            userCompetitor = competitor;
            break;
        }
    }
    
    if (userCompetitor) {
        // User participated yesterday
        
        // TODO: move over
        [self.previousUserRankView setUpRankingViewForCompetitor:userCompetitor isCurrentUser:YES badgesAwarded:YES];
        self.previousUserRankView.hidden = NO;
        
    } else {
        // User did not participate yesterday
        self.previousUserRankView.hidden = YES;
    }
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    RankingCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"RankingCell" forIndexPath:indexPath];
    [cell setUpRankingViewForCompetitor:self.results[indexPath.row] isCurrentUser:NO badgesAwarded:YES];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.results.count;
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
