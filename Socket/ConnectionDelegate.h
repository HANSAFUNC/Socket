//
//  ConnectionDelegate.h
//  Socket
//
//  Created by jackey_gjt on 17/2/7.
//  Copyright © 2017年 Jackey. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Connection;

@protocol ConnectionDelegate<NSObject>
- (void) receivedNetworkPacket:(NSDictionary*)message
                 viaConnection:(Connection*)connection;

@optional
/**
 *  连接失败 :重连
 *
 *  @param connection
 */
- (void) connectionAttemptFailed:(Connection*)connection;
/**
 *  连接终止
 *
 *  @param connection 
 */
- (void) connectionTerminated:(Connection*)connection;



@end