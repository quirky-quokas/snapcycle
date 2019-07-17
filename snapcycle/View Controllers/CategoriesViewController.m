//
//  CategoriesViewController.m
//  snapcycle
//
//  Created by kfullen on 7/17/19.
//  Copyright © 2019 Quirky Quokkas. All rights reserved.
//

#import "Category.h"
#import "CategoriesViewController.h"
#import "CategoriesCell.h"
#import "DetailsViewController.h"

@interface CategoriesViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *categoriesCollectionView;
@property (strong, nonatomic) NSArray *categories;

@end

@implementation CategoriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.categoriesCollectionView.dataSource = self;
    self.categoriesCollectionView.delegate = self;
    
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
    
    Category *category = self.categories[indexPath.item];
    [cell setCategory:category];
    
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.categories.count;
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UICollectionViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.categoriesCollectionView indexPathForCell:tappedCell];
    Category *category = self.categories[indexPath.item];
    
    DetailsViewController *detailsViewController = [segue destinationViewController];
    detailsViewController.category = category;
}



@end

