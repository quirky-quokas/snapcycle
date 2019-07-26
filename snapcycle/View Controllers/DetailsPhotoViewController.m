//
//  DetailsPhotoViewController.m
//  snapcycle
//
//  Created by emilyabest on 7/25/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import "DetailsPhotoViewController.h"

@interface DetailsPhotoViewController ()

@end

@implementation DetailsPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *fullScreenView = [[UIImageView alloc] initWithFrame:self.view.frame];
    fullScreenView.contentMode = UIViewContentModeScaleAspectFit;
    fullScreenView.image = self.categoryImageView.image;
    self.view = fullScreenView;
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
