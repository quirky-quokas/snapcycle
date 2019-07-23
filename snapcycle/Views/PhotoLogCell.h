//
//  PhotoLogCell.h
//  snapcycle
//
//  Created by kfullen on 7/22/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Trash.h"

NS_ASSUME_NONNULL_BEGIN

@interface PhotoLogCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *trashImageView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *markerImageView;

-(void) setPhotoLogCell:(Trash*)trash;
@end

NS_ASSUME_NONNULL_END
