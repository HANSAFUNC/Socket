//
//  BaseServer.h
//  Socket
//
//  Created by jackey_gjt on 17/2/15.
//  Copyright © 2017年 Jackey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseServerDelegate.h"
@interface BaseServer : NSObject
@property (nonatomic ,weak) id<BaseServerDelegate> delegate;
- (BOOL) start;
- (void) stop;
- (void) broadcastChatMessage:(NSString *)message fromUser:(NSString *)name;
@end
