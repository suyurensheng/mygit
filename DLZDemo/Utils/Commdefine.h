//
//  Commdefine.h
//  DLZDemo
//
//  Created by 董力祯 on 2017/6/15.
//  Copyright © 2017年 董力祯. All rights reserved.
//

#ifndef Commdefine_h
#define Commdefine_h

/**十六进制转化为颜色*/
#define XRGB(r,g,b) [UIColor colorWithRed:(0x##r)/255.0 green:(0x##g)/255.0 blue:(0x##b)/255.0 alpha:1]

/**带透明度的十六进制转化为颜色*/
#define XRGBA(r,g,b,a) [UIColor colorWithRed:(0x##r)/255.0 green:(0x##g)/255.0 blue:(0x##b)/255.0 alpha:(a)]

/**十进制转化为颜色*/
#define DLZColor(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

#define MAIN_SCREAM_WIDTH    [UIScreen mainScreen].bounds.size.width

#define MAIN_SCREAM_HEIGHT  [UIScreen mainScreen].bounds.size.height

#define IOS7      [[[UIDevice currentDevice] systemVersion] floatValue]>=7&&[[[UIDevice currentDevice] systemVersion] floatValue]<8

#define IOS8      [[[UIDevice currentDevice] systemVersion] floatValue]>=8&&[[[UIDevice currentDevice] systemVersion] floatValue]<9

#define IOS9      [[[UIDevice currentDevice] systemVersion] floatValue]>=9&&[[[UIDevice currentDevice] systemVersion] floatValue]<10

#define IOS10    [[[UIDevice currentDevice] systemVersion] floatValue]>=10&&[[[UIDevice currentDevice] systemVersion] floatValue]<11

/**应用版本号*/
#define APPLICATION_VERSON  [[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleShortVersionString"]

#ifdef DEBUG
#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define DLog(...)
#endif

#define IMAGE_SIZE_MAX  1024*400.0f


#endif /* Commdefine_h */
