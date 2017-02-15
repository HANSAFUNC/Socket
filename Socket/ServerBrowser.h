//
//  ServerBrowser.h
//  Socket
//
//  Created by jackey_gjt on 17/2/7.
//  Copyright © 2017年 Jackey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerBrowserDelegate.h"
@interface ServerBrowser : NSObject<NSNetServiceBrowserDelegate>
{
    NSNetServiceBrowser   *       netServiceBrowser;
    
    @public __weak id<ServerBrowserDelegate>   delegate;
}
@property (nonatomic ,strong) NSMutableArray * servers;

- (BOOL)start;

- (void)stop;
@end
