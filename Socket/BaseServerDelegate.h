//
//  BaseServerDelegate.h
//  Socket
//
//  Created by jackey_gjt on 17/2/15.
//  Copyright © 2017年 Jackey. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BaseServerDelegate<NSObject>
/**
 *  更新view
 *
 *  @param Packet
 */
- (void) updateListChatPacket:(NSDictionary *)Packet;
/**
 *  服务端中断信息回调
 *
 *  @param room   服务中断
 *  @param string 
 */
- (void) serverTerminated:(id)room reason:(NSString *)string;

@end
