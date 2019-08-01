//
//  TutChildViewController.m
//  snapcycle
//
//  Created by kfullen on 7/31/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import "TutChildViewController.h"

@interface TutChildViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *backdropImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *tutorialImageView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@end

@implementation TutChildViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated {
    self.backdropImageView.image = [UIImage imageNamed:self.backdropImageStr];
    self.tutorialImageView.image = [UIImage imageNamed:self.tutroialImageStr];
    self.titleLabel.text = self.titleText;
    self.infoLabel.text = self.infoText;
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
