//
//  ErrorEntity.m
//  XingVelo3
//
//  Created by 瞿少如 on 12-12-18.
//  Copyright (c) 2012年 Velo. All rights reserved.
//

#import "ErrorEntity.h"

@implementation ErrorEntity

@synthesize message;
@synthesize code;

+ (id)errorInfoWithCode:(NSInteger)code message:(NSString*)messageString
{
    ErrorEntity* errorInfo = [[self alloc] init];
    if(errorInfo)
    {
        errorInfo.code = code;
        errorInfo.message = messageString;
    }
    return errorInfo;
}

@end
