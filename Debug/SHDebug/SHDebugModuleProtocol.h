//
//  SHDebugModleProtocol.h
//  Debug_Demo
//
//  Created by ChuanRao on 2017/3/2.
//  Copyright © 2017年 ChuanRao. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SHDebugModuleProtocol <NSObject>
/** 显示名称，对应cell.textLabel.text */
+ (NSString *)moduleName;

/** 开始执行点击事件 */
+ (void)startModule;

@optional

/** 描述，对应cell.detailTextLabel.text */
+ (NSString *)moduleDetail;
@end
