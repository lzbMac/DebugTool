//
//  DebugInfoModule.m
//  Debug_Demo
//
//  Created by ChuanRao on 2017/3/2.
//  Copyright © 2017年 ChuanRao. All rights reserved.
//

#import "DebugInfoModule.h"
#import "SHDebugTableViewController.h"
#import "SHDebugModuleProtocol.h"
#import "DebugFlexModule.h"
@implementation DebugInfoModule
+ (NSString *)moduleName {
    return @"调试开关入口";
}
+ (NSString *)moduleDetail {
    return @"Flex、logView、提示开关、点一次";
}
+(void)startModule{
    UIViewController* topViewController = [SHDebugTableViewController defaultManager];
    NSMutableArray <SHDebugModuleProtocol>* modules = [NSMutableArray<SHDebugModuleProtocol> new];
    [modules addObjectsFromArray:@[[DebugFlexModule class]
                                   
                                   ]];
    SHDebugTableViewController* newVC = [[SHDebugTableViewController alloc]initWithModule:modules];
    [topViewController.navigationController pushViewController:newVC animated:YES];
}
@end
