//
//  ImageBrowserViewController.h
//  WebKitCorePlam
//
//  Created by yang fan on 11-12-2.
//  Copyright 2011 zywx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Three20.h"

@interface ImageBrowserViewController : TTThumbsViewController {
	NSMutableArray *ImageUrlSet;
}
@property(nonatomic, retain)NSMutableArray *ImageUrlSet;
@end
