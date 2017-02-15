//
//  ViewController.h
//  Socket
//
//  Created by jackey_gjt on 17/2/6.
//  Copyright © 2017年 Jackey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseServer.h"

@interface ViewController : UIViewController
@property (nonatomic ,strong) BaseServer * sytleServer;
-(instancetype)initWithNetServer:(NSNetService *)netServer;
-(void)connect;
@end

