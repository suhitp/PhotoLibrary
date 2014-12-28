//
//  SPImageDetailViewController.m
//  PhotoLibrary
//
//  Created by Suhit on 28/12/14.
//  Copyright (c) 2014 com.suhit. All rights reserved.
//

#import "SPImageDetailViewController.h"
#import "ImageSearchAPIClient.h"

@interface SPImageDetailViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@end

@implementation SPImageDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.spinner.color = [UIColor grayColor];
    self.spinner.center = self.view.center;
    [self.view addSubview:self.spinner];
    [self.spinner setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addConstrintsToSpinner];
    
    if (_imageURL) {
        [self.spinner startAnimating];
        self.title = self.imageTitle;
        [self downloadImageForURL:self.imageURL];
    }
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


- (void)downloadImageForURL:(NSURL *)imageURL {
    [[ImageSearchAPIClient sharedClient] downloadImageWithURL:imageURL
                                            completionHandler:^(UIImage *image, NSError *error) {
                                                if (!error) {
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        [self.spinner stopAnimating];
                                                        _imageView.image = image;
                                                    });
                                                }
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
