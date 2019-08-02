//
//  CompetitionInfoViewController.m
//  snapcycle
//
//  Created by taylorka on 8/1/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import "CompetitionInfoPopUpViewController.h"

@interface CompetitionInfoPopUpViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIView *enclosingView;

@end

@implementation CompetitionInfoPopUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.enclosingView.layer.cornerRadius = 5;
    self.enclosingView.layer.masksToBounds = YES;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onOutsideTap)];
    [self.backgroundImageView setUserInteractionEnabled:YES];
    [self.backgroundImageView addGestureRecognizer:tapGestureRecognizer];
}

- (void) onOutsideTap {
    NSLog(@"tap");
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
