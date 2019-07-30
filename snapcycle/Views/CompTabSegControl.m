//
//  CompTabSegControl.m
//  snapcycle
//
//  Created by emilyabest on 7/30/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import "CompTabSegControl.h"

@implementation CompTabSegControl

- (void)setColorAndFont {
    // color
    UIColor *scGreen = [UIColor colorWithRed:148.0/255.0 green:200.0/255.0 blue:61.0/255.0 alpha:1.0];
    self.tintColor = UIColor.whiteColor;
    self.backgroundColor = UIColor.whiteColor;
    
    // font TODO: set font for all UIControlStates?
    [self setTitleTextAttributes:@{NSForegroundColorAttributeName:UIColor.darkGrayColor, NSFontAttributeName:[UIFont fontWithName:@"SourceSansPro-Regular" size:20]} forState: UIControlStateNormal];
    [self setTitleTextAttributes:@{NSForegroundColorAttributeName:scGreen, NSFontAttributeName:[UIFont fontWithName:@"SourceSansPro-Semibold" size:20]} forState: UIControlStateSelected];
    [self setTitleTextAttributes:@{NSForegroundColorAttributeName:scGreen, NSFontAttributeName:[UIFont fontWithName:@"SourceSansPro-Semibold" size:20]} forState: UIControlStateHighlighted];
}

- (void)setUnderline {    
//    [self setTitleTextAttributes:@{NSUnderlineStyleAttributeName: @(NSUnderlineStyleNone)} forState:UIControlStateSelected]; // DON'T WANT
    
//    self.apportionsSegmentWidthsByContent = true; // DON'T WANT
    
    
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
