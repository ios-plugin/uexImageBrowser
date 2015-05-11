//
//  ImageBrowserViewController.m
//  WebKitCorePlam
//
//  Created by yang fan on 11-12-2.
//  Copyright 2011 zywx. All rights reserved.
//

#import "ImageBrowserViewController.h"
#import "MockPhotoSource.h"
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
@implementation ImageBrowserViewController
@synthesize ImageUrlSet;

- (void)viewDidLoad {
	[super viewDidLoad];
    if ([[[UIDevice currentDevice] systemVersion] floatValue]<7.0) {
        
    }else{
        self.automaticallyAdjustsScrollViewInsets=NO;
    }
 	NSMutableArray *mkPhotoArray = [[NSMutableArray alloc] initWithCapacity:20];
	for (int i = 0; i<[ImageUrlSet count]; i++) {
		NSString *urlStr = [ImageUrlSet objectAtIndex:i];
		MockPhoto *mPhoto = [[MockPhoto alloc] initWithURL:urlStr smallURL:urlStr size:CGSizeMake(SCREEN_WIDTH,SCREEN_HEIGHT) caption:nil];
		[mkPhotoArray addObject:mPhoto];
		TT_RELEASE_SAFELY(mPhoto);
	}
	self.photoSource = [[[MockPhotoSource alloc]
                         initWithType:MockPhotoSourceNormal
						 startIndex:0
                         title:@"图片"
                         photos:[NSArray arrayWithArray:mkPhotoArray]
                         photos2:nil] autorelease];
	[mkPhotoArray release];
}

-(void)dealloc{
    if (ImageUrlSet) {
        [ImageUrlSet release];
        ImageUrlSet = nil;
    }
	[super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

@end
