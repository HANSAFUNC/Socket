//
//  ChatWeViewCell.m
//  Socket
//
//  Created by jackey_gjt on 17/2/8.
//  Copyright © 2017年 Jackey. All rights reserved.
//

#import "ChatWeViewCell.h"

@interface ChatWeViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *formMessage;
@property (weak, nonatomic) IBOutlet UILabel *toMessage;


@end
@implementation ChatWeViewCell


-(void)setMessage:(NSDictionary *)message {
    _message = message;
    [self displayViewAndhiddenViewFunc:message];
    
}

-(void)displayViewAndhiddenViewFunc:(NSDictionary *)message {
    if ([[message allKeys] containsObject:@"from"]) {
        _formMessage.text = [self messageStringWithFrom:message];
        _formMessage.hidden = NO;
        _toMessage.hidden = YES;
        
    }else{
        _toMessage.text = [self messageStringWithTo:message];
        _toMessage.hidden = NO;
        _formMessage.hidden = YES;
    }
}

-(NSString *)messageStringWithFrom:(NSDictionary *)dict {
    
    return [NSString stringWithFormat:@"%@:%@",dict[@"from"],dict[@"message"]];
}
-(NSString *)messageStringWithTo:(NSDictionary *)dict {
    
    return [NSString stringWithFormat:@"%@:%@",dict[@"to"],dict[@"message"]];
}
-(NSDictionary *)packetUtil:(NSString *)message name:(NSString *)name {
    
    NSDictionary * packet = [NSDictionary
                             dictionaryWithObjectsAndKeys:message,@"message",name,@"name", nil];
    return packet;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

@end
