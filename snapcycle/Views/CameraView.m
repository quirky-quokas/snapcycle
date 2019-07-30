//
//  CameraView.m
//  snapcycle
//
//  Created by emilyabest on 7/25/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.

#import "CameraView.h"
#import "FocusFrame.h"

@interface CameraView () <UIGestureRecognizerDelegate>
@end

@implementation CameraView

// TODO: instantiateGR method? GRDelegate only allowed as VC, not view
//- (void)awakeFromNib {
//    [super awakeFromNib];
//    NSLog(@"SUCCESS");
//}

/**
 Draws a focus frame around the point of focus the user has tapped.
 */
- (void)drawFocusFrame:(struct CGPoint)point{
    CGRect frameRect = CGRectMake(point.x-40, point.y-40, 60, 60);
    FocusFrame *focusFrame = [[FocusFrame alloc] initWithFrame:frameRect];
    [self addSubview:focusFrame];
    [focusFrame setNeedsDisplay];

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.0];
    [focusFrame setAlpha:0.0];
    [UIView commitAnimations];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
