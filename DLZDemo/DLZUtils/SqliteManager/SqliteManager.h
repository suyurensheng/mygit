//
//  SqliteManager.h
//  DLZDemo
//
//  Created by 董力祯 on 2018/3/20.
//  Copyright © 2018年 董力祯. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SqliteManager : NSObject

+(instancetype)sharedSqlite;

-(void)creatTableWithName:(NSString*)name primaryKey:(NSString*)primaryKey  otherKeys:(NSDictionary*)otherkeys complete:(void(^)(BOOL isOk))complete;

-(void)writeInfo:(NSDictionary*)info toDbName:(NSString*)name complete:(void(^)(BOOL result))complete;

-(void)updateDb:(NSString*)name option:(NSDictionary*)option withNewInfo:(NSDictionary*)info complete:(void (^)(BOOL result))complete;

-(void)deleteDb:(NSString*)name option:(NSDictionary*)option complete:(void (^)(BOOL result))complete;

-(void)getInfoDb:(NSString*)name complete:(void(^)(NSArray*list))complete;
-(void)getInfoDb:(NSString *)name options:(NSArray*)keys complete:(void (^)(NSArray *list))complete;

-(void)getInfoDb:(NSString*)name1 dbkey:(NSString*)key1 relateDb:(NSString*)name2 relatedbkey:(NSString*)key2 complete:(void (^)(NSArray *list))complete;


@end
