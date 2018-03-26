//
//  ApplicationUtils.h
//  美图聊聊
//
//  Created by 董力祯 on 15/4/21.
//  Copyright (c) 2015年 MTLL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Commdefine.h"

@interface ApplicationUtils : NSObject

#pragma mark-添加下划线

+(UIView*)addLineWithFrame:(CGRect)frame andSuperView:(UIView*)superView;


#pragma mark-时间相关

/**获取当前时间*/
+(NSString*)getCurrentTime;

/**计算时间间隔*/
+(NSInteger)timetriverTime1:(NSString*)time1 Time2:(NSString*)time2;

/**根据标准时间字符串获取时间*/
+(NSDate*)getDateWithTimeStr:(NSString*)timeStr;

/**根据标准时间获取时间字符串*/
+(NSString*)getTimeStrFromDate:(NSDate*)date;

/**标准化格式时间(从一个标准到另一个标准)*/
+(NSString*)formatTime:(NSString *)time fromFormat:(NSString*)format1 toFormat:(NSString*)format2;

/**根据时间获取周数 1234567*/
+(NSInteger)getWeekWithStaticTime:(NSString*)timeStr;

/**根据日期获取某年当月的天数 timeStr为：20100101000000，*/
+(NSInteger)getDaysForMonthWIthStaticTime:(NSString*)timeStr;

/**根据时间戳获得标准时间  timeStamp为秒数*/
+(NSString*)getDateSinceTimeStamp:(double)timeStamp;

/**把标准时间字符串转化成特定标准*/
+(NSString*)formatStaticTime:(NSString*)timer toFormater:(NSString*)toFormater;


#pragma mark-数据转化

/**将字典转换为JSON字符串*/
+ (NSString*)objectToJson:(id)object;

/**将json字符串转化为数据*/
+(id)jsonToValueWithString:(NSString*)jsonStr;


#pragma mark-文字适配
/**
 *size 传入（weight，height）两个值，确定的传入确定的值，需要获得的传0；
 *text 要计算的字符串
 *font 字符串字号
 */
+(CGSize)CGSizeWithSize:(CGSize)size andText:(NSString*)text andFont:(UIFont*)font;


#pragma mark-输入判断

/**判断手机号是否规范*/
+(BOOL)checkThePhoneNum:(NSString*)phoneNum;

/**判断邮箱是否规范*/
+(BOOL)checkTheEmailStr:(NSString*)email;

/**判断身份证号是否规范*/
+(BOOL)checkTheIdentityCard:(NSString *)IdentityCard;

/**判断银行卡号是否规范*/
+(BOOL)checkTheBankCard:(NSString *)bankCard;

#pragma mark-遍历文件夹获得文件夹大小，返回多少M

+(CGFloat)folderSizeWithPath:(NSString*)path;

+(long long)fileSizeAtPath:(NSString*) filePath;

#pragma mark-去除表情符号

+(BOOL)hasEmoji:(NSString*)text;

+(NSString *)disable_emoji:(NSString *)text;


#pragma mark-相机、相册权限提示

/**判断是否有相机权限，有的话返回空，没有的话显示提示*/
+(NSString*)haveCaptureRoot;

/**判断是否有相册权限，有的话返回空，没有的话显示提示*/
+(NSString *)haveLibraryRoot;


#pragma mark-杀死app

+(void)crash;


#pragma mark-三方软件判断与调起

+(BOOL)appIsInstallWithKey:(NSString*)key;

+(void)openAppWithSchemKey:(NSString*)key;


#pragma mark-将image压缩、拉伸、颜色生成

/**将image压缩*/
+(UIImage*)scaleFromImage:(UIImage *)image toSize:(CGSize)size;

/**将image拉伸*/
+ (UIImage *)resizeableImage:(UIImage *)image withEdge: (UIEdgeInsets)edgeset;

/**颜色值转换成图片*/
+(UIImage*)createImageWithColor:(UIColor*)color;

/**把view转换成图片*/
+(UIImage*)createImageFromView:(UIView *)view;

/**截取图片的一部分*/
+(UIImage *)clipImage:(UIImage*)image inRect:(CGRect)rect;

#pragma mark-sha1加密

+(NSString*)sha1:(NSString*)string;

#pragma mark-图片方向纠正
+ (UIImage*)fixOrientation:(UIImage*)aImage;


#pragma mark - 修改webview的agent

+(void)changeTheWebUserAgent:(NSString*)agent;

#pragma mark - 旋转和停止view
+(void)rotateView:(UIView *)view;
+(void)stopView:(UIView *)view;

+(NSString*)getRandomString:(NSInteger)length;
@end
