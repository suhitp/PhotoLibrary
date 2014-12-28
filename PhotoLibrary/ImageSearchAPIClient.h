//
//  WebServices.h
//  PhotoLibrary
//
//  Created by Suhit on 28/12/14.
//  Copyright (c) 2014 com.suhit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageSearchAPIClient : NSObject

+ (ImageSearchAPIClient *)sharedClient;

- (void)searchImagesForTitle:(NSString *)query withOffset:(NSInteger)offset successBlock:(void (^)(NSArray *))successBlock errorBlock:(void(^)(NSError *))errorBlock;

- (void)downloadImageWithURL:(NSURL *)url completionHandler:(void (^)(UIImage *, NSError *))completionBlock;

@end
