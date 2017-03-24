//
//  TCTURLRouteHoldConfig.h
//  TCTURLRoute
//
//  Created by maxfong on 15/7/22.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//

#import <Foundation/Foundation.h>

/** options的一些KEY */
extern NSString * const kRouteHoldLastViewController;   //堆栈的最后一个页面控制器
extern NSString * const kRouteHoldViewController;       //URL生成的ViewController
extern NSString * const kRouteHoldParameter;            //URL生成的属性参数

@protocol TCTURLRouteHoldLoginDelegate <NSObject>

/**
 *  注册登录的类需要实现的协议方法
 *
 *  @param block  isLogin判断登录还是失败
 */
- (void)startLoginWithSuccessBlock:(void(^)(BOOL isLogin))block options:(NSDictionary *)options;

@end

@protocol TCTURLRouteHoldLocationDelegate <NSObject>

/**
 *  注册定位的类需要实现的协议方法
 *
 *  @param block   isLocation参数暂时预留，现统一YES，回调方法内不需要做判断
 */
- (void)startLocationWithSuccessBlock:(void(^)(BOOL isLocation))block options:(NSDictionary *)options;

@end

@interface TCTURLRouteHoldConfig : NSObject

/**
 *  注册登录协议，由URLRoute默认实现
 *
 *  @param loginClass Hold登录类，类需实现TCTURLRouteHoldLoginDelegate协议
 */
+ (void)registerURLRouteHoldLoginClass:(Class<TCTURLRouteHoldLoginDelegate>)loginClass;

/**
 *  注册定位协议
 *
 *  @param loginClass Hold定位类，需要实现TCTURLRouteHoldLocationDelegate
 */
+ (void)registerURLRouteHoldLocationClass:(Class<TCTURLRouteHoldLocationDelegate>)locationClass;

@end
