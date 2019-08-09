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

@interface NewsViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *articles;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSString *topic;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIView *tableViewPlaceholder;

@end

@implementation NewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchBar.delegate = self;
    
    // ui design
    [TabBarController setSnapcycleLogoTitleForNavigationController:self.navigationController];
    [self.tableViewPlaceholder setHidden:YES];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    // get articles
    [self.activityIndicator startAnimating];
    self.topic = @"landfill";
    [self getJSONData];

    // pull to refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(getJSONData) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    // tap to dismiss keyboard
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOffKeyboard:)];
    [self.view setUserInteractionEnabled:YES];
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

#pragma mark - methods to access api data

- (void)getJSONData {
    NSString *urlStr = [self getURLStr];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *const request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *const session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
            [(TabBarController*)self.tabBarController showOKAlertWithTitle:@"Error" message:@"Unable to get articles. Try again later."];
        } else {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            self.articles = jsonDict[@"articles"];
            
            // check if no articles today
            [self.tableViewPlaceholder setHidden:self.articles.count != 0];
            
            [self.tableView reloadData];
        }
        [self.refreshControl endRefreshing];
        [self.activityIndicator stopAnimating];
    }];
    
    [task resume];
}

- (NSString *)getURLStr {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *today = [dateFormatter stringFromDate:[NSDate date]];
    
    NSString *urlStr = [NSString stringWithFormat:@"https://newsapi.org/v2/everything?q=%@-waste&from=%@&sortBy=publishedAt&apiKey=f1ea246abb09430faa9a42590f9fe5ae", self.topic, today];
    
    return urlStr;
}

#pragma mark - SearchBarDelegate methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    // NOTE: does not account for invalid user input
    self.topic = [searchText stringByReplacingOccurrencesOfString:@" " withString:@"-"];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.activityIndicator startAnimating];
    [self getJSONData];
    
    if (self.articles.count != 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.text = @"";
    self.searchBar.showsCancelButton = NO;
    [self.searchBar resignFirstResponder];
}

- (IBAction)tapOffKeyboard:(id)sender {
    [self.view endEditing:YES];
}

#pragma mark - TableViewDelegate methods

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NewsArticleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewsArticleCell"];
    NSDictionary *article = self.articles[indexPath.row];
    
    if (!((article[@"title"] == (id)[NSNull null]) || ([article[@"title"] length] == 0))) {
        cell.articleTitle.text = article[@"title"];
    }
    
    if (!((article[@"description"] == (id)[NSNull null]) || ([article[@"description"] length] == 0))) {
        cell.articleDescrip.text = article[@"description"];
    }
    
    if (!((article[@"urlToImage"] == (id)[NSNull null]) || ([article[@"urlToImage"] length] == 0))) {
            NSURL *url = [NSURL URLWithString:article[@"urlToImage"]];
            cell.articleImage.image = nil;
            [cell.articleImage setImageWithURL:url placeholderImage:[UIImage imageNamed:@"news_articleImagePlaceholder"]];
    }
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.articles.count;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NewsArticleCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
    NSDictionary *article = self.articles[indexPath.row];
    
    NewsArticleViewController *articleVC = [segue destinationViewController];
    articleVC.urlStr = article[@"url"];
}

- (IBAction)didTapLogout:(UIBarButtonItem *)sender {
    TabBarController *tabVC = [[TabBarController alloc] init];
    [tabVC logoutUserWithAlertIfError];
}

@end
