//
//  ViewController.m
//  PhotoLibrary
//
//  Created by Suhit on 28/12/14.
//  Copyright (c) 2014 com.suhit. All rights reserved.
//

#import "SPImageSearchViewController.h"
#import "ImageSearchAPIClient.h"
#import "Image.h"
#import "SPImageDetailViewController.h"


static NSString* const kImageCell = @"imageCell";

@interface SPImageSearchViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (strong, nonatomic) NSMutableArray *imageArray;

@end

@implementation SPImageSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"Gallery";
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.spinner.color = [UIColor grayColor];
    self.spinner.center = self.view.center;
    [self.view addSubview:self.spinner];
    [self.spinner setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addConstrintsToSpinner];
}

- (void)addConstrintsToSpinner {
    
    UIView *superview = self.view;
    UIActivityIndicatorView *spinner = self.spinner;
    NSDictionary *variables = NSDictionaryOfVariableBindings(spinner, superview);
    NSArray *constraints =
    [NSLayoutConstraint constraintsWithVisualFormat:@"V:[superview]-(<=1)-[spinner]"
                                            options: NSLayoutFormatAlignAllCenterX
                                            metrics:nil
                                              views:variables];
    [self.view addConstraints:constraints];
    
    constraints =
    [NSLayoutConstraint constraintsWithVisualFormat:@"H:[superview]-(<=1)-[spinner]"
                                            options: NSLayoutFormatAlignAllCenterY
                                            metrics:nil
                                              views:variables];
    [self.view addConstraints:constraints];
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _imageArray.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *imageCell = [collectionView dequeueReusableCellWithReuseIdentifier:kImageCell forIndexPath:indexPath];
    
    [self downloadImageForCell:imageCell forIndexPath:indexPath];
    
    // Check if this has been the last item, if so start loading more images...
    if (indexPath.row == [self.imageArray count] - 1) {
        [self loadImagesWithOffset:(int)[self.imageArray count]];
    };

    return imageCell;
}

- (void)downloadImageForCell:(UICollectionViewCell *)imageCell forIndexPath:(NSIndexPath *)indexPath {
   
    Image *image = self.imageArray[indexPath.row];
    UIImageView *imageView = (UIImageView *)[imageCell viewWithTag:101];
    [[ImageSearchAPIClient sharedClient] downloadImageWithURL:image.thumbnailURL
                                            completionHandler:^(UIImage *image, NSError *error) {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    imageView.image = image;
                                                });
    }];
}

#pragma mark - SearchBar Delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
    [self loadImagesWithOffset:0];
}

- (void)loadImagesWithOffset:(NSInteger)offset {
   
    if (![self.searchBar.text length] && [self.searchBar.text isEqualToString:@" "])  {
        return;
    }
    
    if ([self.searchBar.text length] && offset == 0) {
        [self.imageArray removeAllObjects];
        [self.spinner startAnimating];
        [self.collectionView reloadData];
    }
    [[ImageSearchAPIClient sharedClient] searchImagesForTitle:self.searchBar.text withOffset:offset successBlock:^(NSArray *images) {
        
        if (offset == 0) {
            self.imageArray = [images mutableCopy];
        }
        else {
            [self.imageArray addObjectsFromArray:images];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.spinner stopAnimating];
            [self.collectionView reloadData];
        });
        
        
    } errorBlock:^(NSError *error) {
        NSLog(@"Error fetching images = %@", error);
    }];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqual:@"imageDetailsSegue"]) {
        NSIndexPath *indexPath = self.collectionView.indexPathsForSelectedItems[0];
        SPImageDetailViewController *imageDetailViewController = (SPImageDetailViewController *)[segue destinationViewController];
        imageDetailViewController.imageURL = [self.imageArray[indexPath.row] imageURL];
        imageDetailViewController.imageTitle = [self.imageArray[indexPath.row] title];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
