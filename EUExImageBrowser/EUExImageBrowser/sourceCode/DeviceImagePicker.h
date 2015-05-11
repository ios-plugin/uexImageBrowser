//
//  DeviceImagePicker.h
//  AppCan
//
//  Created by AppCan on 11-11-24.
//  Copyright 2011 AppCan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class EUExImageBrowser;

@interface DeviceImagePicker : NSObject <UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
	EUExImageBrowser *euexObj;
	UIPopoverController *popController;
}
@property(nonatomic, retain)UIPopoverController *popController;
-(id)initWithEuex:(EUExImageBrowser *)euexObj_;
-(void)openDicm;
@end
