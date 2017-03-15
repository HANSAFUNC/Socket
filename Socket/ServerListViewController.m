//
//  ServerListViewController.m
//  Socket
//
//  Created by jackey_gjt on 17/2/10.
//  Copyright © 2017年 Jackey. All rights reserved.
//

#import "ServerListViewController.h"
#import "ServerBrowser.h"
#import "ServerBrowserDelegate.h"
#import "ViewController.h"
#import "LoaclServer.h"
#import "ClientServer.h"


@interface ServerListViewController ()<ServerBrowserDelegate>

@property (nonatomic ,strong) ServerBrowser * serverBrowser;
@property (nonatomic ,strong) NSNetService *netServiec;
@property (nonatomic ,strong) LoaclServer * localCS;

@end

@implementation ServerListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = 50;
    self.serverBrowser = [[ServerBrowser alloc]init];
    self.serverBrowser->delegate = self;
    UIButton * createBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    createBtn.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40);
    [createBtn setTitle:@"创建房间" forState:0];
    [createBtn addTarget:self action:@selector(createSeverAction) forControlEvents:UIControlEventTouchUpInside];
    createBtn.backgroundColor = [UIColor redColor];
    self.tableView.tableHeaderView = createBtn;
    
}
-(void)createSeverAction {
    
    if (self.localCS) {
        NSLog(@"error : *******只能创建一个服务器******");
        return;
    }
    LoaclServer *localCS = [[LoaclServer alloc]init];
    ViewController * chatVC = [[ViewController alloc]initWithNetServer:nil];
    chatVC.sytleServer =localCS;
    [chatVC connect];
    [self presentViewController:chatVC animated:YES completion:nil];
}

-(void)updateServerList {
    [self.tableView reloadData];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNetService * netservice = self.serverBrowser.servers[indexPath.row];
    ViewController * chatVC = [[ViewController alloc]initWithNetServer:netservice];
    ClientServer *server = [[ClientServer alloc]initWithNetService:netservice];
    chatVC.sytleServer = server;
    [chatVC connect];
    [self presentViewController:chatVC animated:YES completion:nil];
    
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.serverBrowser.servers.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    NSNetService * service = self.serverBrowser.servers[indexPath.row];
    cell.textLabel.text = service.name;
    return cell;
}

-(void)viewWillAppear:(BOOL)animated {
    [self.serverBrowser start];
}
-(void)viewWillDisappear:(BOOL)animated {
    [self.serverBrowser stop];
}
-(void)dealloc {
    NSLog(@"%s",__func__);
}

@end
