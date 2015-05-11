//
//  DeviceImagePicker.m
//  AppCan
//
//  Created by AppCan on 11-11-23.
//  Copyright 2011 AppCan. All rights reserved.
//

#import "AppImagePicker.h"
#import "EUExImageBrowser.h"
#import "Three20.h"
#import "SingleImageView.h"
#import "MockPhotoSource.h"
#import "DirectShowImageBrowser.h"
#import "EUtility.h"

@implementation AppImagePicker
@synthesize nav,euexObj;

-(id)initWithEuex:(EUExImageBrowser *)euexObj_{
	self.euexObj = euexObj_;
	return self;
}

-(void)backButtonClickHandle {
    
	[nav dismissModalViewControllerAnimated:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:self.euexObj.initialStatusBarStyle];
    if (euexObj) {
        [euexObj close:nil];
    }
    
}

-(void)deleteCallBack:(NSString *)url{
    if (euexObj) {
        if (url) {
            NSString *jsStr = [NSString stringWithFormat:@"uexImageBrowser.cbDeletePath(\"%@\")",url];
            [euexObj.meBrwView stringByEvaluatingJavaScriptFromString:jsStr];
        }
    }
}

-(void)openImageBrowserWithSet:(NSMutableArray *)imageSet startIndex:(int)sIndex showFlag:(int)sFlag isDelete:(NSInteger)isDelete{
	if (1 == [imageSet count] && 0 == isDelete) {
		SingleImageView *sImgView = [[SingleImageView alloc] init];
        sImgView.imageURL = [imageSet objectAtIndex:0];
		nav = [[UINavigationController alloc] initWithRootViewController:sImgView];
		sImgView.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonClickHandle)] autorelease];
         sImgView.navigationItem.leftBarButtonItem.tintColor=[UIColor whiteColor];
		[sImgView release];
	}else {
		if (0 == sFlag) {
			ImageBrowserViewController *photoView = [[ImageBrowserViewController alloc] init];
			photoView.ImageUrlSet = imageSet;
            nav = [[UINavigationController alloc] initWithRootViewController:photoView];
			photoView.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonClickHandle)] autorelease];
            photoView.navigationItem.leftBarButtonItem.tintColor=[UIColor whiteColor];
   
			[photoView release];
		}else {
			DirectShowImageBrowser *dBrw = [[DirectShowImageBrowser alloc] init];
			dBrw.ImageUrlSet = imageSet;
			dBrw._startIndex = sIndex;
            nav = [[UINavigationController alloc] initWithRootViewController:dBrw];
			dBrw.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonClickHandle)] autorelease];
            dBrw.navigationItem.leftBarButtonItem.tintColor=[UIColor whiteColor];
            if (1 == isDelete) {
                dBrw.m_AppImagePicker = self;
                dBrw.isDelete = isDelete;
            }
			[dBrw release];
		}
	}
	[EUtility brwView:euexObj.meBrwView presentModalViewController:nav animated:YES];
  // [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

-(void)dealloc{
	if (nav) {
		[nav release];
		nav = nil;
	}
	[super dealloc];
}
@end
