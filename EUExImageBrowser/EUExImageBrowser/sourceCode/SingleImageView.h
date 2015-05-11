//
//  SingleImageView.h
//  AppCan
//
//  Created by AppCan on 11-12-14.
//  Copyright 2011 AppCan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Three20.h"
#import "MockPhotoSource.h"
@interface SingleImageView : TTPhotoViewController {
	NSString *imageURL;
}
@property(nonatomic, retain)NSString *imageURL;
@end
