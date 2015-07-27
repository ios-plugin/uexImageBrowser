//
//  DeviceImagePicker.m
//  AppCan
//
//  Created by AppCan on 11-11-24.
//  Copyright 2011 AppCan. All rights reserved.
//

#import "DeviceImagePicker.h"
#import "EUExImageBrowser.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "EUtility.h"

@implementation DeviceImagePicker
@synthesize popController;

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)

-(id)initWithEuex:(EUExImageBrowser *)euexObj_ isLossless:(BOOL)isLossless{
    self=[super init];
    if(self){
        euexObj = euexObj_;
        self.isLossless=isLossless;
    }
    
    return self;
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    [[UIApplication sharedApplication] setStatusBarStyle:euexObj.initialStatusBarStyle];
    
    if([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"public.image"]){
        
        
        if(self.isLossless){
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            [library assetForURL:[info objectForKey:UIImagePickerControllerReferenceURL]
                     resultBlock:^(ALAsset *asset)
             {
                 ALAssetRepresentation *representation = [asset defaultRepresentation];
                 CGImageRef imgRef = [representation fullResolutionImage];
                 UIImage *image = [UIImage imageWithCGImage:imgRef
                                                      scale:representation.scale
                                                orientation:(UIImageOrientation)representation.orientation];
                 NSData *imageData=UIImageJPEGRepresentation(image,1);
                 [self cbPickWithData:imageData PickerController:picker];
             }failureBlock:^(NSError *error){
                 NSLog(@"cannot get asset:%@",[error localizedDescription]);
             }];
            
            
        }else{
            UIImage *checkImg= [info objectForKey:UIImagePickerControllerOriginalImage];
            NSData *imageData = UIImageJPEGRepresentation(checkImg,0.6);
            [self cbPickWithData:imageData PickerController:picker];
        }
        
    }
}

-(void)cbPickWithData:(NSData*)imageData PickerController:(UIImagePickerController *)picker{
    if (imageData) {
        
        NSFileManager *fmanager = [NSFileManager defaultManager];
        //获取程序的根目录
        NSString *homeDirectory = NSHomeDirectory();
        //获取Documents/apps目录的地址
        NSString *tempPath = [homeDirectory stringByAppendingPathComponent:@"Documents/apps"];
        NSString *curAppId = [EUtility brwViewWidgetId:euexObj.meBrwView];
        NSString *wgtTempPath = [tempPath stringByAppendingPathComponent:curAppId];
        
        if (![fmanager fileExistsAtPath:wgtTempPath]) {
            [fmanager createDirectoryAtPath:wgtTempPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        //picture name
        NSString *timeStr = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSinceReferenceDate]];
        
        NSString *imgName = [NSString stringWithFormat:@"%@.jpg",[timeStr substringFromIndex:([timeStr length]-6)]];
        NSString *imgTmpPath = [wgtTempPath stringByAppendingPathComponent:imgName];
        if ([fmanager fileExistsAtPath:imgTmpPath]) {
            [fmanager removeItemAtPath:imgTmpPath error:nil];
        }
        BOOL succ = [imageData writeToFile:imgTmpPath atomically:YES];
        
        if (320 != SCREEN_WIDTH && [EUtility isIpad]) {
            [popController dismissPopoverAnimated:NO];
            if (succ) {
                [euexObj uexImageBrowserPickerWithOpId:0 dataType:IB_CALLBACK_DATATYPE_TEXT data:imgTmpPath];
            }
        }else {
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
                [picker dismissViewControllerAnimated:NO completion:^{
                    NSNumber *statusBarHidden = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"UIStatusBarHidden"];
                    if ([statusBarHidden boolValue] == YES) {
                        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
                    }
                    
                    if (succ) {
                        [euexObj uexImageBrowserPickerWithOpId:0 dataType:IB_CALLBACK_DATATYPE_TEXT data:imgTmpPath];
                    }
                    [[UIApplication sharedApplication] setStatusBarStyle:euexObj.initialStatusBarStyle];
                }];
                
            }else{
                [picker dismissModalViewControllerAnimated:NO];
                if (succ) {
                    [euexObj uexImageBrowserPickerWithOpId:0 dataType:IB_CALLBACK_DATATYPE_TEXT data:imgTmpPath];
                }
            }
        }
    }
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:NO completion:^{
           [[UIApplication sharedApplication] setStatusBarStyle:euexObj.initialStatusBarStyle];
        NSNumber *statusBarHidden = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"UIStatusBarHidden"];
        if ([statusBarHidden boolValue] == YES) {
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        }
    }];
 }

-(void)openDicm{
   
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
		UIImagePickerController *picker = [[UIImagePickerController alloc] init];
		[picker setDelegate:self];
		[picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
		picker.mediaTypes = [NSArray arrayWithObjects:@"public.image",nil];
		if (320 == SCREEN_WIDTH || ![EUtility isIpad]) {
			[EUtility brwView:euexObj.meBrwView presentModalViewController:picker animated:NO];
		}else {
			UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:picker];
			self.popController = popover;
 			[EUtility brwView:euexObj.meBrwView presentPopover:popController FromRect:CGRectMake(0, 0, 300, 300) permittedArrowDirections:UIPopoverArrowDirectionAny animated:NO];
			[popover release];
		}
		[picker release];
	}else {
		[euexObj jsFailedWithOpId:0 errorCode:1100108 errorDes:ERROR_IB_DEVICE_SUPPORT];
	}
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

}

-(void)dealloc{
	[popController release];
	[super dealloc];
}

@end
