//
//  AppDelegate.m
//  Socket
//
//  Created by jackey_gjt on 17/2/6.
//  Copyright © 2017年 Jackey. All rights reserved.
//

#import "AppDelegate.h"
#import "ServerListViewController.h"

//typedef void (*callback)(node *obj);
typedef struct Array {
    struct node *currentNode;
    struct node *nextNode;
    int index;
    int count;
    void * value;
    struct Array * SelfArray;

//    struct Array *head;

}Array;

typedef struct node {
    void * value;
    int index;
    struct node * nextNode;
}node;
#define LEN sizeof(struct Array)
int INDEX;
node * head = NULL;
@interface AppDelegate ()

@end

@implementation AppDelegate

void calllback(node *obj){
    
    
}
//添加元素;
-(void)insertObject:(node*)obj{
    if (head==NULL) {
        return;
    }
    if (head->value ==NULL) {
        
        if (obj==NULL) {
            return;
        }
        
        head = obj;
        head->nextNode = NULL;
//        NSLog(@"第一次:%@",head->value);
        return;
    }
    
    
    //    node * currentP = head;
    static int a=0;
    a+=1;
    node * temp =NULL;
    node * nextP = head->nextNode;
    if (nextP==NULL) {
        head->nextNode = obj;
        head->nextNode->index= a;
        obj->nextNode = NULL;
        
    }
    while (nextP!=NULL) {
        //头的下一个-NULL就添加节点 否则继续遍历
//        printf("%s","--------\n");
        temp = nextP;
        nextP = nextP->nextNode;
        
    }
    
    if (temp==NULL) {
        return;
    }
    
    temp->nextNode = obj;
    obj->index =a;
    obj->nextNode = NULL;
//    printf("------index :%d\n",a);
//    printf("------head index :%d\n",head->index);
    
    
    
}


-(node *)objectAtIndex:(int)index{
    //没有初始化
    if (head==NULL) {
        NSAssert(head==NULL, @"Please initialize a instance");
    }
    node * temp = NULL;
    node * currentP = head;
    node * nextP = head->nextNode;
//    NSLog(@"初始 :%d",currentP->index);
    
    if (index==0) {
        return head;
    }
    
    while (nextP!=NULL) {
        
//        printf("%s","objc--------\n");
//        
//        NSLog(@"nextp :%d",nextP->index);
        
        if (nextP->index==index) {
            
//            NSLog(@"value :%@",nextP->value);
            temp = nextP;
            
            return temp;
        }
        currentP = nextP;
        if (currentP->nextNode==NULL) {
            break;
        }
        nextP =nextP->nextNode;
    }
    return temp;
}

-(node *)createNodeList{
    head = malloc(sizeof(node));
    if (head==NULL) {
        return NULL;
    }else {
        head->index =0;
        head->value = NULL;
        head->nextNode = NULL;
    }
    return head;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = [[ServerListViewController alloc]init];
    [self.window makeKeyAndVisible];
    
    
    
    //*************************华丽的分割线**********************************//
    //test
    [self createNodeList];
    for (int i = 0; i<5; i++) {
        node * test = malloc(sizeof(node));
        
        if (i==4) {
            test->value = @"哈哈哈哈";
        }else {
            test->value = (__bridge void *)([NSString stringWithFormat:@"%d tadasd",i]);
        }
//        NSLog(@"次数 :%d",i);
        [self insertObject:test];
        
    }
//    node * a =[self objectAtIndex:0];
//    NSLog(@"结果:%@",a->value);
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
