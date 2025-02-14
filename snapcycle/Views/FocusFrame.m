//
//  FocusFrame.m
//  snapcycle
//
//  Created by emilyabest on 7/23/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import "FocusFrame.h"

@implementation FocusFrame

/**
 Overwriting UIView's initWithFrame to initalize an instance of a FocusFrame UIView with the desired characteristics.
 */
- (UIView *)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        // make the frame
        [self setBackgroundColor:[UIColor clearColor]];
        [self.layer setBorderWidth:2.0];
        [self.layer setBorderColor:[UIColor whiteColor].CGColor];
        
        // add blinking animation to frame
        UIColor *scBlue = [UIColor colorWithRed:0.0/255.0 green:112.0/255.0 blue:194.0/255.0 alpha:1.0];
        CABasicAnimation *selectionAnimation = [CABasicAnimation animationWithKeyPath:@"borderColor"];
        selectionAnimation.toValue = (id)scBlue.CGColor;
        selectionAnimation.repeatCount = 6;
        [self.layer addAnimation:selectionAnimation forKey:@"selectionAnimation"];
    }
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
