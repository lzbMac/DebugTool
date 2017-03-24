//
//  DebugFlexModule.m
//  Debug_Demo
//
//  Created by ChuanRao on 2017/3/2.
//  Copyright © 2017年 ChuanRao. All rights reserved.
//

#import "DebugFlexModule.h"
#import "FLEXManager.h"
#import "SHDebugTableViewController.h"
@implementation DebugFlexModule
+ (NSString *)moduleName {
    return @"FLEX Tool";
}

+ (void)startModule {
    [[FLEXManager sharedManager] showExplorer];
    UIViewController* vc = [SHDebugTableViewController defaultManager];
    [vc.navigationController popToViewController:[SHDebugTableViewController defaultManager].currentVc animated:YES];
}

+ (NSString *)moduleDetail {
    return @"";
}
@end
