//
//  CompetitionViewController.h
//  snapcycle
//
//  Created by emilyabest on 7/22/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CompetitionManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface CompetitionViewController : UIViewController<CurrentCompetitionDisplayer, PreviousResultsDisplayer>

@end

NS_ASSUME_NONNULL_END
