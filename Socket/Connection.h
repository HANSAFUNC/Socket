//
//  Connection.h
//  Socket
//
//  Created by jackey_gjt on 17/2/6.
//  Copyright © 2017年 Jackey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConnectionDelegate.h"
#import <CFNetwork/CFSocketStream.h>
#import "ServerDelegate.h"
@interface Connection : NSObject<NSNetServiceDelegate>

@property (nonatomic ,weak) id<ConnectionDelegate> delegate;

- (id) initWithHostAddress:(NSString *)host andPort:(NSInteger)port;

- (id) initWithNativeSocketHandle:(CFSocketNativeHandle)nativeSocketHandle;
- (id) initWithNetService:(NSNetService *)netService;
- (BOOL) connect;
- (void) close;
- (void) sendNetworkPacket:(NSDictionary *)packet;
@end
