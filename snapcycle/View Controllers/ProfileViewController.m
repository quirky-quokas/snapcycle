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
#import "MKDropdownMenu.h"
#import "DateTools.h"
#import "PhotoPopUpViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "CompetitionManager.h"
#import "TutorialViewController.h"

@interface ProfileViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, MKDropdownMenuDelegate, MKDropdownMenuDataSource, UIGestureRecognizerDelegate, CLLocationManagerDelegate>

// Overall
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

// User info
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backdropImageView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UIView *profileImageBorder;
@property (strong, nonatomic) UIImagePickerController *imagePickerVC;

// Sound
@property (weak, nonatomic) IBOutlet UIButton *soundButton;

// Badges
@property (weak, nonatomic) IBOutlet UILabel *numFirstLabel;
@property (weak, nonatomic) IBOutlet UILabel *numSecondLabel;
@property (weak, nonatomic) IBOutlet UILabel *numThirdLabel;

// Location
@property (weak, nonatomic) IBOutlet UIImageView *pinImageView;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLGeocoder *geocoder;

// Pie Chart
@property (weak, nonatomic) IBOutlet HIChartView *pieChartView;
@property (strong, nonatomic) HIOptions *pieChartOptions;
@property int compostItemCount;
@property int recyclingItemCount;
@property int landfillItemCount;
@property (weak, nonatomic) IBOutlet UILabel *noStatsYetLabel;

// Accuracy chart bar graph
@property (strong, nonatomic) NSCalendar *cal;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (weak, nonatomic) IBOutlet HIChartView *accuracyChartView;
@property (strong, nonatomic) HIOptions *accuracyOptions;
@property (strong, nonatomic) NSMutableDictionary<NSNumber*, NSString*> *labelForDay;
@property (strong, nonatomic) NSMutableDictionary<NSNumber*, NSNumber*> *percentageForDay;

// Photo Log
@property (weak, nonatomic) IBOutlet UICollectionView *photoCollectionView;

// Dropdown menu
@property (weak, nonatomic) IBOutlet MKDropdownMenu *photoDropdownMenu;
@property (strong, nonatomic) NSArray *trash;
@property (strong, nonatomic) NSArray *dropdownData;

@end

@implementation ProfileViewController

#pragma mark - Loading and Configuration

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set the navigation bar font
    [TabBarController setSnapcycleLogoTitleForNavigationController:self.navigationController];
    
    // set the scrollView frame
    self.scrollView.contentSize = CGSizeMake(375, 1975);
    
    // set the profile picture
    [self setProfilePicture];
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editProfilePicture:)];
    [self.profileImage addGestureRecognizer:tapGR];
    
    // set profile image pickers
    self.imagePickerVC = [UIImagePickerController new];
    self.imagePickerVC.delegate = self;
    self.imagePickerVC.allowsEditing = YES;
    
    [self setUpSoundButton];
    
    // set the welcome text
    self.welcomeLabel.text = [NSString stringWithFormat:@"Welcome %@!", PFUser.currentUser.username];
    
    // set up Location Manager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    self.geocoder = [[CLGeocoder alloc] init];
    [self.locationManager startUpdatingLocation];
    
    // set drop down menu data source and delegate
    self.photoDropdownMenu.dataSource = self;
    self.photoDropdownMenu.delegate = self;
    self.dropdownData = @[@"Past day", @"Past week", @"Past month", @"Past 6 months", @"Past year", @"All"];
    self.photoDropdownMenu.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.photoDropdownMenu.layer.borderWidth = 1.0f;
    
    // set collection view data source and delegate
    self.photoCollectionView.delegate = self;
    self.photoCollectionView.dataSource = self;
    
    // set up layout for trash photo log
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) self.photoCollectionView.collectionViewLayout;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 5;
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    CGFloat photosPerLine = 2.5;
    CGFloat itemWidth = (self.photoCollectionView.frame.size.width - layout.minimumLineSpacing * (photosPerLine - 1)) / photosPerLine;
    CGFloat itemHeight = 200;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    
    [self configurePieChart];
    [self configureAccuracyChart];
}

- (void)viewDidAppear:(BOOL)animated {
    // TODO: make prettier. Do want to always refresh?
    // set the badges label
    Badges *badges = SnapUser.currentUser.badges;
    [badges fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        self.numFirstLabel.text = [NSString stringWithFormat:@"%@", badges.numFirstPlace];
        self.numSecondLabel.text = [NSString stringWithFormat:@"%@", badges.numSecondPlace];
        self.numThirdLabel.text = [NSString stringWithFormat:@"%@", badges.numThirdPlace];;
    }];
    
    // Fetch stats for graphs
    [self refreshUserActionStats];
    [self refreshUserAccuracyStats];
    
    // Fetch all trash for photo log
    [self fetchTrash:@"All"];
}

#pragma mark - Sound toggle
- (IBAction)onSoundTap:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL soundOff = [defaults boolForKey:@"soundOff"];
    
    // TODO: change images?
    if (soundOff) {
        // turn sound on
        [defaults setBool:NO forKey:@"soundOff"];
        [self.soundButton setImage:[UIImage imageNamed:@"sound-on"] forState:UIControlStateNormal];
    } else {
        // turn sound off
        [defaults setBool:YES forKey:@"soundOff"];
        [self.soundButton setImage:[UIImage imageNamed:@"sound-off"] forState:UIControlStateNormal];
    }
}

- (void)setUpSoundButton {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL soundOff = [defaults boolForKey:@"soundOff"];
    
    // TODO: change images?
    if (soundOff) {
        [self.soundButton setImage:[UIImage imageNamed:@"sound-off"] forState:UIControlStateNormal];
    } else {
        [self.soundButton setImage:[UIImage imageNamed:@"sound-on"] forState:UIControlStateNormal];
    }
}

#pragma mark - Profile Picture

/**
 Sets the user's profile image. If the user does not have a profile image, the default profile image icon is used.
 */
- (void)setProfilePicture {
    self.profileImageBorder.layer.cornerRadius = self.profileImageBorder.frame.size.width / 2;
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
    PFFileObject *imageFile = [SnapUser currentUser].profImage;
    [imageFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
        UIImage *image = [UIImage imageWithData:data];
        self.profileImage.image = image;
        
    }];
}

- (IBAction)onEditProfileTap:(id)sender {
    [self editProfilePicture:nil];
}

/**
 Edits the user's profile image.
 */
- (void)editProfilePicture: (UITapGestureRecognizer *)tapGR {
    // Let user choose source if both are available
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        // Both image source types are available
        [self pickImageWithSourceSelection];
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        // Only camera is available
        [self pickImageWithCamera];
    } else {
        // Only photo library is available
        [self pickImageWithPhotoLibrary];
    }
}

// Allow user to choose source
- (void) pickImageWithSourceSelection {
    // Create alert controller with actions
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: nil
                                                                              message: nil
                                                                       preferredStyle: UIAlertControllerStyleActionSheet];
    // Take photo
    [alertController addAction: [UIAlertAction actionWithTitle: @"Take Photo" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self pickImageWithCamera];
    }]];
    
    // Choose existing photo
    [alertController addAction: [UIAlertAction actionWithTitle: @"Choose Existing Photo" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self pickImageWithPhotoLibrary];
    }]];
    
    // Cancel
    [alertController addAction: [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    // Present as modal popover
    alertController.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController: alertController animated: YES completion: nil];
}

// Present camera
- (void) pickImageWithCamera {
    self.imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:self.imagePickerVC animated:YES completion:nil];
}

// Present photo library
- (void) pickImageWithPhotoLibrary {
    self.imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:self.imagePickerVC animated:YES completion:nil];
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    
    self.profileImage.image = editedImage;
    SnapUser *currentUser = [SnapUser currentUser];
    
    // Scale photo down
    CGFloat imageWidth = editedImage.size.width / 3;
    CGFloat imageHeight = editedImage.size.height / 3;
    CGSize size = CGSizeMake(imageWidth, imageHeight);
    UIImage *resizedImage = [DetailsViewController imageWithImage:editedImage scaledToFillSize:size];
    
    currentUser.profImage = [RegisterViewController getPFFileFromImage:resizedImage];
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            NSString *title = @"Could not upload photo";
            NSString *message = @"Please try again";
            [(TabBarController*) self.tabBarController showOKAlertWithTitle:title message:message];
        }
        
        // TODO: move this out? a litte hacky.
        // Refresh competitions to fetch new profile pic
        CompetitionManager *manager = [CompetitionManager shared];
        manager.currentCompetitionDisplayer.userScoreChanged = YES;
        [manager refreshYesterdayCompetition];
        
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    self.locationLabel.text = @"North Pole";
    NSLog(@"didFailWithError: %@", error);
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    [self.geocoder reverseGeocodeLocation:[locations lastObject] completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = [placemarks lastObject];
        
        NSString *city = placemark.locality;
        NSString *state = placemark.administrativeArea;
        NSString *country = placemark.ISOcountryCode;
        
        self.locationLabel.text = [NSString stringWithFormat:@"%@, %@, %@",city,state,country];
        
        [self.locationManager stopUpdatingLocation];
        
        // TODO: in theory, change what categories we pull based on the user's location
    }];
}

#pragma mark - Pie chart

- (void)configurePieChart {
    // TODO: looks funky if there is 0 of one type
    NSLog(@"configuring pie chart");
    self.pieChartOptions = [[HIOptions alloc]init];
    HIChart *chart = [[HIChart alloc]init];
    chart.type = @"pie";
    self.pieChartOptions.chart = chart;
    
    // Title
    HITitle *title = [[HITitle alloc]init];
    title.text = @"Total snapcycles";
    self.pieChartOptions.title = title;
    
    // Tooltip
    HITooltip *tooltip = [[HITooltip alloc]init];
    tooltip.pointFormat = @"<b>{point.percentage:.1f}%</b> ({point.y} items)";
    self.pieChartOptions.tooltip = tooltip;
    
    // Plot options
    HIPlotOptions *plotoptions = [[HIPlotOptions alloc]init];
    plotoptions.pie = [[HIPie alloc]init];
    plotoptions.pie.allowPointSelect = [[NSNumber alloc] initWithBool:true];
    plotoptions.pie.cursor = @"pointer";
    self.pieChartOptions.plotOptions = plotoptions;
    
    // Diable credits
    HICredits *credits = [[HICredits alloc] init];
    credits.enabled = [[NSNumber alloc] initWithBool:false];
    self.pieChartOptions.credits = credits;
    
    // Remove exporting hamburger button
    HIExporting *exporting = [[HIExporting alloc] init];
    exporting.enabled = [[NSNumber alloc] initWithBool:false];
    self.pieChartOptions.exporting = exporting;
}

- (void)updatePieChartData {
    NSLog(@"updating pie chart data");
    int itemTotal = self.compostItemCount + self.landfillItemCount + self.recyclingItemCount;
    // TODO: show placeholder if user has no stats
    if (itemTotal != 0) {
        self.noStatsYetLabel.hidden = YES;
        HIPie *pie = [[HIPie alloc]init];
        pie.data = @[
                     @{
                         @"name": @"Recycling",
                         @"y": @(self.recyclingItemCount),
                         @"color": @"#0070c2"
                         },
                     @{
                         @"name": @"Compost",
                         @"y": @(self.compostItemCount),
                         @"color": @"#94c83d"
                         },
                     @{
                         @"name": @"Landfill",
                         @"y": @(self.landfillItemCount),
                         @"color": @"#964b00"
                         }
                     ];
        self.pieChartOptions.series = [NSMutableArray arrayWithObjects:pie, nil];
        
        self.pieChartView.options = self.pieChartOptions;
    } else {
        self.noStatsYetLabel.hidden = NO;
    }
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


#pragma mark - Accuracy chart
- (void)configureAccuracyChart {
    self.cal = [NSCalendar currentCalendar];
    [self.cal setTimeZone:[NSTimeZone systemTimeZone]];
    [self.cal setFirstWeekday:1]; // Sunday
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"EEE M/d"];
    
    HIChart *chart = [[HIChart alloc]init];
    chart.type = @"column";
    
    HITitle *title = [[HITitle alloc]init];
    title.text = @"Your accuracy this week";
    
    HISubtitle *subtitle = [[HISubtitle alloc]init];
    subtitle.text = @"% of items disposed correctly";
    
    HIYAxis *yaxis = [[HIYAxis alloc]init];
    yaxis.min = @0;
    yaxis.max = @100;
    yaxis.tickInterval = @20;
    yaxis.title = [[HITitle alloc]init];
    yaxis.title.text = @"% accuracy";
    
    HITooltip *tooltip = [[HITooltip alloc]init];
    tooltip.pointFormat = @"{point.y:.1f}% accurate";
    
    HIPlotOptions *plotOptions = [[HIPlotOptions alloc]init];
    plotOptions.column = [[HIColumn alloc]init];
    //plotOptions.column.pointPadding = @0.2;
    plotOptions.column.borderWidth = @0;
    
    HICredits *credits = [[HICredits alloc]init];
    credits.enabled = [[NSNumber alloc] initWithBool:false];
    
    HIExporting *exporting = [[HIExporting alloc] init];
    exporting.enabled = [[NSNumber alloc] initWithBool:false];
    
    self.accuracyOptions = [[HIOptions alloc] init];
    self.accuracyOptions.chart = chart;
    self.accuracyOptions.title = title;
    self.accuracyOptions.subtitle = subtitle;
    self.accuracyOptions.yAxis = [NSMutableArray arrayWithObject:yaxis];
    self.accuracyOptions.tooltip = tooltip;
    self.accuracyOptions.plotOptions = plotOptions;
    self.accuracyOptions.credits = credits;
    self.accuracyOptions.exporting = exporting;
    
    self.accuracyChartView.options = self.accuracyOptions;
}

- (void)refreshUserAccuracyStats {
    // Reset data
    self.percentageForDay = [[NSMutableDictionary alloc] init];
    self.labelForDay = [[NSMutableDictionary alloc] init];
    
    // Get sunday of week
    NSDate *now = [NSDate date];
    NSDate *startOfDay;
    [self.cal rangeOfUnit:NSCalendarUnitWeekOfMonth  // find start of week
           startDate:&startOfDay
            interval:NULL                // ignore seconds
             forDate:now];
    
    int NUM_SECONDS_IN_24_HOURS = 86399;
    NSDate *endOfDay = [NSDate dateWithTimeInterval:NUM_SECONDS_IN_24_HOURS sinceDate:startOfDay];
    
    dispatch_group_t queryGroup = dispatch_group_create();
    
    for (int dayIndex = 1; dayIndex <= 7; dayIndex ++) {
        PFQuery *allItemsInDayQuery = [SnapUser.currentUser.trashArray query];
        [allItemsInDayQuery whereKey:@"createdAt" greaterThanOrEqualTo:startOfDay];
        [allItemsInDayQuery whereKey:@"createdAt" lessThanOrEqualTo:endOfDay];
        [allItemsInDayQuery includeKey:@"category"];
        
        dispatch_group_enter(queryGroup);
        [allItemsInDayQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (error) {
                NSLog(@"%@", error.localizedDescription);
            } else {
                [self formatAxisLabelForDay:startOfDay index:dayIndex];
                [self calculateAndStoreAccuracyOfTrash:objects forDayIndex:dayIndex];
            }
            dispatch_group_leave(queryGroup);
        }];
        
        // Advance to next day
        startOfDay = [startOfDay dateByAddingDays:1];
        endOfDay = [endOfDay dateByAddingDays:1];
    }
    
    dispatch_group_notify(queryGroup, dispatch_get_main_queue(), ^{
        [self updateAccuracyChartData];
    });
}

- (void) formatAxisLabelForDay:(NSDate*)day index:(int)dayIndex {
    NSString *dateLabel = [self.dateFormatter stringFromDate:day];
    if ([self.cal isDateInToday:day]) {
        // TODO: set color
        dateLabel = [NSString stringWithFormat:@"<span style=\"color: #0070C2\">%@<\span>", dateLabel];
    }
    [self.labelForDay setObject:dateLabel forKey:@(dayIndex)];
}

- (void) calculateAndStoreAccuracyOfTrash:(NSArray<Trash*>*)trashArray forDayIndex:(int)dayIndex{
    if (!trashArray || trashArray.count == 0) {
        // No items were disposed that day
        [self.percentageForDay setObject:@(0) forKey:@(dayIndex)];
    } else {
        int correct = 0;
        for (Trash *trash in trashArray) {
            // Check if user trash disposal method, see if it is allowed in Category
            // Booleans are stored as numbers in Parse, so covert back to
            BOOL disposedCorrectly = [[trash.category objectForKey:trash.userAction] boolValue];
            if (disposedCorrectly) {
                correct++;
            }
        }
        // Store percentages and associate with day
        [self.percentageForDay setObject:@((double)correct/trashArray.count * 100) forKey:@(dayIndex)];
    }
}


- (void)updateAccuracyChartData {
    NSMutableArray<NSNumber*> *orderedPercentages = [[NSMutableArray alloc] init];
    NSMutableArray<NSString*> *orderedLabels = [[NSMutableArray alloc] init];
    
    // Add items to percentages array in correct order
    for (int i = 1; i <= 7; i++) {
        [orderedPercentages addObject:[self.percentageForDay objectForKey:@(i)]];
        [orderedLabels addObject:[self.labelForDay objectForKey:@(i)]];
    }
    
    HIColumn *column1 = [[HIColumn alloc]init];
    column1.data = orderedPercentages;
    column1.showInLegend = [[NSNumber alloc] initWithBool:false];
    // TODO: change color
    column1.color = [[HIColor alloc] initWithHexValue:@"ADDEE5"];
    
    HIXAxis *xaxis = [[HIXAxis alloc]init];
    xaxis.categories = orderedLabels;
    xaxis.crosshair = [[HICrosshair alloc]init];
    
    self.accuracyOptions.xAxis = [NSMutableArray arrayWithObject:xaxis];
    self.accuracyOptions.series = [NSMutableArray arrayWithObjects:column1, nil];
    self.accuracyChartView.options = self.accuracyOptions;
}


#pragma mark - Photo log
- (void)fetchTrash: (NSString*)time {
    PFQuery *photoQuery = [[SnapUser currentUser].trashArray query];
    [photoQuery orderByDescending:@"createdAt"];
    [photoQuery includeKey:@"category"];
    NSDate *now = [NSDate date];
    NSDate *since = [NSDate date];
    if ([time isEqualToString:@"All"]){
    }
    else if ([time isEqualToString:@"Past year"]){
        since = [now dateBySubtractingYears:1];
    }
    else if ([time isEqualToString:@"Past 6 months"]){
        since = [now dateBySubtractingMonths:6];
    }
    else if ([time isEqualToString:@"Past month"]){
        since = [now dateBySubtractingMonths:1];
    }
    else if ([time isEqualToString:@"Past week"]){
        since = [now dateBySubtractingWeeks:1];
    }
    else {
        since = [now dateBySubtractingDays:1];
    }
    
    if (![time isEqualToString:@"All"]){
        [photoQuery whereKey:@"createdAt" greaterThan:since];
    }
    
    [photoQuery findObjectsInBackgroundWithBlock:^(NSArray<Trash *> * _Nullable trash, NSError * _Nullable error) {
        if (trash) {
            self.trash = trash;
            [self.photoCollectionView performBatchUpdates:^{
                [self.photoCollectionView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.photoCollectionView.numberOfSections)]];
            } completion:nil];
        }
        else {
            NSLog(@"%@", error.localizedDescription);
            [self fetchTrash:time];
        }
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.trash.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoLogCell *cell = [self.photoCollectionView dequeueReusableCellWithReuseIdentifier:@"PhotoLogCell" forIndexPath:indexPath];
    Trash *trash = self.trash[indexPath.item];
    [cell setPhotoLogCell:trash];
    return cell;
}

#pragma mark - MKDropDownMenuDelegate

- (NSInteger)dropdownMenu:(nonnull MKDropdownMenu *)dropdownMenu numberOfRowsInComponent:(NSInteger)component {
    return 6;
}

- (NSInteger)numberOfComponentsInDropdownMenu:(nonnull MKDropdownMenu *)dropdownMenu {
    return 1;
}

- (NSAttributedString *)dropdownMenu:(MKDropdownMenu *)dropdownMenu attributedTitleForComponent:(NSInteger)component {
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:@"Choose time"];
    [title addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16.0 weight:UIFontWeightLight] range:NSMakeRange(0, title.length)];
    return (NSAttributedString*) title;
}

- (NSAttributedString *)dropdownMenu:(MKDropdownMenu *)dropdownMenu attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:self.dropdownData[row]];
    [title addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.0 weight:UIFontWeightThin] range:NSMakeRange(0, title.length)];
    return (NSAttributedString*) title;
}

-(void)dropdownMenu:(MKDropdownMenu *)dropdownMenu didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSString *time = self.dropdownData[row];
    [self fetchTrash:time];
    [self.photoDropdownMenu selectRow:row inComponent:component];
    [self.photoDropdownMenu closeAllComponentsAnimated:YES];
}

- (UIColor *)dropdownMenu:(MKDropdownMenu *)dropdownMenu backgroundColorForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSIndexSet *selectedRows = [self.photoDropdownMenu selectedRowsInComponent:component];
    NSInteger selectedRow = (NSInteger)selectedRows.firstIndex;
    if (row == selectedRow) {
        return UIColor.greenColor;
    }
    else {
        return UIColor.whiteColor;
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"trashPopUpSegue"]) {
        PhotoPopUpViewController *photoPopUpViewController = [segue destinationViewController];
        
        PhotoLogCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.photoCollectionView indexPathForCell:tappedCell];
        Trash *trash = self.trash[indexPath.item];
        UIImage *image = tappedCell.trashImageView.image;
        
        photoPopUpViewController.trash = trash;
        photoPopUpViewController.convertedImage = image;
    } else if ([segue.identifier isEqualToString:@"helpSegue"]) {
        TutorialViewController *tutVC = [segue destinationViewController];
        tutVC.dismissToExit = YES; // tutorial should be dismissed modally
    }
}

#pragma mark - User actions

/**
 Logs out user
 */
- (IBAction)onLogoutTap:(id)sender {
    // Logout user
    [((TabBarController*)self.tabBarController) logoutUserWithAlertIfError];
}

- (IBAction)onLocationTap:(id)sender {
    // Create alert controller
    UIAlertController *locationAlert = [UIAlertController alertControllerWithTitle:@"Location Services"
                                                                           message:@"Waste disposal rules change depending on where you are in the world! We pull the most relevant data based on your location to help you make the right choices. Enable Location Services in Settings for the best app experience." preferredStyle:UIAlertControllerStyleAlert];
    // Add cancel action
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [locationAlert addAction:cancelAction];
    
    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{}                             completionHandler:^(BOOL success) {
            if (!success) {
                [(TabBarController*)self.tabBarController showOKAlertWithTitle:@"Error" message:@"Unable to open settings"];
            }
        }];
    }];
    [locationAlert addAction:settingsAction];
    
    [self presentViewController:locationAlert animated:YES completion:nil];
}



@end
