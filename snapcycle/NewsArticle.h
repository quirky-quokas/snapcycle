//
//  NewsArticle.h
//  snapcycle
//
//  Created by emilyabest on 8/6/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NewsArticle : NSObject

@property (strong, nonatomic) NSString *headline;
@property (strong, nonatomic) NSString *descrip;
@property (strong, nonatomic) NSString *author;
@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) NSString *url;

@end

NS_ASSUME_NONNULL_END
