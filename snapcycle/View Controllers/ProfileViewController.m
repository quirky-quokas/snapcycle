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
#import "TabBarController.h"

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;

// Graph
@property (weak, nonatomic) IBOutlet HIChartView *chartView;
@property (strong, nonatomic) HIOptions *options;
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
}

- (void)viewDidAppear:(BOOL)animated {
    [self configurePieChart];
    [self refreshUserActionStats];
}


- (void)refreshUserActionStats {
    // Create dispatch group so that pie chart is only set up after all three queries
    dispatch_group_t queryGroup = dispatch_group_create();
    
    // Query for trash stats for each user action
    // Recycling
    [self countObjectsQueryWithUserAction:@"recycling" dispatchGroup:queryGroup completion:^(int numberOfObjects) {
        self.recyclingItemCount = numberOfObjects;
    }];
    
    // Compost
    [self countObjectsQueryWithUserAction:@"compost" dispatchGroup:queryGroup completion:^(int numberOfObjects) {
        self.compostItemCount = numberOfObjects;
    }];
    
    // Landfill
    [self countObjectsQueryWithUserAction:@"landfill" dispatchGroup:queryGroup completion:^(int numberOfObjects) {
        self.landfillItemCount = numberOfObjects;
    }];
    
    // Set up pie chart once all calls have returned. Pie chart displays total user actions
    dispatch_group_notify(queryGroup, dispatch_get_main_queue(), ^{
        NSLog(@"all completed");
        [self updatePieChartData];
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

- (void)configurePieChart {
    // TODO: looks funky if there is 0 of one type
    NSLog(@"configuring pie chart");
    self.options = [[HIOptions alloc]init];
    HIChart *chart = [[HIChart alloc]init];
    chart.type = @"pie";
    self.options.chart = chart;
    
    // Title
    HITitle *title = [[HITitle alloc]init];
    title.text = @"Total snapcycles";
    self.options.title = title;
    
    // Tooltip
    HITooltip *tooltip = [[HITooltip alloc]init];
    tooltip.pointFormat = @"<b>{point.percentage:.1f}%</b> ({point.y} items)";
    self.options.tooltip = tooltip;
    
    // Plot options
    HIPlotOptions *plotoptions = [[HIPlotOptions alloc]init];
    plotoptions.pie = [[HIPie alloc]init];
    plotoptions.pie.allowPointSelect = [[NSNumber alloc] initWithBool:true];
    plotoptions.pie.cursor = @"pointer";
    self.options.plotOptions = plotoptions;
    
    // Diable credits
    HICredits *credits = [[HICredits alloc] init];
    credits.enabled = [[NSNumber alloc] initWithBool:false];
    self.options.credits = credits;
    
    // Remove exporting hamburger button
    HIExporting *exporting = [[HIExporting alloc] init];
    exporting.enabled = [[NSNumber alloc] initWithBool:false];
    self.options.exporting = exporting;
}

- (void)updatePieChartData {
    NSLog(@"updating pie chart data");
    int itemTotal = self.compostItemCount + self.landfillItemCount + self.recyclingItemCount;
    // TODO: show placeholder if user has no stats
    if (itemTotal != 0) {
        // TODO: configure color
        HIPie *pie = [[HIPie alloc]init];
        pie.data = @[
                     @{
                         @"name": @"Recycling",
                         @"y": @(self.recyclingItemCount),
                         @"color": @"#7db4eb"
                         },
                     @{
                         @"name": @"Compost",
                         @"y": @(self.compostItemCount),
                         @"color": @"#95e47f"
                         },
                     @{
                         @"name": @"Landfill",
                         @"y": @(self.landfillItemCount),
                         @"color": @"#43434b"
                         }
                     ];
        self.options.series = [NSMutableArray arrayWithObjects:pie, nil];
        
        self.chartView.options = self.options;
    }
}

/**
 Sets the user's profile image. If the user does not have a profile image, the default profile image icon is used.
 */
- (void)setProfilePicture {
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
    PFFileObject *imageFile = [SnapUser currentUser].profImage;
    [imageFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
        UIImage *image = [UIImage imageWithData:data];
        self.profileImage.image = image;
    }];
}

/**
 Logs out user
 */
- (IBAction)onLogoutTap:(id)sender {
    // Logout user
    [SnapUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        if (error) {
            [(TabBarController*)self.tabBarController showOKAlertWithTitle:@"Error" message:error.localizedDescription];
            NSLog(@"Error logging out (refactored alert): %@", error.localizedDescription);
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
