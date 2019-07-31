//
//  CameraView.h
//  snapcycle
//
//  Created by emilyabest on 7/25/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CameraViewDelegate <NSObject>

- (void)handlePinchZoom:(UIPinchGestureRecognizer *)pinchGR;
- (void)handleTapFocus:(UITapGestureRecognizer *)tapGR;

@end

@interface CameraView : UIView <UIGestureRecognizerDelegate> // duplicate interface error?

@property (nonatomic, weak) id <CameraViewDelegate> delegate;
- (void)drawFocusFrame:(struct CGPoint)point;
- (void)instantiateGR;

@end

NS_ASSUME_NONNULL_END
