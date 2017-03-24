//
//  TCTURLBridge.h
//  TCTURLRoute
//
//  Created by maxfong on 15/7/21.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCTURLBridge : NSObject

/**
 *  验证规则是否正确，正确的1.0规则会转成2.0规则
 *  @param aSting URL1.0 String
 *  @return URL2.0
 */
+ (NSURL *)routeURLFromString:(NSString *)aSting;

/**
 *  自定义生成URL规则
 *
 *  @param mudule    模块
 *  @param page      页面
 *  @param parameter 参数
 *
 *  @return URL2.0规则
 */
+ (NSURL *)routeURLWithModule:(NSString *)module page:(NSString *)page parameter:(NSDictionary *)parameter;

/**
 *  string解析成dictionary，兼容string中有多个？
 *
 *  @param aString 一个url string
 *
 *  @return Dictionary @{@"xxx":@"xxxxx",@"yyy":@"yyyy"}
 */
+ (NSDictionary *)dictionaryWithString:(NSString *)aString;

@end
