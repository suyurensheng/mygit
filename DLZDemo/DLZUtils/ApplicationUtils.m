//
//  ApplicationUtils.m
//  美图聊聊
//
//  Created by 董力祯 on 15/4/21.
//  Copyright (c) 2015年 MTLL. All rights reserved.
//

#import "ApplicationUtils.h"
#import <AVFoundation/AVFoundation.h>
#import <MapKit/MapKit.h>
#import <CommonCrypto/CommonDigest.h>
#import <CoreText/CoreText.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "DataUtils.h"


@implementation ApplicationUtils

+(UIView*)addLineWithFrame:(CGRect)frame andSuperView:(UIView *)superView{

    UIView *view=[[UIView alloc]initWithFrame:frame];
    view.backgroundColor=XRGB(cc,cc,cc);
    [superView addSubview:view];
    return view;
}



static NSDateFormatter *formater;
static NSString *dateFormatString=@"yyyyMMddHHmmss";

+(NSString*)getCurrentTime{
    
    if (!formater) {
        formater=[[NSDateFormatter alloc]init];
    }
    [formater setDateFormat:dateFormatString];
    return [formater  stringFromDate:[NSDate date]];
}

+(NSInteger)timetriverTime1:(NSString*)time1 Time2:(NSString*)time2{
    
    if (!formater) {
        formater=[[NSDateFormatter alloc]init];
    }
    [formater setDateFormat:dateFormatString];
    NSDate *earlydate=[formater dateFromString:time1];
    NSDate *latterdate=[formater dateFromString:time2];
    NSTimeInterval time=[latterdate timeIntervalSinceDate:earlydate];
    return time;
}

+(NSDate*)getDateWithTimeStr:(NSString *)timeStr{
    if (!formater) {
        formater=[[NSDateFormatter alloc]init];
    }
    [formater setDateFormat:dateFormatString];
    return [formater dateFromString:timeStr];
}

+(NSString*)getTimeStrFromDate:(NSDate *)date{

    if (!formater) {
        formater=[[NSDateFormatter alloc]init];
    }
    [formater setDateFormat:dateFormatString];
    return [formater stringFromDate:date];
}

+(NSString*)formatTime:(NSString *)time fromFormat:(NSString*)format1 toFormat:(NSString*)format2{
    
    if (!formater) {
        formater=[[NSDateFormatter alloc]init];
    }
    [formater setDateFormat:format1];
    NSDate *date=[formater dateFromString:time];
    [formater setDateFormat:format2];
    return [formater stringFromDate:date];
}

+(NSInteger)getWeekWithStaticTime:(NSString*)timeStr{//1234567
    
    if (!formater) {
        formater=[[NSDateFormatter alloc]init];
    }
    [formater setDateFormat:dateFormatString];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSTimeZone *timeZone = [NSTimeZone defaultTimeZone];
    [calendar setTimeZone: timeZone];
    NSCalendarUnit calendarUnit = NSCalendarUnitWeekday;
    NSDateComponents *theComponents = [calendar components:calendarUnit fromDate:[formater dateFromString:timeStr]];
    if (theComponents.weekday==1) {
        return 7;
    }
    return theComponents.weekday-1;
}

+(NSInteger)getDaysForMonthWIthStaticTime:(NSString *)timeStr{
    NSInteger month=[[timeStr substringWithRange:NSMakeRange(4, 2)] integerValue];
    if (month==1||month==3||month==5||month==7||month==8||month==10||month==12) {
        return 31;
    }else if(month==2){
        NSInteger year=[[timeStr substringWithRange:NSMakeRange(0, 4)] integerValue];
        if ((year%100==0&&year%400==0)||(year%100!=0&&year%4==0)) {
            return 29;
        }else{
            return 28;
        }
    }else{
        return 30;
    }
    return 0;
}

+(NSString*)getDateSinceTimeStamp:(double)timeStamp{
    if (!formater) {
        formater=[[NSDateFormatter alloc]init];
    }
    [formater setDateFormat:dateFormatString];
    NSDate *date=[NSDate dateWithTimeIntervalSince1970:timeStamp];
    return [formater stringFromDate:date];
}

+(NSString*)formatStaticTime:(NSString *)timer toFormater:(NSString *)toFormater{
    if (!formater) {
        formater=[[NSDateFormatter alloc]init];
    }
    [formater setDateFormat:dateFormatString];
    NSDate *date=[formater dateFromString:timer];
    [formater setDateFormat:toFormater];
    NSString *backstr=[formater stringFromDate:date];
    return backstr;
}


#pragma mark ----


+ (NSString*)objectToJson:(id)object{
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:nil];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+(id)jsonToValueWithString:(NSString *)jsonStr{

    id  responsObject=[NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    
    return responsObject;
}


+(CGSize)CGSizeWithSize:(CGSize)size andText:(NSString*)text andFont:(UIFont*)font{
    
    if (!text.length) {
        return size;
    }
    CGSize lastSize=CGSizeZero;
    if (size.width==0) {
        lastSize=CGSizeMake(CGFLOAT_MAX, size.height);
    }
    if (size.height==0) {
        lastSize=CGSizeMake(size.width, CGFLOAT_MAX);
    }
    size=[text boundingRectWithSize:lastSize options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:[NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil] context:NULL].size;
    size.height+=1;
    
    return size;
}

+(CGFloat)folderSizeWithPath:(NSString*)path{

    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:path]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:path] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [path stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize/(1024.0*1024.0);
}

+(long long)fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager new];// default is not thread safe
    
    long long filesize=0;
    if ([manager fileExistsAtPath:filePath]){
        NSError *error = nil;
        NSDictionary *dic=[manager attributesOfItemAtPath:filePath error:&error];
        if (!error&&dic) {
            filesize=[dic fileSize];
        }
    }
    return filesize;
}

+(BOOL)isEmoji:(NSString *)text{

    const unichar hs = [text characterAtIndex: 0];
    if (0xd800 <= hs && hs <= 0xdbff) {
        if (text.length > 1) {
            const unichar ls = [text characterAtIndex:1];
            const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
            if (0x1d000 <= uc && uc <= 0x1f77f) {
                return YES;
            }
        }
    } else if (text.length > 1) {
        const unichar ls = [text characterAtIndex:1];
        if (ls == 0x20e3) {
            return YES;
        }
    }
    return NO;
}
+(BOOL)hasEmoji:(NSString *)text{
    __block BOOL returnValue = NO;
    
    [text enumerateSubstringsInRange:NSMakeRange(0, [text length])
                             options:NSStringEnumerationByComposedCharacterSequences
                          usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                              if ([self isEmoji:substring]) {
                                  returnValue = YES;
                              }                              
                          }];
    return returnValue;
}

+(NSString *)disable_emoji:(NSString *)text{
    
    NSMutableString* __block modifiedString = [NSMutableString stringWithCapacity:[text length]];
    
    [text enumerateSubstringsInRange:NSMakeRange(0, [text length])
                             options:NSStringEnumerationByComposedCharacterSequences
                          usingBlock: ^(NSString* substring, NSRange substringRange, NSRange enclosingRange, BOOL* stop) {
                              [modifiedString appendString:([self isEmoji:substring])? @"": substring];
                          }];
    return modifiedString;
}

+(NSString*)haveCaptureRoot{

    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        return @"您还没有相机权限,请设置后重试";
    }
    return @"";
}

+(NSString *)haveLibraryRoot{
    
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if(author == kCLAuthorizationStatusRestricted || author == kCLAuthorizationStatusDenied){//无权限
        return @"您还没有相册权限,请设置后重试";
    }
    return @"";
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


+(BOOL)checkThePhoneNum:(NSString*)phoneNum{
    
    if (phoneNum.length!=11) {
        return NO;
    }
    NSString *phoneRegex = @"^((13[0-9])|(15[0-9])|(18[0,0-9])|(145)|(147)|(17[0,6,7,8]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    BOOL isNum=[phoneTest evaluateWithObject:phoneNum];
    return isNum;
}

+(BOOL)checkTheEmailStr:(NSString*)email{
    
    NSString *emailRegex=@"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.(com|net|org|int|info|edu|gov|top|biz|cc|mil|bi|pro|name|coop|aero|travel|asia|jobs|mobi|tel|tv|ac|am|bz|cn|cx|hk|jp|tw|vc|vn|ru|nz|es|fr|ae|au|it|sg|in|ru|de|vn|mn|)"; //Modified by C.Z
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"SELF MATCHES %@",emailRegex];
    BOOL isEmail=[predicate evaluateWithObject:email];
    return isEmail;
}
+(BOOL)checkTheIdentityCard:(NSString *)IdentityCard{

    if (IdentityCard.length != 18) return NO;
    // 正则表达式判断基本 身份证号是否满足格式
    NSString *regex2 = @"^(^[1-9]\\d{7}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}$)|(^[1-9]\\d{5}[1-9]\\d{3}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])((\\d{4})|\\d{3}[Xx])$)$";
    NSPredicate *identityStringPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    //如果通过该验证，说明身份证格式正确，但准确性还需计算
    if(![identityStringPredicate evaluateWithObject:IdentityCard]) return NO;
    //** 开始进行校验 *//
    //将前17位加权因子保存在数组里
    NSArray *idCardWiArray = @[@"7", @"9", @"10", @"5", @"8", @"4", @"2", @"1", @"6", @"3", @"7", @"9", @"10", @"5", @"8", @"4", @"2"];
    //这是除以11后，可能产生的11位余数、验证码，也保存成数组
    NSArray *idCardYArray = @[@"1", @"0", @"10", @"9", @"8", @"7", @"6", @"5", @"4", @"3", @"2"];
    //用来保存前17位各自乖以加权因子后的总和
    NSInteger idCardWiSum = 0;
    for(int i = 0;i < 17;i++) {
        NSInteger subStrIndex  = [[IdentityCard substringWithRange:NSMakeRange(i, 1)] integerValue];
        NSInteger idCardWiIndex = [[idCardWiArray objectAtIndex:i] integerValue];
        idCardWiSum      += subStrIndex * idCardWiIndex;
    }
    //计算出校验码所在数组的位置
    NSInteger idCardMod=idCardWiSum%11;
    //得到最后一位身份证号码
    NSString *idCardLast= [IdentityCard substringWithRange:NSMakeRange(17, 1)];
    //如果等于2，则说明校验码是10，身份证号码最后一位应该是X
    if(idCardMod==2) {
        if(![idCardLast isEqualToString:@"X"]||[idCardLast isEqualToString:@"x"]) {
            return NO;
        }
    }else{
        //用计算出的验证码与最后一位身份证号码匹配，如果一致，说明通过，否则是无效的身份证号码
        if(![idCardLast isEqualToString: [idCardYArray objectAtIndex:idCardMod]]) {
            return NO;
        }
    }
    return YES;
}

+(BOOL)checkTheBankCard:(NSString *)bankCard{

    if(bankCard.length==0){
        return NO;
    }
    NSString *digitsOnly = @"";
    char c;
    for (int i = 0; i < bankCard.length; i++){
        c = [bankCard characterAtIndex:i];
        if (isdigit(c)){
            digitsOnly =[digitsOnly stringByAppendingFormat:@"%c",c];
        }
    }
    int sum = 0;
    int digit = 0;
    int addend = 0;
    BOOL timesTwo = false;
    for (NSInteger i = digitsOnly.length - 1; i >= 0; i--){
        digit = [digitsOnly characterAtIndex:i] - '0';
        if (timesTwo){
            addend = digit * 2;
            if (addend > 9) {
                addend -= 9;
            }
        }
        else {
            addend = digit;
        }
        sum += addend;
        timesTwo = !timesTwo;
    }
    int modulus = sum % 10;
    return modulus == 0;
}
+(void)crash{
    NSArray *array=[[NSMutableArray alloc]init];
    [array objectAtIndex:1];
}

+(UIImage*)scaleFromImage:(UIImage *)image toSize:(CGSize)size{
    
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)resizeableImage:(UIImage *)image withEdge: (UIEdgeInsets)edgeset{

   return  [image resizableImageWithCapInsets:edgeset resizingMode:UIImageResizingModeTile];
}

+ (UIImage*) createImageWithColor:(UIColor*)color{
    
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage*theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+(BOOL)appIsInstallWithKey:(NSString*)key{

  return  [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://",key]]];
}

+(void)openAppWithSchemKey:(NSString *)key{

    [[UIApplication sharedApplication] openURL:[NSURL   URLWithString:[NSString stringWithFormat:@"%@://",key]]];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+(NSString*)sha1:(NSString *)string{

    const char *cstr = [string cStringUsingEncoding:NSUTF8StringEncoding];
    
    NSData *data = [NSData dataWithBytes:cstr length:string.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (unsigned int)data.length, digest);
    
    NSMutableString *outputStr = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i=0; i<CC_SHA1_DIGEST_LENGTH; i++) {
        
        [outputStr appendFormat:@"%02x", digest[i]];
    }
    return outputStr;
}
+(UIImage*)createImageFromView:(UIView *)view{
    
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return viewImage;
}
+(UIImage*)clipImage:(UIImage *)image inRect:(CGRect)rect{

    if ((rect.origin.x+rect.size.width<=image.size.width)&&(rect.origin.y+rect.size.height)<image.size.height) {
        CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
        UIImage *thumbScale = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        return thumbScale;
    }
    return image;
}

+(UIImage *)fixOrientation:(UIImage *)aImage {
    
    
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

+(void)changeTheWebUserAgent:(NSString *)agent{

    /**获取浏览器的ua*/
    NSString* userAgent = [[[UIWebView alloc] initWithFrame:CGRectZero] stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    [DataUtils writeData:userAgent WithName:@"ua_history"];
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent" : agent, @"User-Agent" : agent}];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(void)rotateView:(UIView *)view{
    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI*2.0];
    rotationAnimation.duration = 1;
    rotationAnimation.repeatCount = HUGE_VALF;
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}
+(void)stopView:(UIView *)view{
    [view.layer removeAllAnimations];//停止动画
}
+(NSString*)getRandomString:(NSInteger)length{
    NSString *string = [[NSString alloc]init];
    for (int i = 0; i < length; i++) {
        int number = arc4random() % 36;
        if (number < 10) {
            int figure = arc4random() % 10;
            NSString *tempString = [NSString stringWithFormat:@"%d", figure];
            string = [string stringByAppendingString:tempString];
        }else {
            int figure = (arc4random() % 26) + 97;
            char character = figure;
            NSString *tempString = [NSString stringWithFormat:@"%c", character];
            string = [string stringByAppendingString:tempString];
        }
    }
    return string;
}

@end
