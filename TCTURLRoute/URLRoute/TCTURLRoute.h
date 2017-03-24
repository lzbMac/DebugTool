//
//  TCTURLRoute.h
//  TCTURLRoute
//
//  Created by maxfong on 15/7/21.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TCTURLRouteResult;

typedef void (^TCTURLRouteCompleteBlock)(TCTURLRouteResult *result, NSDictionary *options);

@interface TCTURLRoute : NSObject

- (BOOL)routeWithURL:(NSURL *)URL options:(NSDictionary *)options completeblock:(TCTURLRouteCompleteBlock)completeBlock;

@end

/*
 1、web跳转native页面 tctclient://project/module[data]   
    例:tctclient://hotel/home?id=1&name=dd
    tctclient 协议头,区分老版本和跳转native的标识
    project 项目标识
    module 具体模块标识
    data 承载附带的数据，统一数据格式为 ?key=value&key1=value1... (非基本类型一律使用json格式)
 2、web跳转外部 external://type/[host]/path
    例:external://http/home?id=1&name=dd
    external 协议头,区分老版本和跳转外部的标识
    type 实际协议头,如 （http , https , weixing ...）
    [host]/path 实际域名/实际路径 为拼接至实际协议头，如 weixing://[host]/path
 3、web跳转web http://host/path
    例:http://www.baidu.com
    http 协议头，不区分老版本
    过渡期 不区分新老版本，一律走老版本规则
    废老版 区分只为跳转web做协议头
 4、外部/浏览器启动客户端 tctravel://host/path/data
    例:tctravel://tctclient/hotel/home?id=1&name=dd
    tctravel 为客户端定义的schema
    host 为客户端定义的host，理论为以上三种协议头 （tctclient,external,http）,实际暂时只支持tctclient
    path 为具体路径拼接至 host部分组成新url 走以上三种协议
 */

