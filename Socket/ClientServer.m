//
//  ClientServer.m
//  Socket
//
//  Created by jackey_gjt on 17/2/15.
//  Copyright © 2017年 Jackey. All rights reserved.
//

#import "ClientServer.h"

@implementation ClientServer

- (id)initWithHost:(NSString*)host andPort:(int)port
{
    _connection = [[Connection alloc] initWithHostAddress:host andPort:port];
    return self;
}


- (id)initWithNetService:(NSNetService*)netService
{   NSLog(@"%@-- %zd",netService.hostName,netService.port);
    _connection = [[Connection alloc] initWithNetService:netService];
    return self;
}


// Cleanup
- (void)dealloc
{
    self.connection = nil;
    
}

#pragma mark -
#pragma mark Network

- (BOOL)start
{
    if (self.connection == nil ) {
        return NO;
    }
    
    _connection.delegate = self;
    
    return [_connection connect];
}


// Stop everything, disconnect from server
- (void)stop {
    if (_connection == nil ) {
        return;
    }
    
    [_connection close];
    self.connection = nil;
}


//广播信息
- (void)broadcastChatMessage:(NSString *)message fromUser:(NSString *)name
{
    NSDictionary* packet = [NSDictionary dictionaryWithObjectsAndKeys:message, @"message", name, @"to", nil];
    
    [_connection sendNetworkPacket:packet];
}


#pragma mark -
#pragma mark ConnectionDelegate Method Implementations

- (void)connectionAttemptFailed:(Connection*)connection
{
    [self.delegate serverTerminated:self reason:@"无法连接到服务器"];
}


- (void)connectionTerminated:(Connection*)connection
{
    //错误回调
    [self.delegate serverTerminated:self reason:@"服务器关闭了或输入输出流有问题"];
}


- (void)receivedNetworkPacket:(NSDictionary*)packet viaConnection:(Connection*)connection
{
    
    [self.delegate updateListChatPacket:packet];
}
@end
