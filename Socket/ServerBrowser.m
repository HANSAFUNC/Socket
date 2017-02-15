//
//  ServerBrowser.m
//  Socket
//
//  Created by jackey_gjt on 17/2/7.
//  Copyright © 2017年 Jackey. All rights reserved.
//

#import "ServerBrowser.h"

#pragma mark NSNetService (BrowserViewControllerAdditions)

@interface NSNetService (BrowserViewControllerAdditions)

- (NSComparisonResult) localizedCaseInsensitiveCompareByName:(NSNetService *)aService;

@end

@implementation NSNetService (BrowserViewControllerAdditions)

- (NSComparisonResult) localizedCaseInsensitiveCompareByName:(NSNetService *)aService
{
    return [[self name] localizedCaseInsensitiveCompare:[aService name]];
}

@end


@implementation ServerBrowser


- (id) init
{
    self = [super init];
    if (self) {
        self.servers = [[NSMutableArray alloc] init];
    }
    
    return self;
}


// Cleanup
- (void) dealloc
{
    if ( _servers != nil ) {
        
        _servers = nil;
    }
    
    self->delegate = nil;
    
}

- (BOOL) start
{
    // Restarting?
    if ( netServiceBrowser != nil ) {
        [self stop];
    }
    
    netServiceBrowser = [[NSNetServiceBrowser alloc] init];
    if( !netServiceBrowser ) {
        return NO;
    }
    
    netServiceBrowser.delegate = self;
    [netServiceBrowser searchForServicesOfType:@"_chatty._tcp." inDomain:@""];
    
    return YES;
}


// Terminate current service browser and clean up
- (void) stop {
    if ( netServiceBrowser == nil ) {
        return;
    }
    
    [netServiceBrowser stop];
    netServiceBrowser = nil;
    [_servers removeAllObjects];
}


- (void) sortServers
{
    [self.servers sortUsingSelector:@selector(localizedCaseInsensitiveCompareByName:)];
}


#pragma mark -
#pragma mark NSNetServiceBrowser Delegate Method Implementations

// New service was found
- (void) netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser
            didFindService:(NSNetService *)netService
                moreComing:(BOOL)moreServicesComing
{
    NSLog(@"%@-- %zd",netService.hostName,netService.port);
    if ( ! [self.servers containsObject:netService] ) {
        [self.servers addObject:netService];
    }
    
    if ( moreServicesComing ) {
        return;
    }
    
    
    [self sortServers];
    
    [delegate updateServerList];
}



// removed
- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser
         didRemoveService:(NSNetService *)netService
               moreComing:(BOOL)moreServicesComing
{
    
    [_servers removeObject:netService];
    
    
    if ( moreServicesComing ) {
        return;
    }
    
    
    [self sortServers];
    
    [delegate updateServerList];
}

@end
