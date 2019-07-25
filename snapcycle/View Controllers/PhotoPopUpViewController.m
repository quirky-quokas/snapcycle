//
//  PhotoPopUpViewController.m
//  snapcycle
//
//  Created by kfullen on 7/25/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import "PhotoPopUpViewController.h"

@interface PhotoPopUpViewController ()
@property (weak, nonatomic) IBOutlet UIView *cellPopUpView;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;


@end

@implementation PhotoPopUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.photoImageView.image = self.convertedImage;
    self.infoLabel.text = self.trash.category.moreInfo;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onOutsideTap:)];
    [self.backgroundImageView setUserInteractionEnabled:YES];
    [self.backgroundImageView addGestureRecognizer:tapGestureRecognizer];
    
}
- (IBAction)onOutsideTap:(id)sender {
    NSLog(@"tap tap tap");
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
