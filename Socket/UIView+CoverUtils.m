//
//  UIView+CoverUtils.m
//  Socket
//
//  Created by jackey_gjt on 17/2/15.
//  Copyright © 2017年 Jackey. All rights reserved.
//

#import "UIView+CoverUtils.h"

@implementation UIView (CoverUtils)

-(void)showErrorView:(NSString *)error {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:error delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}
@end
