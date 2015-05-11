//
//  DeviceImagePicker.h
//  AppCan
//
//  Created by AppCan on 11-11-23.
//  Copyright 2011 AppCan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageBrowserViewController.h"
@class EUExImageBrowser;
@interface AppImagePicker : NSObject {
	EUExImageBrowser *euexObj;
	UINavigationController *nav;
}

@property(nonatomic, assign)EUExImageBrowser *euexObj;
@property(nonatomic, retain)UINavigationController *nav;

-(id)initWithEuex:(EUExImageBrowser *)euexObj_;
-(void)openImageBrowserWithSet:(NSMutableArray *)imageSet startIndex:(int)sIndex showFlag:(int)sFlag isDelete:(NSInteger)isDelete;
-(void)backButtonClickHandle;
-(void)deleteCallBack:(NSString *)url;

@end
