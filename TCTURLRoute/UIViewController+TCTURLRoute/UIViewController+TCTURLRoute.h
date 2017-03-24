//
//  UIViewController+TCTURLRoute.h
//  TCTURLRoute
//
//  Created by maxfong on 15/7/21.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "TCTURLRoutePopProtocol.h"
#import "TCTURLRoutePushProtocol.h"

/** URL规则处理失败 */
extern NSString * const TCTURLRouteHandleErrorNotification;
/** URL规则处理完成 */
extern NSString * const TCTURLRouteHandleCompleteNotification;

typedef void(^TCTURLRouteOpenCompletion)(void); //->kURLRouteOpenCompletion
typedef void(^TCTURLRouteOpenLoginCompletionBlock)(BOOL isLogin, NSDictionary *options);

extern NSString *const kURLRouteOpenAnimated;           //是否需要动画，默认@YES
extern NSString *const kURLRouteOpenAnimatedTransition; //动画形式，默认@(URLRouteOpenAnimatedPush)
extern NSString *const kURLRouteOpenCompletion;         //完成后回调操作，默认nil

typedef NS_ENUM(NSUInteger, URLRouteOpenAnimatedTransition) {
    URLRouteOpenAnimatedPush,
    URLRouteOpenAnimatedPresent
};

@interface UIViewController (TCTURLRoute) <TCTURLRoutePopProtocol, TCTURLRoutePushProtocol>

/**
 *  根据URL打开页面，当前版本不支持自定义页面跳转方式
 *
 *  @param url      只支持2.0规则，例如：scheme://module/page[?][key=value&key=value]
 *  @param options  自定义kURLRouteOpen参数
 */
- (void)openRouteURL:(NSURL *)url options:(NSDictionary *)options;

/**
 *  打开登录
 *
 *  @param completion 登录完成后调用completion & 已登录直接调用completion
 */
- (void)openLoginWithCompletion:(TCTURLRouteOpenLoginCompletionBlock)completion;

@end

@interface UIViewController (TCTURLRouteCompatible)

/**
 *  传入String，兼容1.0规则，统一调用bridge
 */
- (void)openRouteURLString:(NSString *)aString options:(NSDictionary *)options;

@end

@interface UIViewController (TCTURLRouteHoldObject)

/**
 *  维持处理Hold的对象的生命周期
 *  需要重新获取则使用NSDictionary
 *  只需要位置使用NSArray
 *  默认NSObject
 */
@property (nonatomic, strong) id holdObject;

@end
