//
//  SqliteManager.m
//  DLZDemo
//
//  Created by 董力祯 on 2018/3/20.
//  Copyright © 2018年 董力祯. All rights reserved.
//

#import "SqliteManager.h"
#import <sqlite3.h>

#define GETKYES()
@implementation SqliteManager

+(instancetype)sharedSqlite{
    
    static SqliteManager *_shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared=[[self alloc]init];
    });
    return _shared;
}
static sqlite3 *sql;
-(void)openDBComplete:(void(^)(BOOL isOk))complete{
    NSString *dbPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"app.sqlite"];
    if (sqlite3_open(dbPath.UTF8String, &sql) == SQLITE_OK) {//数据库打开成功
        
//        sqlite3_stmt *statement;
//        const char *getTableInfo = "select * from sqlite_master where type='table' order by name";
//        sqlite3_prepare_v2(sql, getTableInfo, -1, &statement, nil);
//        while (sqlite3_step(statement) == SQLITE_ROW) {
//            char *nameData = (char *)sqlite3_column_text(statement, 1);
//            NSString *tableName = [[NSString alloc] initWithUTF8String:nameData];
//            NSLog(@"tableName:%@",tableName);
//        }

        complete(YES);
    }else{
        sqlite3_close(sql);
        NSLog(@"error %s",sqlite3_errmsg(sql));
        complete(NO);
    }
}
-(void)creatTableWithName:(NSString*)name primaryKey:(NSString*)primaryKey  otherKeys:(NSDictionary*)otherkeys complete:(void(^)(BOOL isOk))complete{
    
    [self openDBComplete:^(BOOL isOk) {
        if (isOk) {
            NSString *creattext=[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ( '%@' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT",name,primaryKey];
            for (NSString *key in otherkeys.allKeys) {
                NSString *value=otherkeys[key];
                creattext=[creattext stringByAppendingString:[NSString stringWithFormat:@",'%@' %@ not null",key,value]];
            }
            creattext=[creattext stringByAppendingString:@")"];
            complete([self execSQL:creattext]);
        }else{
            complete(NO);
        }
    }];
}
-(void)writeInfo:(NSDictionary *)info toDbName:(NSString *)name complete:(void (^)(BOOL))complete{
    
    [self openDBComplete:^(BOOL isOk) {
        if (isOk) {
            NSMutableArray *keys=[[NSMutableArray alloc]init];
            NSMutableArray *values=[[NSMutableArray alloc]init];
            for (NSString *key in info.allKeys) {
                [keys addObject:key];
                [values addObject:[NSString stringWithFormat:@"'%@'",info[key]]];
            }
            NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO '%@' (%@) VALUES (%@)",name,[keys componentsJoinedByString:@","],[values componentsJoinedByString:@","]];
            complete([self execSQL:insertSQL]);
        }else{
            complete(NO);
        }
    }];
}
-(void)updateDb:(NSString*)name option:(NSDictionary*)option withNewInfo:(NSDictionary*)info complete:(void (^)(BOOL))complete{
    [self openDBComplete:^(BOOL isOk) {
        if (isOk) {
            NSMutableArray *values=[[NSMutableArray alloc]init];
            for (NSString *key in info.allKeys) {
                [values addObject:[NSString stringWithFormat:@"%@='%@'",key,info[key]]];
            }
            NSMutableArray *options=[[NSMutableArray alloc]init];
            for (NSString *key in option.allKeys) {
                [options addObject:[NSString stringWithFormat:@"%@='%@'",key,option[key]]];
            }
            NSString *updateSQL=[NSString stringWithFormat:@"UPDATE '%@' SET ",name];
            updateSQL=[updateSQL stringByAppendingString:[values componentsJoinedByString:@","]];
            updateSQL=[updateSQL stringByAppendingString:[NSString stringWithFormat:@" WHERE %@",[options componentsJoinedByString:@" "]]];
            complete([self execSQL:updateSQL]);
        }else{
            complete(NO);
        }
    }];
}
-(void)deleteDb:(NSString *)name option:(NSDictionary *)option complete:(void (^)(BOOL))complete{
    
    [self openDBComplete:^(BOOL isOk) {
        if (isOk) {
            NSMutableArray *options=[[NSMutableArray alloc]init];
            for (NSString *key in option.allKeys) {
                [options addObject:[NSString stringWithFormat:@"%@='%@'",key,option[key]]];
            }
            NSString *deleteSQL=[NSString stringWithFormat:@"DELETE  FROM '%@' ",name];
            deleteSQL=[deleteSQL stringByAppendingString:[NSString stringWithFormat:@"WHERE %@",[options componentsJoinedByString:@" "]]];
            complete([self execSQL:deleteSQL]);
        }else{
            complete(NO);
        }
    }];
}

-(void)getInfoDb:(NSString *)name complete:(void (^)(NSArray *))complete{
    [self getInfoDb:name options:nil complete:^(NSArray *list) {
        complete(list);
    }];
}
-(void)getInfoDb:(NSString *)name options:(NSArray*)keys complete:(void (^)(NSArray *list))complete{
    
    [self openDBComplete:^(BOOL isOk) {
        if (isOk) {
            //            获取所有key
            //            sqlite3_stmt *statement;
            //
            //            NSMutableArray *keys=[[NSMutableArray alloc]init];
            //            NSString *getColumn=[NSString stringWithFormat:@"PRAGMA table_info(%@)",name];
            //            sqlite3_prepare_v2(sql, getColumn.UTF8String, -1, &statement, nil);
            //            while (sqlite3_step(statement) == SQLITE_ROW) {
            //                char *key = (char *)sqlite3_column_text(statement, 1);
            //                NSString *columnName = [[NSString alloc] initWithUTF8String:key];
            //                [keys addObject:columnName];
            //                NSLog(@"columnName:%@",columnName);
            //            }
            
            NSString *SQL;
            if (keys.count) {
                SQL = [NSString stringWithFormat:@"SELECT %@ FROM '%@'",[keys componentsJoinedByString:@","],name];
            }else{
                SQL = [NSString stringWithFormat:@"SELECT * FROM '%@'",name];
            }
            sqlite3_stmt *stmt = nil;
            if (sqlite3_prepare_v2(sql, SQL.UTF8String, -1, &stmt, nil) == SQLITE_OK) {
                
                NSMutableArray *dataList = [[NSMutableArray alloc] init];
                while (sqlite3_step(stmt) == SQLITE_ROW) {
                    int columnCount = sqlite3_column_count(stmt);
                    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                    for (int i=0; i<columnCount; i++) {
                        NSString *key = [NSString stringWithUTF8String:(const char *)sqlite3_column_name(stmt, i)];
                        NSString *value = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, i)];
                        [dict setObject:value forKey:key];
                    }
                    [dataList addObject:dict];
                }
                complete(dataList);
            }else{
                NSLog(@"查询失败!");
                complete(nil);
            }
        }else{
            complete(nil);
        }
    }];
}
-(void)getInfoDb:(NSString *)name1 dbkey:(NSString *)key1 relateDb:(NSString *)name2 relatedbkey:(NSString *)key2 complete:(void (^)(NSArray *))complete{
    [self openDBComplete:^(BOOL isOk) {
        if (isOk) {
            NSString *SQL = [NSString stringWithFormat:@"SELECT * FROM %@,%@ WHERE %@.%@=%@.%@",name1,name2,name1,key1,name2,key2];
            sqlite3_stmt *stmt = nil;
            if (sqlite3_prepare_v2(sql, SQL.UTF8String, -1, &stmt, nil) == SQLITE_OK) {
                
                NSMutableArray *dataList = [[NSMutableArray alloc] init];
                while (sqlite3_step(stmt) == SQLITE_ROW) {
                    int columnCount = sqlite3_column_count(stmt);
                    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                    for (int i=0; i<columnCount; i++) {
                        NSString *key = [NSString stringWithUTF8String:(const char *)sqlite3_column_name(stmt, i)];
                        NSString *value = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, i)];
                        [dict setObject:value forKey:key];
                    }
                    [dataList addObject:dict];
                }
                complete(dataList);
            }else{
                NSLog(@"查询失败!");
                complete(nil);
            }
        }else{
            complete(nil);
        }
    }];
}
-(BOOL)execSQL:(NSString *)SQL{
    return sqlite3_exec(sql, SQL.UTF8String, nil, nil, nil) == SQLITE_OK;
}
@end
