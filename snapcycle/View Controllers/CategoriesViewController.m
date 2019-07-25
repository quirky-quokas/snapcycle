//
//  CategoriesViewController.m
//  snapcycle
//
//  Created by kfullen on 7/17/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import "CategoriesViewController.h"
#import "CategoriesCell.h"
#import "DetailsViewController.h"
#import "Category.h"
#import "TabBarController.h"

@interface CategoriesViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, DetailsViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *categoriesCollectionView;
@property (weak, nonatomic) IBOutlet UISearchBar *categoriesSearchBar;
@property (strong, nonatomic) NSArray *categories;
@property (strong, nonatomic) NSArray *filteredCategories;

@end

@implementation CategoriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.categoriesCollectionView.dataSource = self;
    self.categoriesCollectionView.delegate = self;
    self.categoriesSearchBar.delegate = self;
    
    [self fetchCategories];
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) self.categoriesCollectionView.collectionViewLayout;
    
    layout.minimumInteritemSpacing = 4;
    layout.minimumLineSpacing = 4;
    CGFloat postersPerLine = 3;
    CGFloat itemWidth = (self.categoriesCollectionView.frame.size.width - layout.minimumLineSpacing * (postersPerLine - 1)) / postersPerLine;
    CGFloat itemHeight = itemWidth * 1.5;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    
    // set the navigation bar font
    UIColor *scBlue = [UIColor colorWithRed:0.0/255.0 green:112.0/255.0 blue:194.0/255.0 alpha:1.0];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:scBlue, NSFontAttributeName:[UIFont fontWithName:@"SourceSansPro-Light" size:25]}];
}

- (void) fetchCategories {
    PFQuery *postQuery = [PFQuery queryWithClassName:@"Category"];
    [postQuery includeKey:@"name"];
    [postQuery includeKey:@"description"];
    [postQuery includeKey:@"type"];
    [postQuery includeKey:@"image"];
    
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray<Category *> * _Nullable categories, NSError * _Nullable error) {
        if (categories) {
            // Store categories data in categories array
            self.categories = categories;
            self.filteredCategories = self.categories;
            
            // Reload collection view to display categories
            [self.categoriesCollectionView reloadData];
        }
        else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    CategoriesCell *cell = [_categoriesCollectionView dequeueReusableCellWithReuseIdentifier:@"CategoriesCell" forIndexPath:indexPath];
    
    Category *category = self.filteredCategories[indexPath.item];
    [cell setCategory:category];
    
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filteredCategories.count;
}

- (void) postedTrash:(NSString*)message {
    [(TabBarController*)self.tabBarController showOKAlertWithTitle:@"Good work"message:message];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (searchText.length != 0) {
        
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(Category *evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject.name containsString:searchText];
        }];
        self.filteredCategories = [self.categories filteredArrayUsingPredicate:predicate];
        [self.categoriesCollectionView reloadData];
    }
    else {
        self.filteredCategories = self.categories;
        [self.categoriesCollectionView performBatchUpdates:^{
            [self.categoriesCollectionView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.categoriesCollectionView.numberOfSections)]];
        } completion:nil];
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.categoriesSearchBar.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    if ([self.categoriesSearchBar.text isEqualToString:@""]) {
        self.categoriesSearchBar.showsCancelButton = NO;
        [self.categoriesSearchBar resignFirstResponder];
    }
    else {
        self.categoriesSearchBar.showsCancelButton = NO;
        self.categoriesSearchBar.text = @"";
        [self.categoriesSearchBar resignFirstResponder];
        self.filteredCategories = self.categories;
        [self.categoriesCollectionView performBatchUpdates:^{
            [self.categoriesCollectionView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.categoriesCollectionView.numberOfSections)]];
        } completion:nil];
    }
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UICollectionViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.categoriesCollectionView indexPathForCell:tappedCell];
    Category *category = self.filteredCategories[indexPath.item];
    
    DetailsViewController *detailsViewController = [segue destinationViewController];
    detailsViewController.category = category;
    detailsViewController.delegate = self;
}



@end

