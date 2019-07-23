//
//  PhotoLogCell.m
//  snapcycle
//
//  Created by kfullen on 7/22/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import "PhotoLogCell.h"
#import "Trash.h"

@implementation PhotoLogCell

- (void) setPhotoLogCell: (Trash*) trash {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    NSString *dateString = [formatter stringFromDate:trash.createdAt];
    self.dateLabel.text = dateString;
    
    self.typeLabel.text = trash.category.type;
    
    PFFileObject *image = trash.image;
    [image getDataInBackgroundWithBlock:^(NSData * data, NSError * error) {
        if (!error) {
            UIImage *imageToLoad = [UIImage imageWithData:data];
            [self.trashImageView setImage:imageToLoad];
        }
        else {
            NSLog(@"%@",error.localizedDescription);
        }
        
    }];
    
    if (trash.category.type != trash.userAction) {
        UIImage *image = [UIImage imageNamed:@"red-x"];
        self.markerImageView.image = image;
    }
    else {
        UIImage *image = [UIImage imageNamed:@"star"];
        self.markerImageView.image = image;
    }
}

@end
