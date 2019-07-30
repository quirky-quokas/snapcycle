//
//  RankingXIBView.h
//  snapcycle
//
//  Created by taylorka on 7/30/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Competitor.h"

NS_ASSUME_NONNULL_BEGIN

@interface RankingCell : UITableViewCell

- (void)setUpRankingViewForCompetitor:(Competitor*)competitor isCurrentUser:(BOOL)isCurrentUser badgesAwarded:(BOOL)badgesAwarded;

@end

NS_ASSUME_NONNULL_END
