//
//  Image.h
//  PhotoLibrary
//
//  Created by Suhit on 28/12/14.
//  Copyright (c) 2014 com.suhit. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface Image : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *details;

@property (nonatomic, strong) NSURL *thumbnailURL;
@property (nonatomic, assign) CGSize thumbnailSize;

@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, assign) CGSize imageSize;

@end
