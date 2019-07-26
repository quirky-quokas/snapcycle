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

// Leaderboard chart
@property (weak, nonatomic) IBOutlet HIChartView *leaderboardChart;
@property (strong, nonatomic) HIOptions *options;
@property (weak, nonatomic) IBOutlet UILabel *joinPromptLabel;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;

@property (weak, nonatomic) IBOutlet UILabel *previousWinnerLabel;
@property (weak, nonatomic) IBOutlet UILabel *previousUserRankLabel;

@property (strong, nonatomic) CompetitionManager *manager;

@end

@implementation CompetitionViewController

@synthesize userScoreChanged;

#pragma mark - Load and refresh views
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.manager = [CompetitionManager shared];
    self.manager.delegate = self;
    
    [self configureLeaderboardChart];
    
    // Will call back self to update view
    [self.manager refreshCurrentCompetition];
    [self.manager refreshYesterdayCompetition];
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
        // User is in current competition
        self.joinPromptLabel.hidden = YES;
        self.joinButton.hidden = YES;
        
        [self showCompetitionStats:sorted];
    } else {
        // User is not in current competition
        self.joinPromptLabel.hidden = NO;
        self.joinButton.hidden = NO;
        self.leaderboardChart.hidden = YES;
    }
}

- (void)configureLeaderboardChart {
    HIChart *chart = [[HIChart alloc]init];
    chart.type = @"bar";
    
    HITitle *title = [[HITitle alloc]init];
    title.text = @"Daily Competition Leaderboard";
    
    HISubtitle *subtitle = [[HISubtitle alloc]init];
    subtitle.text = @"Least number of items thrown in the landfill today";
    
    HITooltip *tooltip = [[HITooltip alloc]init];
    tooltip.valueSuffix = @" items";
    
    HIPlotOptions *plotOptions = [[HIPlotOptions alloc]init];
    plotOptions.bar = [[HIBar alloc]init];
    
    HICredits *credits = [[HICredits alloc]init];
    credits.enabled = [[NSNumber alloc] initWithBool:false];
    
    HIExporting *exporting = [[HIExporting alloc] init];
    exporting.enabled = [[NSNumber alloc] initWithBool:false];
    
    HIYAxis *yaxis = [[HIYAxis alloc]init];
    yaxis.min = @0;
    yaxis.title = [[HITitle alloc]init];
    yaxis.title.text = @"Items in landfill";
    yaxis.title.align = @"high";
    
    self.options = [[HIOptions alloc]init];
    self.options.chart = chart;
    self.options.title = title;
    self.options.subtitle = subtitle;
    self.options.yAxis = [NSMutableArray arrayWithObjects:yaxis, nil];
    self.options.tooltip = tooltip;
    self.options.plotOptions = plotOptions;
    self.options.credits = credits;
    self.options.exporting = exporting;
}

// Load leaderboard
- (void)showCompetitionStats:(NSArray<Competitor*>*)sorted {
    // Get users and rank, get scores
    NSMutableArray<NSString*> *rankedUsernames = [[NSMutableArray alloc] init];
    NSMutableArray<NSNumber*> *itemsInLandfill = [[NSMutableArray alloc] init];
    
    int rank = 0;
    NSNumber *prevUserItems = @(-1);
    for (Competitor* competitor in sorted) {
        NSNumber *userItems = competitor.score;
        
        // Check for ties. Rank should only increase if the current user has a different score than the
        // previous user since the users are sorted
        if (![prevUserItems isEqualToNumber:userItems]) {
            rank++;
        }
        
        [rankedUsernames addObject:[NSString stringWithFormat:@"#%i. %@", rank, competitor.user.username]];
        [itemsInLandfill addObject:competitor.score];
        
        // Update prevUserItems for next iteration of loop
        prevUserItems = userItems;
    }
    
    HIXAxis * xaxis = [[HIXAxis alloc]init];
    xaxis.categories = rankedUsernames;
    xaxis.labels = [[HILabels alloc] init];
    xaxis.labels.align = @"left";
    xaxis.labels.reserveSpace = [[NSNumber alloc] initWithBool:true];
    
    // TODO: configure color
    HIBar *bar1 = [[HIBar alloc]init];
    bar1.name = @"Landfill";
    bar1.showInLegend = [[NSNumber alloc] initWithBool:false];
    bar1.data = itemsInLandfill;
    
    self.options.xAxis = [NSMutableArray arrayWithObjects:xaxis, nil];
    self.options.series = [NSMutableArray arrayWithObjects:bar1, nil];
    self.leaderboardChart.options = self.options;
    self.leaderboardChart.hidden = NO;
}

#pragma mark - Previous Competition Results

- (void)showPreviousResults:(NSArray<Competitor*>* _Nullable)sorted {
    if (sorted) {
        [self showPreviousWinner:sorted];
        [self showPreviousUserRank:sorted];
    } else {
        self.previousUserRankLabel.hidden = YES;
        self.previousWinnerLabel.text = @"No competition yesterday.";
    }
}

// Display winner given non-null,sorted array of Competitors
- (void) showPreviousWinner:(NSArray<Competitor*>*)sorted {
    NSMutableString *results = [NSMutableString stringWithString:@"Winner(s): "];
    [results appendString: sorted[0].user.username];
    
    int i = 1;
    while (i < sorted.count && [sorted[i].rank isEqualToNumber:@(1)]) {
        [results appendFormat:@", %@", sorted[i].user.username];
        i++;
    }
    
    [results appendFormat:@" with %@ items in the landfill", sorted[0].score];
    self.previousWinnerLabel.text = results;
}

// Display the user's rank from the previous competition given non-null, sorted array of Competitors
- (void) showPreviousUserRank:(NSArray<Competitor*>*)sorted {
    // Find user in array of competitors
    Competitor *userCompetitor = NULL;
    for (Competitor *competitor in sorted) {
        // If we have found the user
        if ([competitor.user.username isEqualToString:[SnapUser currentUser].username]) {
            userCompetitor = competitor;
            break;
        }
    }
    
    if (userCompetitor) {
        // User participated yesterday
        if ([userCompetitor.rank isEqualToNumber:@(1)]) {
            self.previousUserRankLabel.text = @"Congrats, you're a winner! Thanks for snapcycling!";
        } else {
            self.previousUserRankLabel.text = [NSString stringWithFormat:@"You ranked #%@ with %@ items in the landfill. Thanks for snapcycling!", userCompetitor.rank, userCompetitor.score];
        }
        self.previousUserRankLabel.hidden = NO;
    } else {
        // User did not participate yesterday
        self.previousUserRankLabel.hidden = YES;
    }
}

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
