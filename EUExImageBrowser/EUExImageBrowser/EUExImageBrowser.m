//
//  EUExImageBrowser.m
//  webKitCorePalm
//
//  Created by zywx on 11-11-23.
//  Copyright 2011 3g2win. All rights reserved.
//

#import "EUExImageBrowser.h"
#import "EUExBase.h"
#import "EUtility.h"


@implementation EUExImageBrowser
@synthesize pathArray;
@synthesize initialStatusBarStyle;
@synthesize photosMultipleArray;
@synthesize str;
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)

#pragma mark - 使用这个插件需要添加 "$(SRCROOT)/../../../IOSPlugin/Plugin/module/imagebrowserplugin/three20"

-(id)initWithBrwView:(EBrowserView *) eInBrwView {
    if (self = [super initWithBrwView:eInBrwView]) {
    }
    return self;
}



-(void)dealloc{
    if (dImageObj) {
        [dImageObj release];
        dImageObj = nil;
    }
    if (aImageObj) {
        [aImageObj release];
        aImageObj = nil;
    }
    if (pathArray) {
        self.PathArray = nil;
    }
    [super dealloc];
}

-(void)clean{
    if (dImageObj) {
        [dImageObj release];
        dImageObj = nil;
    }
    if (aImageObj) {
        [aImageObj release];
        aImageObj = nil;
    }
    if (pathArray) {
        self.PathArray = nil;
    }
}

-(void)close:(NSMutableArray *)array{
    if (dImageObj) {
        [dImageObj release];
        dImageObj = nil;
    }
    if (aImageObj) {
        [aImageObj release];
        aImageObj = nil;
    }
    if (pathArray) {
        self.PathArray = nil;
    }
}

-(void)open:(NSMutableArray *)inArguments{
    NSString *inUrlStr = [[inArguments objectAtIndex:0] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSArray *inImageArr = [inUrlStr componentsSeparatedByString:@","];
    NSString *idxStr = nil;
    NSString *flagStr = nil;
    NSInteger isDelete = 0;
    NSInteger count = [inArguments count];
    if (count >=2) {
        idxStr = [inArguments objectAtIndex:1];
        flagStr = @"1";
    }
    if (3 <= count) {
        idxStr = [inArguments objectAtIndex:1];
        flagStr = [inArguments objectAtIndex:2];
        if (4 == count) {
            isDelete = [[inArguments objectAtIndex:3] integerValue];
        }else{
            isDelete = 0;
        }
    }
    int startIndex = 0;
    if (idxStr){
        startIndex = [idxStr intValue];
    }
    int sFlag = 0;
    if (flagStr) {
        sFlag = [flagStr intValue];
    }
    if (startIndex >= [inImageArr count]) {
        startIndex = 0;
    }
    if (inImageArr && [inImageArr count]>0) {
        self.pathArray = [NSMutableArray arrayWithArray:inImageArr];
        aImageObj = [[AppImagePicker alloc] initWithEuex:self];
        NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:20];
        for (int i = 0; i<[inImageArr count]; i++) {
            NSString *imageURL = [inImageArr objectAtIndex:i];
            if (![imageURL hasPrefix:@"http"]) {
                //本地图片
                imageURL = [super absPath:imageURL];
                NSString *relPath;
                if ([imageURL hasPrefix:@"/private/var"]) {
                    relPath = [imageURL substringFromIndex:[NSHomeDirectory() length]+9];
                }else {
                    relPath = [imageURL substringFromIndex:[NSHomeDirectory() length]+1];
                }
                if ([relPath hasPrefix:@"Documents/"]) {
                    NSString *gPath = [relPath substringFromIndex:10];
                    imageURL = [NSString stringWithFormat:@"documents://%@",gPath];
                }else if ([relPath rangeOfString:@".app/"].length>0) {
                    NSString *gPath = [relPath substringFromIndex:[relPath rangeOfString:@".app"].location+5];
                    imageURL = [NSString stringWithFormat:@"bundle://%@",gPath];
                }else{
                    
                }
            }else {
                //                //网络图片
                NSURL *midUrl = [NSURL URLWithString:imageURL];
                NSURL *stardUrl = [midUrl standardizedURL];
                imageURL = [stardUrl absoluteString];
            }
            [imageArray addObject:imageURL];
        }
        [aImageObj openImageBrowserWithSet:imageArray startIndex:startIndex showFlag:sFlag isDelete:isDelete];
    }else {
        [self jsFailedWithOpId:0 errorCode:1100201 errorDes:ERROR_IB_ARGS];
    }
}

-(void)pick:(NSMutableArray *)inArguments{
    initialStatusBarStyle=[UIApplication sharedApplication].statusBarStyle;
    dImageObj = [[DeviceImagePicker alloc] initWithEuex:self];
    [dImageObj openDicm];
}

-(void)cropImage:(NSMutableArray *)inArguments{
    
    initialStatusBarStyle=[UIApplication sharedApplication].statusBarStyle;
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.allowsEditing = YES;
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.view.tag = 1000;
    [EUtility brwView:meBrwView presentModalViewController:picker animated:YES];
    
}

////*************************
-(void)pickMulti:(NSMutableArray *)inArguments {
    initialStatusBarStyle=[UIApplication sharedApplication].statusBarStyle;
    QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsMultipleSelection = YES;
    NSString *maxCount=nil;
    if ([inArguments isKindOfClass:[NSMutableArray class]]&&[inArguments count]>0) {
        maxCount=[inArguments objectAtIndex:0];
    }
    if (maxCount.length>0){
        imagePickerController.maximumNumberOfSelection=[[inArguments objectAtIndex:0] intValue];
        imagePickerController.limitsMaximumNumberOfSelection=YES;
    }
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
    [EUtility brwView:meBrwView presentModalViewController:navigationController animated:YES];
    [imagePickerController release];
    [navigationController release];
    self.photosMultipleArray=[[NSMutableArray alloc]init];
}
- (void)imagePickerController:(QBImagePickerController *)picker didFinishPickingMediaWithInfo:(id)info
{
    [[UIApplication sharedApplication] setStatusBarStyle:self.initialStatusBarStyle];
    //截取图片并返回
    if(picker.view.tag == 1000) {
        
        UIImage * image = [info objectForKey:UIImagePickerControllerEditedImage];
        NSFileManager *fmanager = [NSFileManager defaultManager];
        NSString *homeDirectory = NSHomeDirectory();
        NSString *tempPath = [homeDirectory stringByAppendingPathComponent:@"Documents/apps"];
        NSString *curAppId = [EUtility brwViewWidgetId:self.meBrwView];
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
        NSData *imageData = UIImageJPEGRepresentation(image,0.8);
        BOOL succ = [imageData writeToFile:imgTmpPath atomically:YES];
        
        [picker dismissViewControllerAnimated:YES completion:^{
            if (succ) {
                NSNumber *statusBarHidden = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"UIStatusBarHidden"];
                if ([statusBarHidden boolValue] == YES) {
                    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
                }else{
                    [[UIApplication sharedApplication] setStatusBarStyle:self.initialStatusBarStyle];
                }
                
                [self jsSuccessWithName:@"uexImageBrowser.cbCropImage" opId:0 dataType:IB_CALLBACK_DATATYPE_TEXT strData:imgTmpPath];
            }
        }];
        
    } else {
        NSArray *mediaInfoArray = (NSArray *)info;
        for (int i=0; i<(int)mediaInfoArray.count;i++) {
            [self.photosMultipleArray addObject:[mediaInfoArray[i] objectForKey:@"UIImagePickerControllerOriginalImage"]];
            UIImage *checkImg = self.photosMultipleArray[i];
            
            {
                NSData *imageData = UIImageJPEGRepresentation(checkImg,0.6);
                NSFileManager *fmanager = [NSFileManager defaultManager];
                //获取程序的根目录
                NSString *homeDirectory = NSHomeDirectory();
                //获取Documents/apps目录的地址
                NSString *tempPath = [homeDirectory stringByAppendingPathComponent:@"Documents/apps"];
                NSString *curAppId = [EUtility brwViewWidgetId:self.meBrwView];
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
                NSLog(@"hui-->uexImageBrowser-->imagePickerController imgTmpPath is %@",imgTmpPath);
                if(i==0){
                    self.str=[NSString stringWithFormat:@"%@",imgTmpPath];
                }else{
                    self.str=[self.str stringByAppendingString:@","];
                    self.str=[self.str stringByAppendingString:imgTmpPath];
                }
                BOOL succ = [imageData writeToFile:imgTmpPath atomically:YES];
                
                [picker dismissViewControllerAnimated:YES completion:^{
                    if (succ) {
                        NSLog(@"hui-->uexImageBrowser-->imagePickerController success");
                        [self uexImageBrowserPickerWithOpId:0 dataType:IB_CALLBACK_DATATYPE_TEXT data:self.str];
                    }
                }];
            }
        }
    }
    
}


- (void)imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController {
    
    [imagePickerController dismissViewControllerAnimated:YES completion:^{
        NSNumber *statusBarHidden = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"UIStatusBarHidden"];
        if ([statusBarHidden boolValue] == YES) {
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        }else{
            [[UIApplication sharedApplication] setStatusBarStyle:self.initialStatusBarStyle];
        }
        
    }];
}


- (NSString *)imagePickerController:(QBImagePickerController *)imagePickerController descriptionForNumberOfPhotos:(NSUInteger)numberOfPhotos
{
    return [NSString stringWithFormat:@"图片%d张", (int)numberOfPhotos];
}

///********************
-(void)save:(NSMutableArray *)inArguments{
    NSString *imgUrl = [inArguments objectAtIndex:0];
    NSString *imagePath = nil;
    UIImage *image;
    //update 07.18
    if (imgUrl) {
        imagePath = [super absPath:imgUrl];
        image = [UIImage imageWithContentsOfFile:imagePath];
        if(image){
            UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
            [self jsSuccessWithName:@"uexImageBrowser.cbSave" opId:0 dataType:IB_CALLBACK_DATATYPE_INT intData:IB_CSUCCESS];
            return;
        }
    }
    [self jsSuccessWithName:@"uexImageBrowser.cbSave" opId:0 dataType:IB_CALLBACK_DATATYPE_INT intData:IB_CFAILED];
}

-(void)cleanCache:(NSMutableArray *)inArguments{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDir = [paths objectAtIndex:0];
    NSString *imageCpath = [cachesDir stringByAppendingPathComponent:@"Three20"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:imageCpath]) {
        if ([fm removeItemAtPath:imageCpath error:nil]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"清除成功" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
        }
    }
}

-(void)uexImageBrowserPickerWithOpId:(int)inOpId dataType:(int)inDataType data:(NSString*)inData{
    inData =[inData stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self jsSuccessWithName:@"uexImageBrowser.cbPick" opId:inOpId dataType:inDataType strData:inData];
}

@end
