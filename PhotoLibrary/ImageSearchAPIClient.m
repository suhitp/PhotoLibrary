//
//  WebServices.m
//  PhotoLibrary
//
//  Created by Suhit on 28/12/14.
//  Copyright (c) 2014 com.suhit. All rights reserved.
//

#import "ImageSearchAPIClient.h"
#import "Image.h"

static NSString * const kImageSearchAPIBaseURLString = @"http://ajax.googleapis.com/ajax/services/search/images";

@interface ImageSearchAPIClient()

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation ImageSearchAPIClient

+ (ImageSearchAPIClient *)sharedClient
{
    static ImageSearchAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[ImageSearchAPIClient alloc] init];
    });
    
    return _sharedClient;
}

#pragma mark - get imagedata from Google ImageSearch API

- (void)searchImagesForTitle:(NSString *)query withOffset:(NSInteger)offset successBlock:(void (^)(NSArray *))successBlock errorBlock:(void (^)(NSError *))errorBlock {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kImageSearchAPIBaseURLString]];
    request.HTTPMethod = @"GET";
    NSString *queryString = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSDictionary *parameters = @{@"v": @"1.0",
                                 @"rsz": @"8",
                                 @"q": queryString,
                                 @"start": [@(offset) stringValue]
                                 };
    NSMutableString *parameterString = [NSMutableString string];
    for (NSString *key in [parameters allKeys]) {
        if ([parameterString length]) {
            [parameterString appendString:@"&"];
        }
        [parameterString appendFormat:@"%@=%@", key, parameters[key]];
    }
    request.URL = [NSURL URLWithString:[[request.URL absoluteString] stringByAppendingFormat:request.URL.query ? @"&%@" : @"?%@", parameterString]];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
            if (httpResp.statusCode == 200 && [data length]) {
                NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if ([jsonResponse objectForKey:@"responseData"] == [NSNull null]) {
                    return;
                }
                
                NSArray *jsonArray = jsonResponse[@"responseData"][@"results"];
                NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:jsonArray.count];
                
                for (NSDictionary *jsonDict in jsonArray) {
                    Image *image = [[Image alloc] init];
                    
                    image.title = jsonDict[@"contentNoFormatting"];
                    image.details = jsonDict[@"originalContextUrl"];
                    
                    image.thumbnailURL = [NSURL URLWithString:jsonDict[@"tbUrl"]];
                    image.thumbnailSize = CGSizeMake([[jsonDict valueForKeyPath:@"tbWidth"] floatValue],
                                                     [[jsonDict valueForKeyPath:@"tbHeight"] floatValue]);
                    
                    image.imageURL = [NSURL URLWithString:jsonDict[@"url"]];
                    image.imageSize = CGSizeMake([[jsonDict valueForKeyPath:@"width"] floatValue],[[jsonDict valueForKeyPath:@"height"] floatValue]);
                    [imageArray addObject:image];
                }
                NSLog(@"imageArray = %@", imageArray);
                successBlock(imageArray);
            }
        } else {
            NSLog(@"%@", error.description);
            errorBlock(error);
        }
    }];
    [task resume];
}

#pragma mark - Download Images
- (void)downloadImageWithURL:(NSURL *)url completionHandler:(void (^)(UIImage *, NSError *))completionBlock{
    NSURLSessionDownloadTask *imageDownloadTask = [[NSURLSession sharedSession]
                                                   downloadTaskWithURL:url
                                                   completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                       if (!error) {
                                                           UIImage *downloadedImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
                                                           completionBlock(downloadedImage, nil);
                                                       } else {
                                                           completionBlock(nil, error);
                                                       }
                                                       
                                                   }];
    [imageDownloadTask resume];
}

@end
