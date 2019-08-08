//
//  NewsArticleViewController.m
//  snapcycle
//
//  Created by emilyabest on 8/7/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import "NewsArticleViewController.h"
#import "WebKit/WebKit.h"

@interface NewsArticleViewController () <WKNavigationDelegate>
@property (weak, nonatomic) IBOutlet UIView *viewHolder; // TODO: is viewHolder needed? could we just use self.view?
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation NewsArticleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.activityIndicator startAnimating];
    
    NSURL *url = [NSURL URLWithString:self.urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.viewHolder.bounds configuration:config];
    webView.navigationDelegate = self;
    [webView loadRequest:request]; // TODO: why must this be on the main thread?
    [self.viewHolder addSubview:webView];

    // TODO: find a better solution!!!
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        [self.activityIndicator stopAnimating];
    });
    
//    [self.activityIndicator stopAnimating];

// loadRequest and addSubview must be executed on main thread
//    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
//    dispatch_async(globalQueue, ^{
//        [webView loadRequest:request];
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.viewHolder addSubview:webView];
//        });
//    });
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
