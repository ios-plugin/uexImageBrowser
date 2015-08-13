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
        
        UIImage *checkImg = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSLog(@"**********》》》》》》imageBrower插件----------++++==>>>>>>>>>>图片的方向信息:%ld",(long)checkImg.imageOrientation);
        if (checkImg.imageOrientation==UIImageOrientationUp)
        {
            
        }else if(checkImg.imageOrientation==UIImageOrientationRight)
        {
            
            checkImg = [UIImage imageWithCGImage:checkImg.CGImage scale:1.0 orientation:UIImageOrientationRight];
            checkImg = [self fixOrientation:checkImg];
        }
        
        NSLog(@"%ld",(long)checkImg.imageOrientation);
        
        
        if(self.isLossless){
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            [library assetForURL:[info objectForKey:UIImagePickerControllerReferenceURL]
                     resultBlock:^(ALAsset *asset)
             {
                 //                 ALAssetRepresentation *representation = [asset defaultRepresentation];
                 //                 CGImageRef imgRef = [representation fullResolutionImage];
                 //                 UIImage *image = [UIImage imageWithCGImage:imgRef
                 //                                                      scale:representation.scale
                 //                                                orientation:(UIImageOrientation)representation.orientation];
                 NSData *imageData=UIImageJPEGRepresentation(checkImg,1);
                 [self cbPickWithData:imageData PickerController:picker];
             }failureBlock:^(NSError *error){
                 NSLog(@"cannot get asset:%@",[error localizedDescription]);
             }];
            
            
        }else{
            
            //            UIImage *checkImg= [info objectForKey:UIImagePickerControllerOriginalImage];
            NSData *imageData = UIImageJPEGRepresentation(checkImg,0.6);
            [self cbPickWithData:imageData PickerController:picker];
        }
        
    }
}
///////////////////////////////////////////////////////////
- (UIImage *)fixOrientation:(UIImage *)oImage {
    
    // No-op if the orientation is already correct
    if (oImage.imageOrientation == UIImageOrientationUp) return oImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (oImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, oImage.size.width, oImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, oImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, oImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:break;
    }
    
    switch (oImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, oImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, oImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, oImage.size.width, oImage.size.height,
                                             CGImageGetBitsPerComponent(oImage.CGImage), 0,
                                             CGImageGetColorSpace(oImage.CGImage),
                                             CGImageGetBitmapInfo(oImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (oImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,oImage.size.height,oImage.size.width), oImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,oImage.size.width,oImage.size.height), oImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

///////////////////////////////////////////////////////////

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
        picker.allowsEditing = YES;
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
