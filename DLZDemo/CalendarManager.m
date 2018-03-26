//
//  CalendarManager.m
//  DLZDemo
//
//  Created by 董力祯 on 2018/2/23.
//  Copyright © 2018年 董力祯. All rights reserved.
//

#import "CalendarManager.h"
#import <EventKit/EventKit.h>

@implementation CalendarManager

static CalendarManager *_calendarManager;
+(instancetype)sharedCalendarManager{
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        _calendarManager=[[CalendarManager alloc] init];
    });
    return _calendarManager;
}
-(void)creatCalendarEventWithTitle:(NSString *)title content:(NSString *)content startTime:(NSString *)startTime endTime:(NSString *)endTime alertTimes:(NSArray *)times complete:(void (^)(NSString *))complete{
    
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    if ([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]){
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error){
                    complete(@"添加失败，请稍后重试");
                }else if (!granted){
                    complete(@"不允许使用日历,请在设置中允许此App使用日历");
                }else{
                    
                    EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
                    event.title     = title;
                    event.location = content;
                    
                    NSDateFormatter *tempFormatter = [[NSDateFormatter alloc]init];
                    [tempFormatter setDateFormat:@"yyyyMMddHHmmss"];
                    
                    event.startDate = [tempFormatter dateFromString:startTime];
                    event.endDate   = [tempFormatter dateFromString:endTime];
                    event.allDay = NO;
                    
                    //添加提醒
                    if (times && times.count > 0) {

                        for (NSString *timeString in times) {
                            [event addAlarm:[EKAlarm alarmWithRelativeOffset:[timeString integerValue]]];
                        }
                    }
                    
                    [event setCalendar:[eventStore defaultCalendarForNewEvents]];
                    NSError *err;
                    [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
                    if (!err) {
                        complete(@"");
                    }else{
                        complete(err.localizedDescription);
                    }
                }
            });
        }];
    }else{
       complete(@"此版本不支持日历功能");
    }
}
@end
