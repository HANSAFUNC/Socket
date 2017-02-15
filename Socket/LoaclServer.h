//
//  LoaclServer.h
//  Socket
//
//  Created by jackey_gjt on 17/2/8.
//  Copyright © 2017年 Jackey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseServerDelegate.h"
#import "BaseServer.h"
@interface LoaclServer : BaseServer


@property (nonatomic ,strong) NSNetService * netServer;
-(void)start;
- (void)stop;
- (void)broadcastChatMessage:(NSString*)message fromUser:(NSString*)name;
@end
