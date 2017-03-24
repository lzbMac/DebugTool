//
//  SHDebugTableViewController.h
//  Debug_Demo
//
//  Created by ChuanRao on 2017/3/2.
//  Copyright © 2017年 ChuanRao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHDebugModuleProtocol.h"
@interface SHDebugTableViewController : UITableViewController

@property (nonatomic, weak)UIViewController *currentVc;

+ (instancetype) defaultManager;
- (instancetype )initWithModule:(NSMutableArray<SHDebugModuleProtocol> *)modules;
//+(UIViewController *)topViewController;//拿到当前控制器
@end
