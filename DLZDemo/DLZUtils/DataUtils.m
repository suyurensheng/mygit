//
//  DataUtils.m
//  Doctor_Square
//
//  Created by 董力祯 on 16/5/5.
//  Copyright © 2016年 董力祯. All rights reserved.
//

#import "DataUtils.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
// 获取当前设备可用内存及所占内存的头文件
#import <sys/sysctl.h>
#import <mach/mach.h>
@interface DataUtils ()

@end
@implementation DataUtils

+(id)sharedDataUtils{

    static DataUtils *_shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared=[[DataUtils alloc]init];
    });
    return _shared;
}

+(void)writeData:(id)data WithName:(NSString*)name{
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:name];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

+(id)readDataWithName:(NSString *)name{
    
    if (!name.length) {
        return nil;
    }
    return [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:name]];
}

+(void)deleteDataWithName:(NSString *)name{
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:name];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+(void)getAlbumImages:(void(^)(NSArray *requestArray,ErrorEntity *error))back{
    
    NSMutableArray *backArray=[[NSMutableArray alloc]init];
    
    ALAssetsLibraryAccessFailureBlock failureblock = ^(NSError *myerror){
        NSString *message;
        if ([myerror.localizedDescription rangeOfString:@"Global denied access"].location!=NSNotFound) {
            message=@"无法访问相册.请在'设置->定位服务'设置为打开状态.";
        }else{
            message=@"相册访问失败.";
        }
        back(nil,[ErrorEntity errorInfoWithCode:myerror.code message:message]);
    };
    
    ALAssetsGroupEnumerationResultsBlock groupEnumerAtion = ^(ALAsset *result,NSUInteger index, BOOL *stop){
        
        
        if (result!=NULL) {
            
            if ([[result valueForProperty:ALAssetPropertyType]isEqualToString:ALAssetTypePhoto]) {
                
                NSString *urlstr=[NSString stringWithFormat:@"%@",result.defaultRepresentation.url];//图片的url
                /*result.defaultRepresentation.fullScreenImage//图片的大图
                 result.thumbnail                            //图片的缩略图小图
                 //                    NSRange range1=[urlstr rangeOfString:@"id="];
                 //                    NSString *resultName=[urlstr substringFromIndex:range1.location+3];
                 //                    resultName=[resultName stringByReplacingOccurrencesOfString:@"&ext=" withString:@"."];//格式demo:123456.png
                 */
                
                [[(NSDictionary*)[backArray lastObject] objectForKey:@"data"] addObject:urlstr];
            }
        }
    };
    
    ALAssetsLibraryGroupsEnumerationResultsBlock libraryGroupsEnumeration = ^(ALAssetsGroup* group,BOOL* stop){
        
        if (group!=nil) {
            if (group.numberOfAssets!=0) {
                NSString *g=[NSString stringWithFormat:@"%@",group];//获取相簿的组
                //                NSLog(@"gg:%@",g);//gg:ALAssetsGroup - Name:Camera Roll, Type:Saved Photos, Assets count:71
                
                NSString *groupName=[[[[g substringFromIndex:16] componentsSeparatedByString:@","] objectAtIndex:0] substringFromIndex:5];
//                if (![groupName isEqualToString:@"My Photo Stream"]&&![groupName isEqualToString:@"我的照片流"]) {
//                    //构建数组
//                    NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
//                    [dic setObject:groupName forKey:@"name"];
//                    NSMutableArray *imageArray=[[NSMutableArray alloc] init];
//                    [dic setObject:imageArray forKey:@"data"];
//                    [backArray addObject:dic];
//                    [group enumerateAssetsUsingBlock:groupEnumerAtion];
//                    if (((NSArray*)[[backArray lastObject] objectForKey:@"data"]).count==0) {
//                        [backArray removeLastObject];
//                    }
//                }
                if ([groupName isEqualToString:@"All Photos"] || [groupName isEqualToString:@"所有照片"]||[groupName isEqualToString:@"Camera Roll"]||[groupName isEqualToString:@"相机胶卷"]) {
                    //构建数组
                    NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
                    [dic setObject:groupName forKey:@"name"];
                    NSMutableArray *imageArray=[[NSMutableArray alloc] init];
                    [dic setObject:imageArray forKey:@"data"];
                    [backArray addObject:dic];
                    [group enumerateAssetsUsingBlock:groupEnumerAtion];
                    if (((NSArray*)[[backArray lastObject] objectForKey:@"data"]).count==0) {
                        [backArray removeLastObject];
                    }
                }
            }
        }else{
            
            back(backArray,[ErrorEntity errorInfoWithCode:0 message:nil]);
        }
    };
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:libraryGroupsEnumeration failureBlock:failureblock];
}

+(void)getAlbumDatas:(void (^)(NSArray *))complete{

    // 1.判断相册是否可以打开
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        complete(nil);
        return;
    }
    PHFetchResult<PHAssetCollection *> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    // 遍历所有的自定义相簿
    for (PHAssetCollection *assetCollection in assetCollections) {
        [self enumerateAssetsInAssetCollection:assetCollection original:YES];
    }
    
    // 获得相机胶卷
    PHAssetCollection *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
    // 遍历相机胶卷,获取大图
    [self enumerateAssetsInAssetCollection:cameraRoll original:YES];
}
+ (void)enumerateAssetsInAssetCollection:(PHAssetCollection *)assetCollection original:(BOOL)original{
    
    NSLog(@"相簿名:%@", assetCollection.localizedTitle);
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    // 同步获得图片, 只会返回1张图片
    options.synchronous = YES;
    
    // 获得某个相簿中的所有PHAsset对象
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
    for (PHAsset *asset in assets) {
        // 是否要原图
        CGSize size = original ? CGSizeMake(asset.pixelWidth, asset.pixelHeight) : CGSizeZero;
        
        // 从asset中获得图片
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            NSLog(@"%@", result);
        }];
    }
}

-(void)loadImageGetViewWithTarget:(id)target source:(ImageGetSource)source{

    _target=target;
    _source=source;
    
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    if (_source==ImageGetSourceCamera) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }else{
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    picker.delegate=self;
    if ([target isKindOfClass:[UIViewController class]]) {
        [target presentViewController:picker animated:YES completion:nil];
    }else{
        for (UIView* next = [target superview]; next; next = next.superview) {
                UIResponder *nextResponder = [next nextResponder];
                if ([nextResponder isKindOfClass:[UIViewController class]]) {
                    [(UIViewController *)nextResponder presentViewController:picker animated:YES completion:nil];
                    break;
                }
            }
    }
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *image=info[UIImagePickerControllerOriginalImage];
    if (image) {
        image=[ApplicationUtils fixOrientation:image];
        if ([_target isKindOfClass:[UIViewController class]]) {
            [_target dismissViewControllerAnimated:YES completion:nil];
        }else{
            for (UIView* next = [_target superview]; next; next = next.superview) {
                UIResponder *nextResponder = [next nextResponder];
                if ([nextResponder isKindOfClass:[UIViewController class]]) {
                    [(UIViewController *)nextResponder dismissViewControllerAnimated:YES completion:nil];
                    break;
                }
            }
        }
        if (_target&&[_target respondsToSelector:@selector(imageGetViewDidFinishedWithImage:source:)]) {
            [_target imageGetViewDidFinishedWithImage:image source:_source];
        }
    }else{
        if (_target&&[_target respondsToSelector:@selector(imageGetViewDidFail:)]) {
            [_target imageGetViewDidFail:[ErrorEntity errorInfoWithCode:101 message:@"未知错误"]];
        }
    }
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{

    if (_target&&[_target respondsToSelector:@selector(imageGetViewDidCancel)]) {
        [_target imageGetViewDidCancel];
    }
}
-(void)getMemoryStatus:(void (^)(double, double))status{
    
    NSTimeInterval period = 1.0; //设置时间间隔
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    //    dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, 3*NSEC_PER_SEC);
    dispatch_time_t time=dispatch_walltime(NULL, 3);
    
    dispatch_source_set_timer(_timer, time, period * NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{//在这里执行事件
        
        double available=0;
        vm_statistics_data_t vmStats;
        mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
        kern_return_t kernReturn = host_statistics(mach_host_self(),
                                                   HOST_VM_INFO,
                                                   (host_info_t)&vmStats,
                                                   &infoCount);
        
        if (kernReturn == KERN_SUCCESS){
            available=((vm_page_size *vmStats.free_count) / 1024.0) / 1024.0;
        }
        
        
        double used=0;
        task_basic_info_data_t taskInfo;
        infoCount = TASK_BASIC_INFO_COUNT;
        kernReturn = task_info(mach_task_self(),
                               TASK_BASIC_INFO,
                               (task_info_t)&taskInfo,
                               &infoCount);
        
        
        if (kernReturn == KERN_SUCCESS){
            used=(taskInfo.resident_size / 1024.0 / 1024.0);
        }
        status(available,used);
        
    });
    dispatch_resume(_timer);
    [self performSelector:@selector(cancelTime) withObject:nil afterDelay:60];
}
-(void)cancelTime{
    dispatch_source_cancel(_timer);
}
@end
