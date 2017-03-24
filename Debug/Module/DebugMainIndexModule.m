//
//  DebugMainIndexModult.m
//  Debug_Demo
//
//  Created by ChuanRao on 2017/3/2.
//  Copyright © 2017年 ChuanRao. All rights reserved.
//

#import "DebugMainIndexModule.h"
#import "SHDebugTableViewController.h"
@implementation DebugMainIndexModule
+ (NSString *)moduleName{
    return @"返回到首页";
}
+ (void)startModule{
    UIViewController* vc = [SHDebugTableViewController defaultManager];
    [vc.navigationController popToViewController:[SHDebugTableViewController defaultManager].currentVc animated:YES];
}

+ (NSString *)moduleDetail{
    return nil;
}
@end
