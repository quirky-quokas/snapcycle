//
//  SoundManager.h
//  snapcycle
//
//  Created by taylorka on 8/2/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SoundManager : NSObject

+ (void)playSuccessSound;

+ (void)playFailureSound;

@end

NS_ASSUME_NONNULL_END
