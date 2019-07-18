//
//  ProfileViewController.m
//  snapcycle
//
//  Created by emilyabest on 7/16/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import "ProfileViewController.h"
#import "Parse/Parse.h"
#import "AppDelegate.h"
#import "SnapUser.h"
#import "LoginViewController.h"
#import <Highcharts/Highcharts.h>
#import <UIKit/UIKit.h>
#import "Category.h"

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (weak, nonatomic) IBOutlet UILabel *recyclingStatsLabel;
@property (weak, nonatomic) IBOutlet UILabel *compostStatsLabel;
@property (weak, nonatomic) IBOutlet UILabel *landfillStatsLabel;

// Graph
@property (weak, nonatomic) IBOutlet HIChartView *chartView;
@property int compostItemCount;
@property int recyclingItemCount;
@property int landfillItemCount;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set the scrollView frame
    self.scrollView.contentSize = CGSizeMake(375, 1300);
    
    // set the profile picture
    [self setProfilePicture];
    
    // set the welcome text
    self.welcomeLabel.text = [NSString stringWithFormat:@"Welcome %@!", PFUser.currentUser.username];
    
    // Create dispatch group so that pie chart is only set up after all three queries
    dispatch_group_t queryGroup = dispatch_group_create();
    
    // Query for trash stats for each user action
    // Recycling
    [self countObjectsQueryWithUserAction:@"recycling" dispatchGroup:queryGroup completion:^(int numberOfObjects) {
        self.recyclingItemCount = numberOfObjects;
        self.recyclingStatsLabel.text = [NSString stringWithFormat:@"recycling: %i items", self.recyclingItemCount];
    }];
    
    // Compost
    [self countObjectsQueryWithUserAction:@"compost" dispatchGroup:queryGroup completion:^(int numberOfObjects) {
        self.compostItemCount = numberOfObjects;
        self.compostStatsLabel.text = [NSString stringWithFormat:@"compost: %i items", self.compostItemCount];
    }];
    
    // Landfill
    [self countObjectsQueryWithUserAction:@"landfill" dispatchGroup:queryGroup completion:^(int numberOfObjects) {
        self.landfillItemCount = numberOfObjects;
        self.landfillStatsLabel.text = [NSString stringWithFormat:@"landfill: %i items", self.landfillItemCount];
    }];

    // Set up pie chart once all calls have returned. Pie chart displays total user actions
    dispatch_group_notify(queryGroup, dispatch_get_main_queue(), ^{
        NSLog(@"all completed");
        [self setUpPieChart];
    });
}

// Count objects for the specified user action (how the user disposed of the trash regardless of what they wre supposed to do.
- (void)countObjectsQueryWithUserAction:(NSString*)userAction dispatchGroup:(dispatch_group_t)group completion:(void (^)(int numberOfObjects))setActionCount {
    // Query for trash objects in user's array that match action
    PFQuery *trashQuery = [[SnapUser currentUser].trashArray query];
    [trashQuery whereKey:@"userAction" equalTo:userAction];
    
    dispatch_group_enter(group);
    [trashQuery countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
        // TODO: if there is an error
        setActionCount(number);
        dispatch_group_leave(group);
    }];
}

- (void)setUpPieChart {
    int itemTotal = self.compostItemCount + self.landfillItemCount + self.recyclingItemCount;
    // TODO: show placeholder if user has no stats
    if (itemTotal != 0) {
        // Configure chart options
        HIOptions *options = [[HIOptions alloc]init];
        HIChart *chart = [[HIChart alloc]init];
        chart.type = @"pie";
        options.chart = chart;
        
        // Title
        HITitle *title = [[HITitle alloc]init];
        title.text = @"Your snapcycles";
        options.title = title;
        
        // Tooltip
        HITooltip *tooltip = [[HITooltip alloc]init];
        tooltip.pointFormat = @"<b>{point.percentage:.1f}%</b>";
        options.tooltip = tooltip;
        
        // Plot options
        HIPlotOptions *plotoptions = [[HIPlotOptions alloc]init];
        plotoptions.pie = [[HIPie alloc]init];
        plotoptions.pie.allowPointSelect = [[NSNumber alloc] initWithBool:true];
        plotoptions.pie.cursor = @"pointer";
        options.plotOptions = plotoptions;
        
        // Diable credits
        HICredits *credits = [[HICredits alloc] init];
        credits.enabled = [[NSNumber alloc] initWithBool:false];
        options.credits = credits;
        
        // Remove exporting hamburger button
        HIExporting *exporting = [[HIExporting alloc] init];
        exporting.enabled = [[NSNumber alloc] initWithBool:false];
        options.exporting = exporting;
        
        // Data
        // TODO: configure color
        HIPie *pie = [[HIPie alloc]init];
        double doubleTotal = (double)itemTotal; // avoid losing precision
        pie.data = @[
                     @{
                         @"name": @"Recycling",
                         @"y": @(self.recyclingItemCount/doubleTotal),
                         @"color": @"#7db4eb"
                         },
                     @{
                         @"name": @"Compost",
                         @"y": @(self.compostItemCount/doubleTotal),
                         @"color": @"#95e47f"
                         },
                     @{
                         @"name": @"Trash",
                         @"y": @(self.landfillItemCount/doubleTotal),
                         @"color": @"#43434b"
                         }
                     ];
        options.series = [NSMutableArray arrayWithObjects:pie, nil];
        
        self.chartView.options = options;
    }
    
}

/**
 Sets the user's profile image. If the user does not have a profile image, the default profile image icon is used.
 */
- (void)setProfilePicture {
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
    PFFileObject *imageFile = [SnapUser currentUser].profImage;
    UIImage *image = [UIImage imageWithData:imageFile.getData];
    self.profileImage.image = image;
}

/**
 Logs out user
 */
- (IBAction)onLogoutTap:(id)sender {
    // Logout user
    [SnapUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        if (error) {
            UIAlertController *alert = [LoginViewController createErrorAlertWithOKAndMessage:error.localizedDescription];
            [self presentViewController:alert animated:YES completion:nil];
            NSLog(@"Error logging out: %@", error.localizedDescription);
        } else {
            // Return to login screen
            // Get single instance of app delegate
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            
            // Create new instance of storyboard, starting from login screen
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UINavigationController *loginNavigationController = [storyboard instantiateInitialViewController];
            
            // Set root view controller to switch views
            appDelegate.window.rootViewController = loginNavigationController;
            NSLog(@"Logout successful");
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
