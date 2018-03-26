//
//  CalendarManager.h
//  DLZDemo
//
//  Created by 董力祯 on 2018/2/23.
//  Copyright © 2018年 董力祯. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalendarManager : NSObject

+(instancetype)sharedCalendarManager;

/**
 *  将App事件添加到系统日历提醒事项，实现闹铃提醒的功能
 *
 *  @param title      事件标题
 *  @param content   事件内容
 *  @param startTime  开始时间
 *  @param endTime    结束时间
 *  @param allDay     是否全天
 *  @param times 闹钟集合
 *  @param complete     添加结果反馈
 */
-(void)creatCalendarEventWithTitle:(NSString*)title content:(NSString*)content startTime:(NSString*)startTime endTime:(NSString*)endTime alertTimes:(NSArray*)times complete:(void(^)(NSString*errorMessage))complete;
@end
