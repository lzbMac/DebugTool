//
//  TCTURLRoutePopProtocol.h
//  TCTURLRoute
//
//  Created by maxfong on 15/7/21.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TCTURLRoutePopProtocol <NSObject>

@optional

/**
 *  使用url路由返回时，对viewcontroller进行数据配置
 *
 *  @param info 传入的url字典数据，包括页面具体参数
 */
- (void)routePopOutWithParam:(NSDictionary *)param;

@end
