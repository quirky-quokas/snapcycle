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

/**
 Instantiate the gesture recognizers
 */
- (void)instantiateGR {
    // instantiate the pinch gesture recognizer (zoom)
    UIPinchGestureRecognizer *pinchGR = [[UIPinchGestureRecognizer alloc] initWithTarget:self.delegate action:@selector(handlePinchZoom:)];
    [self addGestureRecognizer:pinchGR];
    self.userInteractionEnabled = YES;
    pinchGR.cancelsTouchesInView = NO;
    pinchGR.delegate = self;
    
    // instantiate the tap gesture recognizer (focus)
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self.delegate action:@selector(handleTapFocus:)];
    [self addGestureRecognizer:tapGR];
    tapGR.numberOfTapsRequired = 1;
    tapGR.numberOfTouchesRequired = 1;
    tapGR.delegate = self;
}

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
