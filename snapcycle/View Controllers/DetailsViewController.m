//
//  DetailsViewController.m
//  snapcycle
//
//  Created by emilyabest on 7/16/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import "DetailsViewController.h"
#import "SnapUser.h"
#import "Trash.h"

@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *categoryImageView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIButton *recycleButton;
@property (weak, nonatomic) IBOutlet UIButton *compostButton;
@property (weak, nonatomic) IBOutlet UIButton *landfillButton;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.nameLabel.text = self.category.name;
    self.infoLabel.text = self.category.info;
    
    PFFileObject *image = self.category.image;
    [image getDataInBackgroundWithBlock:^(NSData * data, NSError * error) {
        if (!error) {
            UIImage *imageToLoad = [UIImage imageWithData:data];
            [self.categoryImageView setImage:imageToLoad];
        }
        else {
            NSLog(@"%@",error.localizedDescription);
        }
        
    }];
}
- (IBAction)recycleTrash:(id)sender {
    Trash *newTrash = [Trash new];
    
    newTrash.name = self.category.name;
    newTrash.type = @"recycling";
    newTrash.user = [SnapUser currentUser];
    newTrash.image = self.category.image;
    
    [newTrash saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            SnapUser *user = [SnapUser currentUser];
            [user.trashArray addObject:newTrash];
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            }];
            [self.navigationController popViewControllerAnimated:YES];
            NSString* message = @"You've successfully recycled your trash";
            [self.delegate postedTrash:message];
        }
        else {
            NSString *alertTitle = @"Could not recycle trash";
            [self showAlertwithTitle:alertTitle];
        }
    }];
}
- (IBAction)compostTrash:(id)sender {
    Trash *newTrash = [Trash new];
    
    newTrash.name = self.category.name;
    newTrash.type = @"compost";
    newTrash.user = [SnapUser currentUser];
    newTrash.image = self.category.image;
    
    [newTrash saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            SnapUser *user = [SnapUser currentUser];
            [user.trashArray addObject:newTrash];
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            }];
            [self.navigationController popViewControllerAnimated:YES];
            NSString* message = @"You've successfully composted your trash";
            [self.delegate postedTrash:message];
        }
        else {
            NSString *alertTitle = @"Could not compost trash";
            [self showAlertwithTitle:alertTitle];
        }
    }];
}
- (IBAction)throwAwayTrash:(id)sender {
    Trash *newTrash = [Trash new];
    
    newTrash.name = self.category.name;
    newTrash.type = @"landfill";
    newTrash.user = [SnapUser currentUser];
    newTrash.image = self.category.image;
    
    [newTrash saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            SnapUser *user = [SnapUser currentUser];
            [user.trashArray addObject:newTrash];
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            }];
            [self.navigationController popViewControllerAnimated:YES];
            NSString* message = @"You've successfully thrown away your trash";
            [self.delegate postedTrash:message];
        }
        else {
            NSString *alertTitle = @"Could not throw away trash";
            [self showAlertwithTitle:alertTitle];
        }
    }];
}

- (void) showAlertwithTitle:(NSString*)title {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:@"Please try again" preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:^{
        
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
