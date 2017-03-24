//
//  UIViewController+TCTURLRoute.m
//  TCTURLRoute
//
//  Created by maxfong on 15/7/21.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//

#import "UIViewController+TCTURLRoute.h"
#import "UIViewController+TCTURLRouteCallBack.h"
#import <objc/runtime.h>
#import "TCTURLRoute.h"
#import "TCTURLRouteConfig+RouteUserInfo.h"
#import "TCTURLRouteResult.h"
#import "TCTURLRouteHoldConfig.h"
#import "TCTURLBridge.h"
#import "NSURL+TCTURLChar.h"
#import "NSURL+TCTURLTag.h"

NSString *const TCTURLRouteHandleErrorNotification = @"TCTURLRouteHandleErrorNotification";
NSString *const TCTURLRouteHandleCompleteNotification = @"TCTURLRouteHandleCompleteNotification";
NSString *const kURLRouteOpenAnimated = @"kURLRouteOpenAnimated";           //是否需要动画
NSString *const kURLRouteOpenAnimatedTransition = @"kURLRouteOpenAnimatedTransition"; //动画形式
NSString *const kURLRouteOpenCompletion = @"kURLRouteOpenCompletion";         //完成后回调操作

extern NSString * const kRouteOriginalURLString;

@interface TCTURLRouteHoldConfig (TCTURLRouteHold)
+ (instancetype)defaultHoldConfig;
- (id<TCTURLRouteHoldLoginDelegate>)loginDelegate;
@end

@implementation UIViewController (TCTURLRoute)

#pragma mark -
- (void)openRouteURL:(NSURL *)url options:(NSDictionary *)options {
    if (!url) return;
    NSURL *newURL = url;
    if ([url isInternal]) {
        //简单的URL可以bridge
        newURL = [TCTURLBridge routeURLFromString:url.absoluteString];
    }
    //通知Tag变更
    NSDictionary *dictTags = [newURL requestTags];
    NSString *tagCode = dictTags[kURLTagNativeCode];
    NSString *webCode = dictTags[kURLTagWebCode];
    if (tagCode.length) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kURLFetchInternalTagCodeNotification object:tagCode];
    }
    if (webCode.length) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kURLFetchInternalWebCodeNotification object:webCode];
    }
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    dictionary[kRouteResultLastViewController] = [self p_route_lastViewController];
    dictionary[kRouteResultUseableURL] = newURL;
    [dictionary addEntriesFromDictionary:options];
    
#ifdef TC_Server_Debug
    NSLog(@"URLRoute开始扫描plist数据");  //这里是假的 -. -
    NSLog(@"URLRoute扫描完毕");
    NSLog(@"URLRoute即将使用的URL为:%@", url);
#endif
    [self p_route_openRouteURL:newURL options:dictionary];
#ifdef TC_Server_Debug
    NSLog(@"URLRoute准备结束");
    NSLog(@"URLRoute已结束");
#endif
}

#pragma mark -
- (UIViewController *)p_route_lastViewController {
    UIViewController *viewController = nil;
    if ([self isKindOfClass:[UINavigationController class]]) {
        viewController = ((UINavigationController *)self).topViewController;
    }
    else if ([self isKindOfClass:[UIViewController class]]) {
        viewController = self;
    }
    else {
        NSAssert(viewController, ([NSString stringWithFormat:@"CTURLRoute Tip:缺少Nav"]));
    }
    return viewController;
}

- (void)p_route_openRouteURL:(NSURL *)routeURL options:(NSDictionary *)dict
{
    BOOL success = [p_route_URLRoute() routeWithURL:routeURL options:dict completeblock:^(TCTURLRouteResult *result, NSDictionary *otherOptions) {
        NSDictionary *options = otherOptions ?: dict;
        switch (result.openType) {
            case URLRouteOpenWeb:
            case URLRouteOpenNative: {
                UIViewController *viewController = result.viewController;
                UIViewController *lastViewController = result.lastViewController;
                //设置callback值
                viewController.routeCallBackViewController = lastViewController;
                
                NSDictionary *param = result.parameter;
                if (lastViewController) {
                    //Push前回调，供对象属性参数初始化
                    if ([viewController respondsToSelector:@selector(routeWillPushControllerWithParam:)]) {
                        [viewController routeWillPushControllerWithParam:param];
                    }
                    //具体页面打开操作
                    NSArray *allOpenKeys = options.allKeys;
                    BOOL animated = YES;
                    if ([allOpenKeys containsObject:kURLRouteOpenAnimated]) {
                        animated = [options[kURLRouteOpenAnimated] boolValue];
                    }
                    TCTURLRouteOpenCompletion completion = nil;
                    if ([allOpenKeys containsObject:kURLRouteOpenCompletion]) {
                        completion = options[kURLRouteOpenCompletion];
                    }
                    URLRouteOpenAnimatedTransition openType = URLRouteOpenAnimatedPush;
                    if ([allOpenKeys containsObject:kURLRouteOpenAnimatedTransition]) {
                        openType = [options[kURLRouteOpenAnimatedTransition] integerValue];
                    }
                    switch (openType) {
                        case URLRouteOpenAnimatedPush: {
                            [lastViewController.navigationController pushViewController:viewController animated:animated];
                            if (completion) completion();
                        } break;
                        case URLRouteOpenAnimatedPresent: {
                            [lastViewController presentViewController:viewController animated:animated completion:completion];
                        } break;
                        default:
                            break;
                    }
                    //Push后回调，做一些清理操作
                    if ([viewController respondsToSelector:@selector(routeDidPushControllerWithParam:)]) {
                        [viewController routeDidPushControllerWithParam:param];
                    }
                }
                else {
                    NSAssert(lastViewController, ([NSString stringWithFormat:@"%@的NavigationController不存在，无法push", NSStringFromClass([self class])]));
                }
            }
                break;
            case URLRouteOpenExternal: {
                NSURL *URL = options[kRouteResultUseableURL];
                [[UIApplication sharedApplication] openURL:URL];
            }
                break;
            default: break;
        }
    }];
    if (success) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TCTURLRouteHandleCompleteNotification object:dict];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:TCTURLRouteHandleErrorNotification object:routeURL];
    }
}

#pragma mark -
static TCTURLRoute *p_route_URLRoute() {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = TCTURLRoute.new;
    });
    return instance;
}

#pragma mark -
- (void)openLoginWithCompletion:(TCTURLRouteOpenLoginCompletionBlock)completion {
    __weak typeof(self) weakSelf = self;
    __block NSDictionary *options = @{kRouteHoldLastViewController:weakSelf};
    if ([TCTURLRouteConfig route_isLogin]) {
        if (completion) completion(YES, options);
    }
    else {
        TCTURLRouteHoldConfig *holdConfig = [TCTURLRouteHoldConfig defaultHoldConfig];
        id<TCTURLRouteHoldLoginDelegate> loginDelegate = holdConfig.loginDelegate;
        if (loginDelegate && [loginDelegate respondsToSelector:@selector(startLoginWithSuccessBlock:options:)]) {
            
            [loginDelegate startLoginWithSuccessBlock:^(BOOL isLogin) {
                if (completion) completion(isLogin, options);
            } options:options];
        }
    }
}

@end

@implementation UIViewController (TCTURLRouteCompatible)

- (void)openRouteURLString:(NSString *)aString options:(NSDictionary *)options {
    if (!aString.length) return;
#ifdef TC_Server_Debug
    NSLog(@"URLRoute准备接收");
    NSLog(@"URLRoute已接收%@", aString);
    NSLog(@"URLRoute验证转换状态");
#endif
    NSURL *url = [TCTURLBridge routeURLFromString:aString];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setValue:aString forKey:kRouteOriginalURLString];
    [dictionary addEntriesFromDictionary:options];
    [self openRouteURL:url options:dictionary];
}

@end


@implementation UIViewController (TCTURLRouteHoldObject)

- (id)holdObject {
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setHoldObject:(id)holdObject {
    objc_setAssociatedObject(self, @selector(holdObject), holdObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
