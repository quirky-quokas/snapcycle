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

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (weak, nonatomic) IBOutlet UILabel *recyclingStatsLabel;
@property (weak, nonatomic) IBOutlet UILabel *compostStatsLabel;
@property (weak, nonatomic) IBOutlet UILabel *landfillStatsLabel;

// Graph
@property (weak, nonatomic) IBOutlet HIChartView *chartView;
@property NSUInteger compostItemCount;
@property NSUInteger recyclingItemCount;
@property NSUInteger landfillItemCount;

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
    
    // TODO: display a graph of their three trash piles
    // temporarily display stats: how many of each type of disposal
    SnapUser *user = [SnapUser currentUser];
    PFQuery *recyclingQuery = [user.trashArray query];
    [recyclingQuery whereKey:@"type" equalTo:@"recycling"];
    [recyclingQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        // TODO: if there are no objects or error
        self.recyclingItemCount = [objects count];
        self.recyclingStatsLabel.text = [NSString stringWithFormat:@"recycling: %ld items", self.recyclingItemCount];;
    }];
    
    PFQuery *landfillQuery = [user.trashArray query];
    [landfillQuery whereKey:@"type" equalTo:@"landfill"];
    [landfillQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects) {
            self.landfillItemCount = [objects count];
            self.landfillStatsLabel.text = [NSString stringWithFormat:@"landfill: %ld items", self.landfillItemCount];
            [self setUpPieChart];
        }
    }];
    
    PFQuery *compostQuery = [user.trashArray query];
    [compostQuery whereKey:@"type" equalTo:@"compost"];
    [compostQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects) {
            self.compostItemCount = [objects count];
            self.compostStatsLabel.text = [NSString stringWithFormat:@"compost: %ld items", self.compostItemCount];
        }
    }];

    // TODO: figure out when to call set up pie chart!!
}

- (void)setUpPieChart {
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
    double itemTotal = (double)(self.compostItemCount + self.landfillItemCount + self.recyclingItemCount);
    NSLog(@"%f", itemTotal);
    HIPie *pie = [[HIPie alloc]init];
    pie.data = @[
                 @{
                     @"name": @"Recycling",
                     @"y": @(self.recyclingItemCount/itemTotal),
                     //@"color": @"#0000FF"
                     },
                 @{
                     @"name": @"Compost",
                     @"y": @(self.compostItemCount/itemTotal),
                     @"color": @"#00FF00"
                     },
                 @{
                     @"name": @"Trash",
                     @"y": @(self.landfillItemCount/itemTotal),
                     @"color": @"#808080"
                     }
                 ];
    options.series = [NSMutableArray arrayWithObjects:pie, nil];
    
    self.chartView.options = options;
    
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
