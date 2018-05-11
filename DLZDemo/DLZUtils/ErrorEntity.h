//
//  ErrorEntity.h
//  XingVelo3
//
//  Created by 瞿少如 on 12-12-18.
//  Copyright (c) 2012年 Velo. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ERRORCODESELF 5555

@interface ErrorEntity : NSObject

@property (nonatomic, strong) NSString* message;
@property (nonatomic, assign) NSInteger code;

+ (id)errorInfoWithCode:(NSInteger)code message:(NSString*)messageString;

@end
