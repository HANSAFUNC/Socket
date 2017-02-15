//
//  Server.h
//  Socket
//
//  Created by jackey_gjt on 17/2/6.
//  Copyright © 2017年 Jackey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerDelegate.h"
@interface Server : NSObject<NSNetServiceDelegate>
{
    uint16_t _port;
    CFSocketRef _listeningSocket;
    @public NSNetService * netService;
}
@property (nonatomic ,strong) id<ServerDelegate> delegate;
-(BOOL)startService;
-(void)stopService;


@end
