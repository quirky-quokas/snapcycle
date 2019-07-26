//
//  Category.m
//  snapcycle
//
//  Created by kfullen on 7/16/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import "Category.h"
#import <Parse/Parse.h>

@implementation Category

@dynamic name;
@dynamic info;
@dynamic moreInfo;
@dynamic type;
@dynamic image;
@dynamic landfillInfo;
@dynamic compostInfo;
@dynamic recyclingInfo;

+ (nonnull NSString *)parseClassName {
    return @"Category";
}

+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image {
    
    // check if image is not nil
    if (!image) {
        return nil;
    }
    
    NSData *imageData = UIImagePNGRepresentation(image);
    // get image data and check if that is not nil
    if (!imageData) {
        return nil;
    }
    
    return [PFFileObject fileObjectWithName:@"can.png" data:imageData];
}
@end

