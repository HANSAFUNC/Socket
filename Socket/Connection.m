//
//  Connection.m
//  Socket
//
//  Created by jackey_gjt on 17/2/6.
//  Copyright © 2017年 Jackey. All rights reserved.
//

#import "Connection.h"
//Declare C callback functions
//void readStreamEventHandler(CFReadStreamRef stream, CFStreamEventType eventType, void *info);
//void writeStreamEventHandler(CFWriteStreamRef stream, CFStreamEventType eventType, void *info);
Connection  * connection = nil;
@interface Connection()
{
    NSNetService *          netService;
    
    // Read stream
    CFReadStreamRef         readStream;
    BOOL                    readStreamOpen;
    //输入数据缓存区
    NSMutableData *         incomingDataBuffer;
    int	                    packetBodySize;
    
    // Write stream
    CFWriteStreamRef        writeStream;
    BOOL                    writeStreamOpen;
    //输出数据缓存区
    NSMutableData *         outgoingDataBuffer;
}
- (void)writeStreamHandleEvent:(CFStreamEventType)event;
@property (nonatomic ,strong) NSMutableSet * clients;
@property (nonatomic ,assign) CFSocketNativeHandle connectedSocketHandle;
@property (nonatomic ,assign) NSInteger port;
@property (nonatomic ,strong) NSString * host;
@end
@implementation Connection


-(void)serverFailed:(Server *)server reason:(NSString *)reason {
    
}

- (id) initWithNetService:(NSNetService *)NetService
{
    [self clean];
    
    //Bonjour是否解析 没有解析不知道hostname
    if ( NetService.hostName != nil ) {
        return [self initWithHostAddress:NetService.hostName andPort:NetService.port];
    }
    
    netService = NetService;
    return self;
}

- (id) initWithHostAddress:(NSString *)host andPort:(NSInteger)port
{
    [self clean];
    
    self.host = host;
    self.port = port;
    return self;
}

- (instancetype) initWithNativeSocketHandle:(CFSocketNativeHandle)nativeSocketHandle
{
    [self clean];
    self.clients = [[NSMutableSet alloc]init];
    self.connectedSocketHandle = nativeSocketHandle;
    
    return self;
}


- (BOOL) connect
{
    if ( self.host != nil ) {
        // 绑定一个可读写的连接
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                           (__bridge CFStringRef)self.host,
                                           (UInt32)self.port, &readStream, &writeStream);
        
        // 初始化
        return [self setupSocketStreams];
    }
    
    else if ( self.connectedSocketHandle != -1 ) {
        // 绑定连接
        CFStreamCreatePairWithSocket(kCFAllocatorDefault, self.connectedSocketHandle,
                                     &readStream, &writeStream);
        
        // 初始化
        return [self setupSocketStreams];
    }
    
    else if (netService != nil ) {
        NSLog(@"%@-- %zd",netService.hostName,netService.port);
        if ( netService.hostName != nil ) {
            CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                               (__bridge CFStringRef)netService.hostName, (UInt32)netService.port, &readStream, &writeStream);
            return [self setupSocketStreams];
        }
        
        // //通过代理解析
        netService.delegate = self;
        [netService resolveWithTimeout:5.0];
        
        return YES;
    }
    
    
    return NO;
}

//初始化化socket流
-(BOOL)setupSocketStreams{
    
    if ( readStream == nil || writeStream == nil ) {
        [self close];
        return NO;
    }
    
    // Create buffers
    incomingDataBuffer = [[NSMutableData alloc] init];
    outgoingDataBuffer = [[NSMutableData alloc] init];
    
    // 读写流的属性  当流关闭的时候套接字关闭
    CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
    CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
    
    
    //事件处理
    CFOptionFlags registeredEvents =
    kCFStreamEventOpenCompleted       //打开流后处理
    | kCFStreamEventHasBytesAvailable //有可用数据处理
    | kCFStreamEventCanAcceptBytes    //可以接收数据处理
    | kCFStreamEventEndEncountered    //流关闭处理
    | kCFStreamEventErrorOccurred;    //发生错误处理
    
    
    CFStreamClientContext ctx = {
        0,
        (__bridge void *)(self),
        NULL,
        NULL,
        NULL};
    
    /**
     *  设置流 回调事件
     */
    CFReadStreamSetClient(readStream, registeredEvents, readStreamEventHandler, &ctx);
    CFWriteStreamSetClient(writeStream, registeredEvents,writeStreamEventHandler, &ctx);
    
    // 在运行循环调度流
    CFReadStreamScheduleWithRunLoop(readStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
    CFWriteStreamScheduleWithRunLoop(writeStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
    
    // 能否打开流
    if ( !CFReadStreamOpen(readStream) || !CFWriteStreamOpen(writeStream)) {
        [self close];
        return NO;
    }
    
    return YES;
    
}
void readStreamEventHandler(CFReadStreamRef stream, CFStreamEventType eventType, void *info){
    //客户回调信息
    //有信息就来这里
    Connection *connection = (__bridge Connection*)info;
    [connection readStreamHandleEvent:eventType];
}
//读取流事件处理
-(void)readStreamHandleEvent:(CFStreamEventType)event {
    if ( event == kCFStreamEventOpenCompleted ) {
        readStreamOpen = YES;
    }
    
    
    //有新的数据来的时候
    else if ( event == kCFStreamEventHasBytesAvailable ) {
        
        
        [self readFromStreamIntoIncomingBuffer];
    }
    
    
    else if ( event == kCFStreamEventEndEncountered || event == kCFStreamEventErrorOccurred ) {
        // Clean everything up
        [self close];
        
        if ( !readStreamOpen || !writeStreamOpen ) {
            [self.delegate connectionAttemptFailed:self];
        }
        else {
            [self.delegate connectionTerminated:self];
        }
    }
}
-(void)readFromStreamIntoIncomingBuffer{
    //临时缓存区
    UInt8 buf[1024];
    //判断有没有可以读取的数据
    while (CFReadStreamHasBytesAvailable(readStream)) {
        CFIndex lenght = CFReadStreamRead(readStream, buf, sizeof(buf));
        if (lenght <= 0) {
            [self close];
            //            if ([self.Connectiondelegate respondsToSelector:@selector(connectionTerminated:)]) {
            //
            //            }
            [self.delegate connectionTerminated:self];
            return;
        }
        //读取到的数据都放到这个缓存区
        [incomingDataBuffer appendBytes:buf length:lenght];
    }
    while( YES ) {
        
        if ( packetBodySize == -1 ) {
            
            if ( [incomingDataBuffer length] >= sizeof(int) ) {
                // extract length
                //复制4-xxx长度
                //4个长度之后的数据
                memcpy(&packetBodySize, [incomingDataBuffer bytes], sizeof(int));
                NSLog(@"********从输入缓存区取拿包数据****************");
                
                NSRange rangeToDelete = {0, sizeof(int)};
                //移除
                [incomingDataBuffer replaceBytesInRange:rangeToDelete withBytes:NULL length:0];
            }
            else {
                
                break;
            }
        }
        
        // 提取body
        if ( [incomingDataBuffer length] >= packetBodySize ) {
            NSLog(@"********把Body从缓存区拿出来****************");
            // We now have enough data to extract a meaningful packet.
            NSData* raw = [NSData dataWithBytes:[incomingDataBuffer bytes] length:packetBodySize];
            NSDictionary* packet = [NSKeyedUnarchiver unarchiveObjectWithData:raw];
            //
#warning 接收数据调用 delegate
            
            if ([self.delegate respondsToSelector:
                 @selector(receivedNetworkPacket:viaConnection:)])
            {
                [self.delegate receivedNetworkPacket:packet viaConnection:self];
            }
            
            
            
            NSRange rangeToDelete = {0, packetBodySize};
            [incomingDataBuffer replaceBytesInRange:rangeToDelete withBytes:NULL length:0];
            
            
            packetBodySize = -1;
        }
        else {
            
            break;
        }
    }
    
}


void writeStreamEventHandler(CFWriteStreamRef stream, CFStreamEventType eventType, void *info)
{
    
    Connection* connection = (__bridge Connection*)info;
    [connection writeStreamHandleEvent:eventType];
}


- (void)writeStreamHandleEvent:(CFStreamEventType)event
{
    
    if ( event == kCFStreamEventOpenCompleted ) {
        writeStreamOpen = YES;
    }
    //是否有足够空间写入流
    
    else if ( event == kCFStreamEventCanAcceptBytes ) {
        // Write whatever data we have, as much as stream can handle
        //写
        [self writeOutgoingBufferToStream];
    }
    
    
    else if ( event == kCFStreamEventEndEncountered || event == kCFStreamEventErrorOccurred ) {
        // Clean everything up
        [self close];
        
        if ( !readStreamOpen || !writeStreamOpen ) {
            [self.delegate connectionAttemptFailed:self];
        }
        else {
            
            [self.delegate connectionTerminated:self];
        }
    }
}

-(void)writeOutgoingBufferToStream{
    
    //连接流是否打开
    if (readStreamOpen==NO || writeStreamOpen==NO ) {
        
        
        return;
    }
    
    // 没输出缓存
    if ( [outgoingDataBuffer length] == 0 ) {
        
        return;
    }
    
    //别的数据不接收
    if ( !CFWriteStreamCanAcceptBytes(writeStream) ) {
        return;
    }
    
    //写
    CFIndex writtenBytes = CFWriteStreamWrite(writeStream, [outgoingDataBuffer bytes], [outgoingDataBuffer length]);
    
    if ( writtenBytes == -1 ) {
        //返回-1等于有❌
        [self close];
        //结束连接
        [self.delegate connectionTerminated:self];
        
        return;
    }
    
    //移除输出了的缓存
    NSRange range = {0, writtenBytes};
    [outgoingDataBuffer replaceBytesInRange:range withBytes:NULL length:0];
}

- (void)sendNetworkPacket:(NSDictionary *)packet
{
    //    NSString * msg = @"sbsbsbsbsbsbsbs";
    //    NSString * name = @"jk";
    //    NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:msg,@"message",name,@"from", nil];
    // Encode packet
    
    NSData * rawPacket = [NSKeyedArchiver archivedDataWithRootObject:packet];
    
    NSLog(@"---%ld",(long)rawPacket.length);
    
    // header
    //instrument
    NSInteger packetLength = [rawPacket length];
    NSLog(@"packetLength %ld",(long)packetLength);
    [outgoingDataBuffer appendBytes:&packetLength length:sizeof(int)];
    NSLog(@"packetLength %ld",(long)packetLength);
    // body
    [outgoingDataBuffer appendData:rawPacket];
    NSLog(@"packetLength %ld",(long)packetLength);
    
    // 尝试写
    [self writeOutgoingBufferToStream];
}

-(void)close{
    if ( readStream != nil ) {
        CFReadStreamUnscheduleFromRunLoop(readStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
        CFReadStreamClose(readStream);
        CFRelease(readStream);
        readStream = NULL;
    }
    
    // Clean write stream
    if ( writeStream != nil ) {
        CFWriteStreamUnscheduleFromRunLoop(writeStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
        CFWriteStreamClose(writeStream);
        CFRelease(writeStream);
        writeStream = NULL;
    }
    
    // Clean buffers
    
    incomingDataBuffer = NULL;
    
    
    outgoingDataBuffer = NULL;
    
    // 停止服务器
    if ( netService != nil ) {
        [netService stop];
        netService = nil;
    }
    
    // 重设变量
    [self clean];
    
}

-(void)clean {
    
    readStream = nil;
    readStreamOpen = NO;
    
    writeStream = nil;
    writeStreamOpen = NO;
    
    incomingDataBuffer = nil;
    outgoingDataBuffer = nil;
    
    netService = nil;
    self.host = nil;
    self.connectedSocketHandle = -1;
    packetBodySize = -1;
    
}
-(void)netService:(NSNetService *)sender didAcceptConnectionWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream {
    
}

/**
 *  不能解析回调
 *
 *  @param sender
 *  @param errorDict 错误
 */
- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict
{
    if ( sender != netService ) {
        return;
    }
    NSLog(@"%@ %ld",netService.hostName,(long)netService.port);
    
    [self.delegate connectionAttemptFailed:self];
    
    [self close];
}


/**
 *  解析回调
 *
 *  @param sender
 */
- (void)netServiceDidResolveAddress:(NSNetService *)sender
{
    if ( sender != netService ) {
        return;
    }
    NSLog(@"%@-- %zd",netService.hostName,netService.port);
    // Save connection info
    self.host = netService.hostName;
    self.port = netService.port;
    
    
    netService = nil;
    
    
    if ( ![self connect] ) {
        [self.delegate connectionAttemptFailed:self];
        [self close];
    }
}


@end
