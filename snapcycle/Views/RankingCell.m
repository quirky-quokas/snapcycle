//
//  RankingXIBView.m
//  snapcycle
//
//  Created by taylorka on 7/30/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import "RankingCell.h"

@interface RankingCell ()

@property (weak, nonatomic) IBOutlet UIImageView *badgeView;
@property (weak, nonatomic) IBOutlet UILabel *rankingLabel;

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numFirstLabel;
@property (weak, nonatomic) IBOutlet UILabel *numSecondLabel;
@property (weak, nonatomic) IBOutlet UILabel *numThirdLabel;


@property (weak, nonatomic) IBOutlet UIImageView *crownView;
@property (weak, nonatomic) IBOutlet UIImageView *profilePicView;
@property (weak, nonatomic) IBOutlet UIView *profilePicBorder;

@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;

@end

@implementation RankingCell

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self customInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)customInit {
    [[NSBundle mainBundle] loadNibNamed:@"RankingXIB"
                                  owner:self options:nil];
    [self addSubview:self.contentView];
    self.contentView.frame = self.bounds;
}

- (void)setUpRankingViewForCompetitor:(Competitor*)competitor isCurrentUser:(BOOL)isCurrentUser badgesAwarded:(BOOL)badgesAwarded {
    // Set up ranking info
    if ([competitor.rank isEqualToNumber:@(1)] && badgesAwarded) {
        self.crownView.hidden = NO;
        self.rankingLabel.hidden = YES;
        self.badgeView.image = [UIImage imageNamed:@"first-place"];
        self.badgeView.hidden = NO;
    } else if ([competitor.rank isEqualToNumber:@(2)] && badgesAwarded) {
        self.crownView.hidden = YES;
        self.rankingLabel.hidden = YES;
        self.badgeView.image = [UIImage imageNamed:@"second-place"];
         self.badgeView.hidden = NO;
    } else if ([competitor.rank isEqualToNumber:@(3)] && badgesAwarded) {
        self.crownView.hidden = YES;
        self.rankingLabel.hidden = YES;
        self.badgeView.image = [UIImage imageNamed:@"third-place"];
         self.badgeView.hidden = NO;
    } else {
        self.crownView.hidden = YES;
        self.rankingLabel.text = [NSString stringWithFormat:@"#%@", competitor.rank];
        self.badgeView.hidden = YES;
        self.rankingLabel.hidden = NO;
    }
    
    // Set up user info
    if (isCurrentUser) {
        self.usernameLabel.text = [NSString stringWithFormat:@"%@ (You)", competitor.user.username];
        self.contentView.backgroundColor = [UIColor colorWithRed:173.0/255.0 green:222.0/255.0 blue:229.0/255.0 alpha:1.0];
    } else {
        self.usernameLabel.text = competitor.user.username;
    }
    
    
    [competitor.user.badges fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        self.numFirstLabel.text = [NSString stringWithFormat:@"%@", competitor.user.badges.numFirstPlace];
        self.numSecondLabel.text = [NSString stringWithFormat:@"%@", competitor.user.badges.numSecondPlace];
        self.numThirdLabel.text = [NSString stringWithFormat:@"%@", competitor.user.badges.numThirdPlace];
    }];
    
    // Profile pic view
    self.profilePicView.layer.cornerRadius = self.profilePicView.frame.size.width / 2;
    self.profilePicBorder.layer.cornerRadius = self.profilePicBorder.frame.size.width / 2;
    PFFileObject *image = competitor.user.profImage;
    [image getDataInBackgroundWithBlock:^(NSData * data, NSError * error) {
        if (!error) {
            UIImage *imageToLoad = [UIImage imageWithData:data];
            [self.profilePicView setImage:imageToLoad];
        }
        else {
            NSLog(@"%@",error.localizedDescription);
        }
        
    }];
    
    // Set up items
    self.scoreLabel.text = [NSString stringWithFormat:@"%@ items", competitor.score];
}

@end
