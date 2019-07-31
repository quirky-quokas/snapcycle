//
//  PhotoPopUpViewController.m
//  snapcycle
//
//  Created by kfullen on 7/25/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import "PhotoPopUpViewController.h"
#import "Parse/Parse.h"

@interface PhotoPopUpViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *landfillLabel;
@property (weak, nonatomic) IBOutlet UILabel *compostLabel;
@property (weak, nonatomic) IBOutlet UILabel *recyclingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *landfillImageView;
@property (weak, nonatomic) IBOutlet UIImageView *compostImageView;
@property (weak, nonatomic) IBOutlet UIImageView *recyclingImageView;
@property (weak, nonatomic) IBOutlet UIScrollView *cellScrollView;
@property (weak, nonatomic) IBOutlet UIView *enclosingView;

@end

@implementation PhotoPopUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.cellScrollView.delegate = self;
    CGFloat contentWidth = self.cellScrollView.bounds.size.width;
    CGFloat contentHeight = self.cellScrollView.bounds.size.height * 1.5;
    self.cellScrollView.contentSize = CGSizeMake(contentWidth, contentHeight);
    
    self.enclosingView.layer.cornerRadius = 5;
    self.enclosingView.layer.masksToBounds = YES;
    
    self.photoImageView.image = self.convertedImage;
    self.nameLabel.text = self.trash.category.name;
    self.landfillLabel.text = self.trash.category.landfillInfo;
    self.compostLabel.text = self.trash.category.compostInfo;
    self.recyclingLabel.text = self.trash.category.recyclingInfo;
    
    if (self.trash.category.landfill == YES && self.trash.category.recycling == YES && self.trash.category.compost == YES) {
        self.landfillImageView.image = [UIImage imageNamed:@"green-thumb"];
        self.recyclingImageView.image = [UIImage imageNamed:@"green-thumb"];
        self.compostImageView.image = [UIImage imageNamed:@"green-thumb"];
    }
    else if (self.trash.category.landfill == YES && self.trash.category.recycling == YES && self.trash.category.compost == NO) {
        self.landfillImageView.image = [UIImage imageNamed:@"green-thumb"];
        self.recyclingImageView.image = [UIImage imageNamed:@"green-thumb"];
        self.compostImageView.image = [UIImage imageNamed:@"stop-hand"];
    }
    else if (self.trash.category.landfill == YES && self.trash.category.recycling == NO && self.trash.category.compost == YES) {
        self.landfillImageView.image = [UIImage imageNamed:@"green-thumb"];
        self.recyclingImageView.image = [UIImage imageNamed:@"stop-hand"];
        self.compostImageView.image = [UIImage imageNamed:@"green-thumb"];
    }
    else if (self.trash.category.landfill == NO && self.trash.category.recycling == YES && self.trash.category.compost == YES) {
        self.landfillImageView.image = [UIImage imageNamed:@"stop-hand"];
        self.recyclingImageView.image = [UIImage imageNamed:@"green-thumb"];
        self.compostImageView.image = [UIImage imageNamed:@"green-thumb"];
    }
    else if (self.trash.category.landfill == YES && self.trash.category.recycling == NO && self.trash.category.compost == NO) {
        self.landfillImageView.image = [UIImage imageNamed:@"green-thumb"];
        self.recyclingImageView.image = [UIImage imageNamed:@"stop-hand"];
        self.compostImageView.image = [UIImage imageNamed:@"stop-hand"];
    }
    else if (self.trash.category.landfill == NO && self.trash.category.recycling == YES && self.trash.category.compost == NO) {
        self.landfillImageView.image = [UIImage imageNamed:@"stop-hand"];
        self.recyclingImageView.image = [UIImage imageNamed:@"green-thumb"];
        self.compostImageView.image = [UIImage imageNamed:@"stop-hand"];
    }
    else if (self.trash.category.landfill == NO && self.trash.category.recycling == NO && self.trash.category.compost == YES) {
        self.landfillImageView.image = [UIImage imageNamed:@"stop-hand"];
        self.recyclingImageView.image = [UIImage imageNamed:@"stop-hand"];
        self.compostImageView.image = [UIImage imageNamed:@"green-thumb"];
    }
    else {
        self.landfillImageView.image = [UIImage imageNamed:@"stop-hand"];
        self.recyclingImageView.image = [UIImage imageNamed:@"stop-hand"];
        self.compostImageView.image = [UIImage imageNamed:@"stop-hand"];
    }
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onOutsideTap:)];
    [self.backgroundImageView setUserInteractionEnabled:YES];
    [self.backgroundImageView addGestureRecognizer:tapGestureRecognizer];
    
}
- (IBAction)onOutsideTap:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    if (self.cellScrollView.contentOffset.x != 0) {
//        self.cellScrollView.contentOffset.x = 0;
//    }
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
