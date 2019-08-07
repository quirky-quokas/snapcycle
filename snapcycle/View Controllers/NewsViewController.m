//
//  NewsViewController.m
//  snapcycle
//
//  Created by emilyabest on 8/6/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import "NewsViewController.h"
#import "NewsArticleCell.h"
#import "UIImageView+AFNetworking.h"
#import "TabBarController.h"
#import "NewsArticleViewController.h"

@interface NewsViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *articles;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation NewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [TabBarController setSnapcycleLogoTitleForNavigationController:self.navigationController];
    
    [self.activityIndicator startAnimating];
    [self getJSONData];

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(getJSONData) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)getJSONData {
    // TODO: update url daily with new date
    // TODO: allow user to search for a topic they're interested in?
    NSURL *url = [NSURL URLWithString:@"https://newsapi.org/v2/everything?q=landfill-waste&from=2019-07-07&sortBy=publishedAt&apiKey=f1ea246abb09430faa9a42590f9fe5ae"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            // Fill movies array with data from dictionary
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            self.articles = jsonDict[@"articles"];
            
            //TODO: check if no articles today!
            
            // Reload table view
            [self.tableView reloadData];
        }
        [self.refreshControl endRefreshing];
        
        [self.activityIndicator stopAnimating];
    }];
    
    [task resume];
}

- (IBAction)didTapLogout:(UIBarButtonItem *)sender {
    TabBarController *tabVC = [[TabBarController alloc] init];
    [tabVC logoutUserWithAlertIfError];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NewsArticleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewsArticleCell"];
    
    NSDictionary *article = self.articles[indexPath.row];
    
    if (!((article[@"title"] == (id)[NSNull null]) || ([article[@"title"] length] == 0))) {
        cell.articleTitle.text = article[@"title"];
    }
    
    if (!((article[@"description"] == (id)[NSNull null]) || ([article[@"description"] length] == 0))) {
        cell.articleDescrip.text = article[@"description"];
    }
    
    if (!((article[@"author"] == (id)[NSNull null]) || ([article[@"author"] length] == 0))) {
        cell.articleAuthor.text = article[@"author"];
    }
    
    if (!((article[@"urlToImage"] == (id)[NSNull null]) || ([article[@"urlToImage"] length] == 0))) {
        NSURL *url = [NSURL URLWithString:article[@"urlToImage"]];
        cell.articleImage.image = nil;
        [cell.articleImage setImageWithURL:url];
    }
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.articles.count;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    NewsArticleCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
    NSDictionary *article = self.articles[indexPath.row];
    
    NewsArticleViewController *articleVC = [segue destinationViewController];
    articleVC.urlStr = article[@"url"];
}

@end
