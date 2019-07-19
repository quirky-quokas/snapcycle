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
        
        NSLog(@"%@", self.filteredCategories);
        
    }
    else {
        self.filteredCategories = self.categories;
    }
    
    [self.categoriesCollectionView reloadData];
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.categoriesSearchBar.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.categoriesSearchBar.showsCancelButton = NO;
    self.categoriesSearchBar.text = @"";
    [self.categoriesSearchBar resignFirstResponder];
    self.filteredCategories = self.categories;
    [self.categoriesCollectionView reloadData];
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

