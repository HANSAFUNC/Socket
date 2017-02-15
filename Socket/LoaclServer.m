//
//  LoaclServer.m
//  Socket
//
//  Created by jackey_gjt on 17/2/8.
//  Copyright © 2017年 Jackey. All rights reserved.
//
/**
 *  模拟本地服务器
 *
 *  @param nonatomic
 *  @param strong
 *
 *  @return
 */
#import "LoaclServer.h"
#import "Server.h"
#import "ServerDelegate.h"
#import "Connection.h"
#import "ConnectionDelegate.h"
@interface LoaclServer ()<ServerDelegate,ConnectionDelegate>
@property (nonatomic ,strong) NSMutableSet *clients;
@property (nonatomic ,strong) Server * server;
@end
@implementation LoaclServer

//static LoaclServer* instance = nil;
//+(instancetype)shareInstance{
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        instance = [[self alloc]init];
//    });
//    return instance;
//}

-(instancetype)init {
    self = [super init];
    if (self) {
        self.clients = [[NSMutableSet alloc]init];
    }
    return self;
}

//打开服务器
-(void)start {
    
    self.server = [[Server alloc]init];
    self.server.delegate = self;
    BOOL succeed = [self.server startService];
    if (!succeed) {
        self.server = nil;
        return;
    }else {
        NSLog(@"*********开启服务器成功*********");
    }
    _netServer = self.server->netService;
    
}
- (void)stop
{
    [self.server stopService];
    self.server = nil;
    
    [self.clients makeObjectsPerformSelector:@selector(close)];
}

//监听客服端的连接
-(void)handleNewClient:(Connection *)Client {
    Client.delegate = self;
    [self.clients addObject:Client];
}

-(void)serverFailed:(Server *)server reason:(NSString *)reason {
    NSLog(@"服务器终结");
    [server startService];
    
}


- (void)broadcastChatMessage:(NSString*)message fromUser:(NSString*)name
{
   
    NSDictionary* packet = [NSDictionary dictionaryWithObjectsAndKeys:message, @"message", name, @"from", nil];
    [self.delegate updateListChatPacket:packet];
    [self.clients makeObjectsPerformSelector:@selector(sendNetworkPacket:) withObject:packet];
}

#pragma -MARK delegate
//服务器接收到数据 要广播给所有用户

-(void)receivedNetworkPacket:(NSDictionary *)message viaConnection:(Connection *)connection {
    
    [connection sendNetworkPacket:message];
    [self.delegate updateListChatPacket:message];
    
    
}
//终结
-(void)connectionTerminated:(Connection *)connection {
    [self.clients removeObject:connection];
}
//服务器错误
-(void)connectionAttemptFailed:(Connection *)connection {
    NSLog(@"读写流不能用");
    
}


@end
