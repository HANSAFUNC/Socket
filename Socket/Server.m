//
//  Server.m
//  Socket
//
//  Created by jackey_gjt on 17/2/6.
//  Copyright © 2017年 Jackey. All rights reserved.
//
#include <netinet/in.h>
#include <unistd.h>
#import "Server.h"
#import "Connection.h"


@implementation Server


-(BOOL)startService {
    
    //是否创建socket服务器成功;
    BOOL succeed =[self createService];
    if (!succeed) {
        return NO;
    }
    succeed = [self publishService];
    if ( !succeed ) {
        [self terminateServer];
        return NO;
    }
    
    return YES;
}
//停止服务器
-(void)stopService {
    
    [self terminateServer];
    [self unpublishService];
    
}

//终止socket
- (void) terminateServer
{
    if ( _listeningSocket != nil ) {
        CFSocketInvalidate(_listeningSocket);
        CFRelease(_listeningSocket);
        _listeningSocket = nil;
    }
}

- (void) handleNewNativeSocket:(CFSocketNativeHandle)nativeSocketHandle
{
     // nativeSocketHandle :可以作文一个请求响应
    //由于是Bonjour服务器 port和ip都是自动产生
     Connection* connection = [[Connection alloc] initWithNativeSocketHandle:nativeSocketHandle];
    
    // 关闭套接字句柄
    if ( connection == nil ) {
        close(nativeSocketHandle);
        return;
    }
    
    // 连接成功
    BOOL succeed = [connection connect];
    if ( !succeed ) {
        [connection close];
        return;
    }
    // 客户端进来的回调
    [self.delegate handleNewClient:connection];
}
//发布服务
- (BOOL)publishService {
    //服务器名字
    NSString * name = @"哈哈哈哈";
    //发布一个本地服务器
    netService = [[NSNetService alloc]initWithDomain:@"" type:@"_chatty._tcp." name:name port:_port];
    if (netService == nil) {
        return NO;
    }
    [netService scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    [netService setDelegate:self];
    
    [netService publish];
    
    
    return YES;
}
- (void) unpublishService
{
    if ( netService ) {
        [netService stop];
        [netService removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        netService = nil;
    }
}

-(BOOL)createService {
    
//    CFSocketCreate(CFAllocatorRef allocator, SInt32 protocolFamily, SInt32 socketType, SInt32 protocol, CFOptionFlags callBackTypes, CFSocketCallBack callout, const CFSocketContext *context);
    CFSocketContext context =  {
        0,
        (__bridge void *)(self),
        NULL,
        NULL,
        NULL,
    };
    
    //创建socket listen
    _listeningSocket = CFSocketCreate(kCFAllocatorDefault,
                                      PF_INET,
                                      SOCK_STREAM,
                                      IPPROTO_TCP,
                                      kCFSocketAcceptCallBack,
                                      SocketAcceptCallBack, &context);
    if (_listeningSocket == NULL) {
        return NO;
    }
    int existingValue = 1;
    
    CFSocketNativeHandle socketNativeHandle = CFSocketGetNative(_listeningSocket);
    /**
     *  设置超时
     *
     *  @param socketNativeHandle 本地socket句柄
     *  @param SOL_SOCKET         套接字级别选项
     *  @param SO_REUSEADDR       允许地址重用
     *
     *
     */
    
    
//    TCP_KEEPINTVL r;
    
    //SO_KEEPALIVE 
    setsockopt( socketNativeHandle, SOL_SOCKET, SO_REUSEADDR, (void *)&existingValue, sizeof(existingValue));
    struct sockaddr_in socketAddress;
    memset(&socketAddress, 0, sizeof(socketAddress));
    socketAddress.sin_len = sizeof(socketAddress);
    socketAddress.sin_family = AF_INET;   //IPv4 IPv6
    socketAddress.sin_port = 0;   //由内核自动分配
    socketAddress.sin_addr.s_addr = htonl(INADDR_ANY); //DNS
    
    NSData * socketAddressData = [NSData dataWithBytes:&socketAddress length:sizeof(socketAddress)];
    //如果绑定节点不成功
    //bing
    if (CFSocketSetAddress(_listeningSocket,(__bridge CFDataRef)(socketAddressData))!= kCFSocketSuccess) {
        if (_listeningSocket !=NULL) {
            CFRelease(_listeningSocket);
            _listeningSocket = NULL;
        }
    
        return NO;
    }
    
    NSData * socketAddressActualData =(NSData *)CFBridgingRelease(CFSocketCopyAddress(_listeningSocket));
    //socket实际地址
    struct sockaddr_in socketAddressActual;
    memcpy(&socketAddressActual, [socketAddressActualData bytes], [socketAddressActualData length]);
    
    _port = ntohs(socketAddressActual.sin_port);
    CFRunLoopRef currentRunLoop = CFRunLoopGetCurrent();
    CFRunLoopSourceRef source = CFSocketCreateRunLoopSource(kCFAllocatorDefault, _listeningSocket, 0);
    CFRunLoopAddSource(currentRunLoop, source, kCFRunLoopCommonModes);
    CFRelease(currentRunLoop);
    NSLog(@"-----------%d",_port);
    return YES;
}

static void SocketAcceptCallBack(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *data, void *info){
    
    
    if ( type != kCFSocketAcceptCallBack ) {
        return;
    }
    //接收socket
    // 回调一个套接字本地句柄指针 //用于存放error
    CFSocketNativeHandle nativeSocketHandle = *(CFSocketNativeHandle *)data;
    
    Server *server = (__bridge Server *)info;
    [server handleNewNativeSocket:nativeSocketHandle];
    
    
}

- (void) netService:(NSNetService*)sender didNotPublish:(NSDictionary*)errorDict
{
    if ( sender != netService ) {
        return;
    }
    
    // 暂停socket服务
    [self terminateServer];
    
    // 停止 Bonjour
    [self unpublishService];
    
    // 服务器发布失败
    if ([self.delegate respondsToSelector:@selector(serverFailed:reason:)]) {
        [self.delegate serverFailed:self reason:@"Failed to publish service via Bonjour (duplicate server name?)"];
    }
    
}

- (void) netServiceDidPublish:(NSNetService *)sender
{
    NSLog(@" >> netServiceDidPublish: %@", [sender name]);
}

- (void) netServiceDidStop:(NSNetService *)sender
{
    NSLog(@" >> netServiceDidStop: %@", [sender name]);
}


@end
