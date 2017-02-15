//
//  ViewController.m
//  Socket
//
//  Created by jackey_gjt on 17/2/6.
//  Copyright © 2017年 Jackey. All rights reserved.
//

#import "ViewController.h"
#import "Server.h"
#import "LoaclServer.h"
#import "BaseServerDelegate.h"

#import "Connection.h"
//views
#import "ChatWeViewCell.h"
#import "UIView+CoverUtils.h"


@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,ConnectionDelegate,BaseServerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *sendMessageField;

//__________________________________________________________________________
@property (nonatomic ,strong) NSMutableArray * messageArray;
@property (nonatomic ,strong) NSNetService * server;
@end

@implementation ViewController

-(instancetype)initWithNetServer:(NSNetService *)netServer {
    
    self = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialViewController];
    _server = netServer;
  
    return self;;
    
}

-(void)serverTerminated:(id)room reason:(NSString *)string {
    
    NSLog(@"%@",@"弹出遮盖并pop");
    [self.view showErrorView:string];
    [self.sytleServer stop];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
}
-(void)connect{
    if (self.sytleServer) {
        [self.sytleServer start];
        self.sytleServer.delegate = self;

    }
    
}
-(void)updateListChatPacket:(NSDictionary *)Packet{
    [self.messageArray addObject:Packet];
    [self.tableView reloadData];
    UITableViewCell * cell = [self.tableView visibleCells].lastObject;
    CGRect rect = cell.frame;
//    rect.origin.y+=self.tableView.rowHeight/2;
    [self.tableView scrollRectToVisible:rect animated:YES];
    

    
}

- (IBAction)sendMessage:(id)sender {
    
    NSString *message = [_sendMessageField text];
    
    [self.sytleServer broadcastChatMessage:message fromUser:@"郭健滔"];
    
    
}
- (IBAction)backServerList:(id)sender {
    [self.sytleServer stop];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.messageArray = [NSMutableArray array];
    [self setupUI];
    
}

- (void)receivedNetworkPacket:(NSDictionary*)message viaConnection:(Connection*)connection {
    [self.messageArray addObject:message];
    [self.tableView reloadData];
}

-(void)setupUI {
    [self.tableView registerNib:[UINib nibWithNibName:@"ChatWeViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 100;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0);
    self.tableView.bounces =NO;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messageArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ChatWeViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.message = self.messageArray[indexPath.row];
    return cell;
}

-(void)dealloc {
    self.sytleServer  = nil;
    NSLog(@"销毁");
}


@end
