//
//  TCTURLRouteHold.m
//  TCTURLRoute
//
//  Created by maxfong on 15/7/22.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//

#import "TCTURLRouteHold.h"
#import "TCTURLRouteHoldConfig.h"
#import "TCTURLRouteConfig+RouteUserInfo.h"

@interface TCTURLRouteHoldConfig (TCTURLRouteHold)
+ (instancetype)defaultHoldConfig;
- (id<TCTURLRouteHoldLoginDelegate>)loginDelegate;
- (id<TCTURLRouteHoldLocationDelegate>)locationDelegate;
@end

@interface TCTURLRouteHold ()

@property (nonatomic, strong) TCTURLRouteResult *routeResult;
@property (nonatomic, copy)TCTURLRouteHoldCompleteBlock completeBlock;

@end

@implementation TCTURLRouteHold

- (void)dealHoldWithRouteResult:(TCTURLRouteResult *)routeResult completeBlock:(TCTURLRouteHoldCompleteBlock)completeBlock {
    //验证登录情况
    __block typeof(self) weakSelf = self;
    TCTURLRouteHoldConfig *holdConfig = [TCTURLRouteHoldConfig defaultHoldConfig];
    if (self.wantLogin) {
        NSString *memberID = [TCTURLRouteConfig route_memberID];
        if (memberID.length) {
            self.wantLogin = NO;
            [self dealHoldWithRouteResult:routeResult completeBlock:completeBlock];
        }
        else {
            id<TCTURLRouteHoldLoginDelegate> loginDelegate = holdConfig.loginDelegate;
            if (loginDelegate && [loginDelegate respondsToSelector:@selector(startLoginWithSuccessBlock:options:)]) {
                NSDictionary *options = @{kRouteHoldLastViewController:routeResult.lastViewController};
                [loginDelegate startLoginWithSuccessBlock:^(BOOL isLogin) {
                    if (isLogin) {
                        weakSelf.wantLogin = NO;
                        [weakSelf dealHoldWithRouteResult:routeResult completeBlock:completeBlock];
                    }
                } options:options];
            }
        }
    }
    else if (self.wantLocation) {
        NSString *latitude  = [TCTURLRouteConfig route_latitude];
        NSString *longitude = [TCTURLRouteConfig route_longitude];
        if (!latitude.length || !longitude.length) {
            id<TCTURLRouteHoldLocationDelegate> locationDeleagate = holdConfig.locationDelegate;
            if (locationDeleagate && [locationDeleagate respondsToSelector:@selector(startLocationWithSuccessBlock:options:)]) {
                NSDictionary *options = @{kRouteHoldLastViewController:routeResult.lastViewController};
                [locationDeleagate startLocationWithSuccessBlock:^(BOOL isLocation){
                    weakSelf.wantLocation = NO;
                    [weakSelf dealHoldWithRouteResult:routeResult completeBlock:completeBlock];
                } options:options];
            }
        }
        else {
            self.wantLocation = NO;
            [self dealHoldWithRouteResult:routeResult completeBlock:completeBlock];
        }
    }
    else {
        //检查passKeys
        [self.passKeys enumerateObjectsUsingBlock:^(NSString *propertyName, NSUInteger idx, BOOL *stop) {
            if ([propertyName isKindOfClass:[NSString class]]) {
                id lastViewController = routeResult.lastViewController;
                SEL selector = NSSelectorFromString(propertyName);
                if ([lastViewController respondsToSelector:selector]) {
                    id viewController = routeResult.viewController;
                    id propertyValue = [lastViewController valueForKey:propertyName];
                    if ([viewController respondsToSelector:selector]) {
                        [viewController setValue:propertyValue forKey:propertyName];
                    }
                }
            }
        }];
        //检查属性
        [self.checkKeys enumerateObjectsUsingBlock:^(NSString *propertyName, NSUInteger idx, BOOL *stop) {
            if ([propertyName isKindOfClass:[NSString class]]) {
                NSDictionary *param = routeResult.parameter;
                id obj = param[propertyName];
                if (!obj) {
                    NSAssert(obj, ([NSString stringWithFormat:@"链接未提供页面%@值", propertyName]));
                }
            }
        }];
        //自定义操作
        BOOL dontHold = YES;
        if (self.holdController.length > 0) {
            Class cls = NSClassFromString(self.holdController);
            id<TCTURLRouteHoldProtocol> holdObj = cls.new;
            if ([holdObj respondsToSelector:@selector(holdWithParameters:)]) {
                NSMutableDictionary *param = [NSMutableDictionary dictionary];
                if (routeResult.viewController) [param setValue:routeResult.viewController forKey:kRouteHoldParameter];
                if (routeResult.lastViewController) [param setValue:routeResult.lastViewController forKey:kRouteHoldLastViewController];
                if (routeResult.parameter) [param setValue:routeResult.parameter forKey:kRouteHoldParameter];
                
                dontHold = NO;
                [holdObj holdWithParameters:param];
            }
        }
        //正常回调
        if (dontHold && completeBlock) {
            completeBlock(routeResult, routeResult.parameter);
        }
    }
}

@end
