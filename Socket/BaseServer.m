//
//  BaseServer.m
//  Socket
//
//  Created by jackey_gjt on 17/2/15.
//  Copyright © 2017年 Jackey. All rights reserved.
//

#import "BaseServer.h"

@implementation BaseServer

- (void) dealloc
{
    self.delegate = nil;
    
}

- (BOOL) start
{
    [self doesNotRecognizeSelector:_cmd];
    
    return NO;
}

- (void) stop
{
    [self doesNotRecognizeSelector:_cmd];
}

- (void) broadcastChatMessage:(NSString *)message fromUser:(NSString *)name
{
    [self doesNotRecognizeSelector:_cmd];
}

@end
