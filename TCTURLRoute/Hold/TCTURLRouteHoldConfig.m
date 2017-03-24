//
//  TCTURLRouteHoldConfig.m
//  TCTURLRoute
//
//  Created by maxfong on 15/7/22.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//

#import "TCTURLRouteHoldConfig.h"

NSString * const kRouteHoldLastViewController = @"TCTURLRouteHoldLastViewController";
NSString * const kRouteHoldViewController = @"kRouteHoldViewController";
NSString * const kRouteHoldParameter = @"kRouteHoldParameter";

@interface TCTURLRouteHoldConfig ()

@property (nonatomic, strong) id<TCTURLRouteHoldLoginDelegate> loginDelegate;
@property (nonatomic, strong) id<TCTURLRouteHoldLocationDelegate> locationDelegate;

@end

@implementation TCTURLRouteHoldConfig

+ (instancetype)defaultHoldConfig {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = self.new;
    });
    return instance;
}

+ (void)registerURLRouteHoldLoginClass:(Class<TCTURLRouteHoldLoginDelegate>)loginClass {
    id<TCTURLRouteHoldLoginDelegate> login = loginClass.new;
    [TCTURLRouteHoldConfig defaultHoldConfig].loginDelegate = login;
}

+ (void)registerURLRouteHoldLocationClass:(Class<TCTURLRouteHoldLocationDelegate>)locationClass {
    id<TCTURLRouteHoldLocationDelegate> location = locationClass.new;
    [TCTURLRouteHoldConfig defaultHoldConfig].locationDelegate = location;
}

@end
