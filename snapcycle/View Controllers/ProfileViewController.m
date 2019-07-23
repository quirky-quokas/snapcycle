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
#import "DetailsViewController.h"
#import "RegisterViewController.h"
#import "Trash.h"
#import "PhotoLogCell.h"

@interface ProfileViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *photoCollectionView;

// Graph
@property (weak, nonatomic) IBOutlet HIChartView *chartView;
@property (strong, nonatomic) HIOptions *options;
@property int compostItemCount;
@property int recyclingItemCount;
@property int landfillItemCount;

@property (strong, nonatomic) NSArray *trash;

// Improve
@property (weak, nonatomic) IBOutlet UILabel *landfillCanRecycleLabel;
@property (weak, nonatomic) IBOutlet UILabel *landfillCanCompostLabel;

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
    
    // set collection view data source and delegate
    self.photoCollectionView.delegate = self;
    self.photoCollectionView.dataSource = self;
    
    // fetch trash objects
    [self fetchTrash];
    
    // set up layout for trash photo log
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) self.photoCollectionView.collectionViewLayout;
    layout.minimumInteritemSpacing = 3;
    layout.minimumLineSpacing = 0;
    CGFloat postersPerLine = 3;
    CGFloat itemWidth = (self.photoCollectionView.frame.size.width - layout.minimumLineSpacing * (postersPerLine - 1)) / postersPerLine;
    CGFloat itemHeight = 130;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
}

- (void)viewDidAppear:(BOOL)animated {
    [self configurePieChart];
    [self refreshUserActionStats];
}


- (void)refreshUserActionStats {
    [self updateWaysToImprove];
    
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

- (void)updateWaysToImprove {
    [self updateLandfillCouldHaveRecycled];
    [self updateLandfillCouldHaveComposted];
}

-(void)updateLandfillCouldHaveRecycled {
    // Update landfill could have been recycled
    // Identify recyclable items
    PFQuery *categoryQuery = [Category query];
    [categoryQuery whereKey:@"type" equalTo:@"recycling"];
    
    // Get user's items that they put in the landfill
    PFQuery *trashQuery = [[SnapUser currentUser].trashArray query];
    [trashQuery whereKey:@"userAction" equalTo:@"landfill"];
    
    // Only include items that are in the category of type recycling
    [trashQuery includeKey:@"category"];
    [trashQuery whereKey:@"category" matchesQuery:categoryQuery];
    
    [trashQuery countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
        self.landfillCanRecycleLabel.text = [NSString stringWithFormat:@"- %i items thrown in the landfill that could have been recycled", number];
    }];
}

-(void)updateLandfillCouldHaveComposted {
    // Update compost could have been recycled
    // Identify recyclable items
    PFQuery *categoryQuery = [Category query];
    [categoryQuery whereKey:@"type" equalTo:@"compost"];
    
    // Get user's items that they put in the landfill
    PFQuery *trashQuery = [[SnapUser currentUser].trashArray query];
    [trashQuery whereKey:@"userAction" equalTo:@"landfill"];
    
    // Only include items that are in the category of type recycling
    [trashQuery includeKey:@"category"];
    [trashQuery whereKey:@"category" matchesQuery:categoryQuery];
    
    [trashQuery countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
        self.landfillCanCompostLabel.text = [NSString stringWithFormat:@"- %i items thrown in the landfill that could have been composted", number];
    }];
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

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    
    self.profileImage.image = editedImage;
    SnapUser *currentUser = [SnapUser currentUser];
    CGFloat imageWidth = editedImage.size.width/2;
    CGFloat imageHeight = editedImage.size.height/2;
    CGSize size = CGSizeMake(imageWidth, imageHeight);
    UIImage *resizedImage = [DetailsViewController imageWithImage:editedImage scaledToFillSize:size];
    currentUser.profImage = [RegisterViewController getPFFileFromImage:resizedImage];
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            NSString *title = @"Could not upload photo";
            NSString *message = @"Please try again";
            [(TabBarController*) self.tabBarController showOKAlertWithTitle:title message:message];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (IBAction)onTapEditPic:(id)sender {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    [self presentViewController:imagePickerVC animated:YES completion:nil];
    
}

- (void) fetchTrash {
    PFQuery *photoQuery = [[SnapUser currentUser].trashArray query];
    [photoQuery orderByDescending:@"createdAt"];
    [photoQuery findObjectsInBackgroundWithBlock:^(NSArray<Trash *> * _Nullable trash, NSError * _Nullable error) {
        if (trash) {
            self.trash = trash;
            [self.photoCollectionView reloadData];
        }
        else {
            NSLog(@"%@", error.localizedDescription);
            [self fetchTrash];
        }
    }];
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.trash.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoLogCell *cell = [self.photoCollectionView dequeueReusableCellWithReuseIdentifier:@"PhotoLogCell" forIndexPath:indexPath];
    Trash *trash = self.trash[indexPath.item];
    
    [cell setPhotoLogCell:trash];
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
