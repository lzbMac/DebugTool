//
//  TCTURLRoutePushProtocol.h
//  TCTURLRoute
//
//  Created by maxfong on 15/7/21.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const URLRouteVersion;

@protocol TCTURLRoutePushProtocol

@optional

/**
 *  url路由跳转时，对viewcontroller进行数据配置
 *
 *  @param info 传入的url字典数据，包括处理后url的key： kRouteConfigureFormatUrlKey 以及页面具体参数
 */
- (void)routeWillPushControllerWithParam:(NSDictionary *)param;

/**
 *  页面push跳转后调用
 *
 *  @param info 传入的url字典数据，包括处理后url的key： kRouteConfigureFormatUrlKey 以及页面具体参数
 */
- (void)routeDidPushControllerWithParam:(NSDictionary *)param;

@end
