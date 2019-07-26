//
//  PhotoPopUpViewController.m
//  snapcycle
//
//  Created by kfullen on 7/25/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import "PhotoPopUpViewController.h"
#import "Parse/Parse.h"

@interface PhotoPopUpViewController ()
@property (weak, nonatomic) IBOutlet UIView *cellPopUpView;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *moreInfoLabel;

@end

@implementation PhotoPopUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.photoImageView.image = self.convertedImage;
    self.nameLabel.text = self.trash.category.name;
    
    NSMutableString *action = [NSMutableString string];
    
    if ([self.trash.category.type isEqualToString:@"recycling"]) {
        [action setString:@"recycled"];
    }
    else if ([self.trash.category.type isEqualToString:@"compost"]) {
        [action setString:@"composted"];
    }
    else {
        [action setString:@"thrown away"];
    }
    
    PFQuery *query = [[SnapUser currentUser].trashArray query];
    PFQuery *categoryQuery = [Category query];
    [categoryQuery whereKey:@"name" equalTo:self.trash.category.name];
    [query whereKey:@"category" matchesQuery:categoryQuery];
    [query whereKey:@"userAction" equalTo:self.trash.category.type];
    [query countObjectsInBackgroundWithBlock:^(int count, NSError * _Nullable error) {
        if (!error){
            if (count > 1) {
                self.infoLabel.text = [NSString stringWithFormat:@"You've %@ %d %@ items in total! Good job!", action, count, self.trash.category.name];
            }
            else {
                self.infoLabel.text = [NSString stringWithFormat:@"You've %@ %d %@ items in total", action, count, self.trash.category.name];
            }
        }
        else {
            self.infoLabel.text = [NSString stringWithFormat:@"You've %@ ... %@ items in total!", action, self.trash.category.name];
        }
    }];
    
    PFQuery *secondQuery = [[SnapUser currentUser].trashArray query];
    PFQuery *secondCategoryQuery = [Category query];
    [secondCategoryQuery whereKey:@"name" equalTo:self.trash.category.name];
    [secondQuery whereKey:@"category" matchesQuery:categoryQuery];
    [secondQuery whereKey:@"userAction" notEqualTo:self.trash.category.type];
    [secondQuery countObjectsInBackgroundWithBlock:^(int count, NSError * _Nullable error) {
        if (!error){
            if (count > 0) {
                self.moreInfoLabel.text = [NSString stringWithFormat:@"You should've %@ %d %@ items", action, count, self.trash.category.name];
            }
            else {
                self.moreInfoLabel.text = [NSString stringWithFormat:@"Wow, you've %@ all your %@ items successfully! You're awesome :)", action, self.trash.category.name];
            }
        }
        else {
            self.moreInfoLabel.text = [NSString stringWithFormat:@"However, you should've %@ ... %@ items", action, self.trash.category.name];
        }
    }];
    
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onOutsideTap:)];
    [self.backgroundImageView setUserInteractionEnabled:YES];
    [self.backgroundImageView addGestureRecognizer:tapGestureRecognizer];
    
}
- (IBAction)onOutsideTap:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
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
