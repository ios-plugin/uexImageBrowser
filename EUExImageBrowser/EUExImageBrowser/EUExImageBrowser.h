//
//  EUExImageBrowser.h
//  AppCan
//
//  Created by AppCan on 11-11-23.
//  Copyright 2011 AppCan. All rights reserved.
//
//#define UEX_PLATFORM_CALL_ARGS		5
//json,text,int
#define IB_CALLBACK_DATATYPE_TEXT	0
//#define IB_CALLBACK_DATATYPE_JSON	1
 #define IB_CALLBACK_DATATYPE_INT	2
//const true/false
#define IB_CTRUE				1
#define IB_CFALSE				0
//success failed
#define IB_CSUCCESS			0
#define IB_CFAILED			1
//define error destribution
#define  ERROR_IB_ARGS				@"参数错误"
#define  ERROR_IB_FILE_EXIST		@"文件不存在"
#define  ERROR_IB_FILE_FORMAT		@"文件格式错误"
#define  ERROR_IB_FILE_OPEN		@"文件未打开错误"
#define  ERROR_IB_FILE_SAVE		@"保存文件失败"
#define  ERROR_IB_STORAGE_DEVICE   @"存储设备错误"
#define  ERROR_IB_FILE_TOO_LARGE   @"文件过大"
#define  ERROR_IB_DEVICE_SUPPORT   @"设备不支持错误"
#define  ERROR_IB_CONFIG			@"config文件未配置"

#import <Foundation/Foundation.h>
#import "EUExBase.h"
#import "DeviceImagePicker.h"
#import "AppImagePicker.h"
#import <UIKit/UIKit.h>
#import "QBImagePickerController.h"
@interface EUExImageBrowser : EUExBase<QBImagePickerControllerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>{
	DeviceImagePicker *dImageObj;
	AppImagePicker *aImageObj;
    NSMutableArray *pathArray;
    UIStatusBarStyle initialStatusBarStyle;
    NSMutableArray *photosMultipleArray;
    NSString *str;
}

@property (nonatomic,retain)NSMutableArray *pathArray;
@property (nonatomic,assign)UIStatusBarStyle initialStatusBarStyle;
@property(nonatomic,retain)NSMutableArray *photosMultipleArray;
@property(nonatomic,copy) NSString* str;
-(void)uexImageBrowserPickerWithOpId:(int)inOpId dataType:(int)inDataType data:(NSString*)inData;
-(void)close:(NSMutableArray *)array;
@end
