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

@interface ProfileViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate, CLLocationManagerDelegate>

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
@property (strong, nonatomic) NSArray<NSNumber*> *orderedPercentages;
@property (strong, nonatomic) NSArray<NSString*> *orderedLabels;

// Photo Log
@property (weak, nonatomic) IBOutlet UICollectionView *photoCollectionView;
@property (strong, nonatomic) NSArray *trash;

// Date pickers
@property (weak, nonatomic) IBOutlet UITextField *startDateTextField;
@property (weak, nonatomic) IBOutlet UITextField *endDateTextField;
@property (strong, nonatomic) UIDatePicker *startDatePicker;
@property (strong, nonatomic) UIDatePicker *endDatePicker;
@property (strong, nonatomic) NSDateFormatter *formatter;

@end

@implementation ProfileViewController

#pragma mark - Loading and Configuration

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set the navigation bar font
    [TabBarController setSnapcycleLogoTitleForNavigationController:self.navigationController];
    
    // set the scrollView frame
    self.scrollView.contentSize = CGSizeMake(375, 1963);
    
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
    
    // set up DatePickers
    self.startDatePicker = [[UIDatePicker alloc] init];
    self.startDatePicker.datePickerMode = UIDatePickerModeDate;
    [self.startDatePicker addTarget:self action:@selector(showSelectedStartDate) forControlEvents:UIControlEventValueChanged];
    [self.startDateTextField setInputView:self.startDatePicker];
    
    self.endDatePicker = [[UIDatePicker alloc] init];
    self.endDatePicker.datePickerMode = UIDatePickerModeDate;
    [self.endDatePicker addTarget:self action:@selector(showSelectedEndDate) forControlEvents:UIControlEventValueChanged];
    [self.endDateTextField setInputView:self.endDatePicker];
    
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateFormat:@"MM/dd/yyyy"];
    NSString *now = [self.formatter stringFromDate:[NSDate date]];
    [self.startDatePicker setMaximumDate:[self.formatter dateFromString:now]];
    [self.endDatePicker setMaximumDate:[self.formatter dateFromString:now]];
    
    UIToolbar *startToolbar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,44)];
    startToolbar.barStyle = UIBarStyleDefault;
    UIBarButtonItem *startSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem* startDoneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissStartDP)];
    
    [startToolbar setItems:[NSArray arrayWithObjects:startSpaceLeft, startDoneButton, nil]];
    
    UIToolbar *endToolbar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,44)];
    endToolbar.barStyle = UIBarStyleDefault;
    UIBarButtonItem *endSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem* endDoneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissEndDP)];
    
    [endToolbar setItems:[NSArray arrayWithObjects:endSpaceLeft, endDoneButton, nil]];
    
    self.startDateTextField.inputAccessoryView = startToolbar;
    self.endDateTextField.inputAccessoryView = endToolbar;

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
        [self.numFirstLabel sizeToFit];
        self.numSecondLabel.text = [NSString stringWithFormat:@"%@", badges.numSecondPlace];
        [self.numSecondLabel sizeToFit];
        self.numThirdLabel.text = [NSString stringWithFormat:@"%@", badges.numThirdPlace];;
        [self.numThirdLabel sizeToFit];
    }];
    
    // Fetch stats for graphs
    [self refreshUserActionStats];
    [self refreshUserAccuracyStats];
    
    // Fetch all trash for photo log
    [self fetchTrash];
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
    // Get sunday of week
    NSDate *now = [NSDate date];
    NSDate *startOfDay;
    [self.cal rangeOfUnit:NSCalendarUnitWeekOfMonth  // find start of week
           startDate:&startOfDay
            interval:NULL                // ignore seconds
             forDate:now];
    
    dispatch_group_t queryGroup = dispatch_group_create();
    
    // Query for accuracy percentages
    dispatch_group_enter(queryGroup);
    [PFCloud callFunctionInBackground:@"accuracyPercentagesForWeekStartingAtDay" withParameters:@{@"day": startOfDay} block:^(id  _Nullable object, NSError * _Nullable error) {
        self.orderedPercentages = object;
        dispatch_group_leave(queryGroup);
    }];
    
    // Create day labels
    dispatch_group_enter(queryGroup);
    self.orderedLabels = [self createDateLabelsForWeekStartingFromDay:startOfDay];
    dispatch_group_leave(queryGroup);
    
    dispatch_group_notify(queryGroup, dispatch_get_main_queue(), ^{
        [self updateAccuracyChartData];
    });
}

// Format labels for week, including color for current day
- (NSArray<NSString*>*)createDateLabelsForWeekStartingFromDay:(NSDate*)day {
    NSMutableArray<NSString*> *orderedLabels = [[NSMutableArray alloc] init];
    for (int i = 0; i < 7; i++) {
        NSString *dateLabel = [self.dateFormatter stringFromDate:day];
        
        if ([self.cal isDateInToday:day]) {
            // TODO: set color
            dateLabel = [NSString stringWithFormat:@"<span style=\"color: #0070C2\">%@<\span>", dateLabel];
        }
        [orderedLabels addObject:dateLabel];
        
        // Advance to next day
        day = [day dateByAddingDays:1];
    }
    return orderedLabels;
}

// Update bar graph with new data
- (void)updateAccuracyChartData {
    HIColumn *column1 = [[HIColumn alloc]init];
    column1.data = self.orderedPercentages;
    column1.showInLegend = [[NSNumber alloc] initWithBool:false];
    // TODO: change color
    column1.color = [[HIColor alloc] initWithHexValue:@"ADDEE5"];
    
    HIXAxis *xaxis = [[HIXAxis alloc]init];
    xaxis.categories = self.orderedLabels;
    
    self.accuracyOptions.xAxis = [NSMutableArray arrayWithObject:xaxis];
    self.accuracyOptions.series = [NSMutableArray arrayWithObjects:column1, nil];
    self.accuracyChartView.options = self.accuracyOptions;
}


#pragma mark - Photo log
- (void)fetchTrash {
    PFQuery *photoQuery = [[SnapUser currentUser].trashArray query];
    [photoQuery orderByDescending:@"createdAt"];
    [photoQuery includeKey:@"category"];
    if(![self.startDateTextField.text isEqualToString:@""]) {
        NSDate *date = [self.formatter dateFromString:self.startDateTextField.text];
        [photoQuery whereKey:@"createdAt" greaterThanOrEqualTo:date];
    }
    if(![self.endDateTextField.text isEqualToString:@""]){
        NSDate *date = [self.formatter dateFromString:self.endDateTextField.text];
        date = [date dateByAddingDays:1];
        [photoQuery whereKey:@"createdAt" lessThanOrEqualTo:date];
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
            [self fetchTrash];
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

#pragma mark - Date Pickers

-(void) showSelectedStartDate{
    [self.endDatePicker setMinimumDate:self.startDatePicker.date];
    self.startDateTextField.text = [NSString stringWithFormat:@"%@",[self.formatter stringFromDate:self.startDatePicker.date]];
}

-(void) showSelectedEndDate{
    [self.startDatePicker setMaximumDate:self.endDatePicker.date];
    self.endDateTextField.text = [NSString stringWithFormat:@"%@",[self.formatter stringFromDate:self.endDatePicker.date]];
}

-(void)dismissStartDP{
    self.startDateTextField.text = [NSString stringWithFormat:@"%@",[self.formatter stringFromDate:self.startDatePicker.date]];
    [self.startDateTextField resignFirstResponder];
    [self fetchTrash];
}

-(void)dismissEndDP{
    self.endDateTextField.text = [NSString stringWithFormat:@"%@",[self.formatter stringFromDate:self.endDatePicker.date]];
    [self.endDateTextField resignFirstResponder];
    [self fetchTrash];
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
