//
//  DirectShowImageBrowser.h
//  WebKitCorePlam
//
//  Created by AppCan on 12-4-12.
//  Copyright 2012 AppCan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Three20.h" 

@class AppImagePicker;

@interface DirectShowImageBrowser : TTPhotoViewController {
	NSMutableArray *ImageUrlSet;
	NSInteger _startIndex;
    NSInteger isDelete;
    AppImagePicker *m_AppImagePicker;
}

@property(nonatomic) NSInteger isDelete;
@property(nonatomic) NSInteger _startIndex;
@property(nonatomic, retain)NSMutableArray *ImageUrlSet;
@property(nonatomic, assign)AppImagePicker *m_AppImagePicker;

@end
