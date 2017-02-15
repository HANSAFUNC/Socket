//
//  KeepDocument.m
//  Socket
//
//  Created by jackey_gjt on 17/2/14.
//  Copyright © 2017年 Jackey. All rights reserved.
//

#import "KeepDocument.h"


@implementation KeepDocument

static KeepDocument * instance = nil;
+(instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}


@end
