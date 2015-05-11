//
//  SingleImageView.m
//  AppCan
//
//  Created by AppCan on 11-12-14.
//  Copyright 2011 AppCan. All rights reserved.
//

#import "SingleImageView.h"
#import "Three20.h" 
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

@implementation SingleImageView
@synthesize imageURL;
-(void)viewDidLoad{
	[super viewDidLoad];

	MockPhoto *mphoto = [[MockPhoto alloc] initWithURL:imageURL smallURL:imageURL size:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT)];
	self.photoSource = [[[MockPhotoSource alloc] initWithType:MockPhotoSourceNormal
												  startIndex:0
													   title:@"图片"
													  photos:[NSArray arrayWithObject:mphoto]
													 photos2:nil] autorelease];
	[mphoto release]; 
}

-(void)dealloc{
	[imageURL release];
	[super dealloc];
}
@end
