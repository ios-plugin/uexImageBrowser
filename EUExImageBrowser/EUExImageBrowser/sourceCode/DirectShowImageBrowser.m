//
//  DirectShowImageBrowser.m
//  WebKitCorePlam
//
//  Created by AppCan on 12-4-12.
//  Copyright 2012 AppCan. All rights reserved.
//

#import "DirectShowImageBrowser.h"
#import "MockPhotoSource.h"
#import "AppImagePicker.h"
#import "EUExImageBrowser.h"
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

@implementation DirectShowImageBrowser
@synthesize isDelete;
@synthesize ImageUrlSet;
@synthesize _startIndex;
@synthesize m_AppImagePicker;

- (void)viewDidLoad {
	[super viewDidLoad];
 	NSMutableArray *mkPhotoArray = [[NSMutableArray alloc] initWithCapacity:10];
    
	for (int i = 0; i<[ImageUrlSet count]; i++) {
		NSString *urlStr = [ImageUrlSet objectAtIndex:i];
        
		MockPhoto *mPhoto = [[MockPhoto alloc] initWithURL:urlStr smallURL:urlStr size:CGSizeMake(SCREEN_WIDTH , SCREEN_HEIGHT) caption:nil];
		[mkPhotoArray addObject:mPhoto];
		TT_RELEASE_SAFELY(mPhoto);
	}
	self.photoSource = [[[MockPhotoSource alloc]
                         initWithType:MockPhotoSourceDelayed
						 startIndex:_startIndex
                         title:@"图片"
                         photos:mkPhotoArray
                         photos2:nil] autorelease];
	[mkPhotoArray release];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    if (1 == isDelete) {
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"删除" style:UIBarButtonItemStyleBordered target:self action:@selector(DeleteButtonClickHandle)] autorelease];
    }
}

- (void)DeleteButtonClickHandle{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"要删除这张照片吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    [alert show];
    [alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (1 == buttonIndex) {
        if (ImageUrlSet) {
            NSInteger index = self.centerPhotoIndex;
            if ([ImageUrlSet count] > index) {
                if (m_AppImagePicker) {
                    if (m_AppImagePicker.euexObj.pathArray) {
                        NSString *path = [m_AppImagePicker.euexObj.pathArray objectAtIndex:index];
                        [m_AppImagePicker deleteCallBack:path];
                        [m_AppImagePicker.euexObj.pathArray removeObjectAtIndex:index];
                    }
                }
                [ImageUrlSet removeObjectAtIndex:index];
                if ([ImageUrlSet count]>0) {
                    NSMutableArray *mkPhotoArray = [[NSMutableArray alloc] initWithCapacity:10];
                    for (int i = 0; i<[ImageUrlSet count]; i++) {
                        NSString *urlStr = [ImageUrlSet objectAtIndex:i];
                        MockPhoto *mPhoto = [[MockPhoto alloc] initWithURL:urlStr smallURL:urlStr size:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT) caption:nil];
                        [mkPhotoArray addObject:mPhoto];
                        TT_RELEASE_SAFELY(mPhoto);
                    }
                    
                    NSArray *tempArray = [NSArray arrayWithArray:mkPhotoArray];
                    self.photoSource = [[[MockPhotoSource alloc]
                                         initWithType:MockPhotoSourceDelayed
                                         startIndex:index
                                         title:@"图片"
                                         photos:tempArray
                                         photos2:nil] autorelease];
                    [mkPhotoArray release];
                }else{
                    [self.m_AppImagePicker backButtonClickHandle];
                }
            }
        }
    }
}

- (void)dealloc {
	if (ImageUrlSet) {
		[ImageUrlSet release];
		ImageUrlSet = nil;
	}
	[super dealloc];
}

@end
