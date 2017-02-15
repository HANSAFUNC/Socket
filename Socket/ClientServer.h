//
//  ClientServer.h
//  Socket
//
//  Created by jackey_gjt on 17/2/15.
//  Copyright © 2017年 Jackey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Connection.h"
#import "ConnectionDelegate.h"
#import "BaseServer.h"
@interface ClientServer :BaseServer<ConnectionDelegate>
@property (nonatomic ,strong) Connection * connection;
/**
 *  地址+端口
 *
 *  @param host
 *  @param port
 *
 *  @return
 */
- (id)initWithHost:(NSString*)host andPort:(int)port;

/**
 *  用Bonjour服务器初始化
 *
 *  @param netService
 *
 *  @return 
 */
- (id)initWithNetService:(NSNetService*)netService;
@end
