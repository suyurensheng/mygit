//
//  ShowView.m
//  DLZDemo
//
//  Created by 董力祯 on 2016/10/20.
//  Copyright © 2016年 董力祯. All rights reserved.
//

#import "ShowView.h"

@implementation ShowView

-(id)init{

    self=[[NSBundle mainBundle] loadNibNamed:@"ShowView" owner:self options:nil].lastObject;
    if (self) {
        self.frame=[UIScreen mainScreen].bounds;
    }
    return self;
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    [self endEditing:YES];
}
@end
