//
//  TutChildViewController.m
//  snapcycle
//
//  Created by kfullen on 7/31/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import "TutChildViewController.h"
#import <SDWebImage/SDWebImage.h>
#import "TutorialPageViewController.h"

@interface TutChildViewController ()

//@property (weak, nonatomic) IBOutlet UIImageView *backdropImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *tutorialImageView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIButton *endTutorialButton;

@end

@implementation TutChildViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.backdropImageView.image = nil;
    NSURL *gifURL = [NSURL URLWithString:self.tutorialImageStr];
    [self.tutorialImageView sd_setImageWithURL:gifURL];
    self.titleLabel.text = self.titleText;
    self.titleLabel.textAlignment = UIControlContentVerticalAlignmentFill;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.infoLabel.text = self.infoText;
//    [self.infoLabel sizeToFit];
    self.infoLabel.textAlignment = UIControlContentVerticalAlignmentCenter;
    self.infoLabel.textAlignment = NSTextAlignmentLeft;
    if (self.lastPage == NO){
        self.endTutorialButton.enabled = NO;
        self.endTutorialButton.hidden = YES;
    }
    else {
        self.endTutorialButton.enabled = YES;
        self.endTutorialButton.hidden = NO;
        self.infoLabel.hidden = YES;
    }
}

- (IBAction)tapEndTutorial:(id)sender {
    if (((TutorialPageViewController*)self.parentViewController).dismissToExit) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        // Segue to exit
        [self performSegueWithIdentifier:@"endedTutorialSegue" sender:self];
    }
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

