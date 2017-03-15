//
//  ServerDelegate.h
//  Socket
//
//  Created by jackey_gjt on 17/2/7.
//  Copyright © 2017年 Jackey. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Connection,Server;
@protocol ServerDelegate <NSObject>

// Server has been terminated because of an error
/**
 *  服务器被终止调用
 *
 *  @param server
 *  @param reason 错误原因
 */
- (void)serverFailed:(Server *)server reason:(NSString *)reason;

/**
 *  有新的用户连接的时候调用
 *
 *  @param connection 
 */
-(void)handleNewClient:(Connection *)Client;
@end
