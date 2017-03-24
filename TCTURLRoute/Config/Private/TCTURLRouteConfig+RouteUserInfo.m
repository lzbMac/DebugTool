//
//  TCTURLRouteConfig+RouteUserInfo.m
//  TCTURLRoute
//
//  Created by maxfong on 15/8/4.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//

#import "TCTURLRouteConfig+RouteUserInfo.h"
#import "TCTURLRouteConfigDelegate.h"

@interface TCTURLRouteConfig ()

+ (instancetype)defaultRouteConfig;
- (id<TCTURLRouteConfigDelegate>)configDelegate;

@end

@implementation TCTURLRouteConfig (RouteUserInfo)

+ (BOOL)route_isLogin {
    return [[TCTURLRouteConfig defaultRouteConfig].configDelegate route_isLogin];
}
+ (NSString *)route_memberID {
    return [[TCTURLRouteConfig defaultRouteConfig].configDelegate route_memberID];
}
+ (NSString *)route_externalMemberID {
    return [[TCTURLRouteConfig defaultRouteConfig].configDelegate route_externalMemberID];
}
+ (NSString *)route_latitude {
    return [[TCTURLRouteConfig defaultRouteConfig].configDelegate route_latitude];
}
+ (NSString *)route_longitude {
    return [[TCTURLRouteConfig defaultRouteConfig].configDelegate route_longitude];
}
+ (NSString *)route_locationCityID {
    return [[TCTURLRouteConfig defaultRouteConfig].configDelegate route_locationCityID];
}
+ (NSString *)route_version {
    return [[TCTURLRouteConfig defaultRouteConfig].configDelegate route_version];
}
+ (NSString *)route_versionType {
    return [[TCTURLRouteConfig defaultRouteConfig].configDelegate route_versionType];
}
+ (NSString *)route_refid {
    return [[TCTURLRouteConfig defaultRouteConfig].configDelegate route_refid];
}
+ (NSString *)route_deviceID {
    return [[TCTURLRouteConfig defaultRouteConfig].configDelegate route_deviceID];
}
+ (NSString *)route_selectedCityID {
    return [[TCTURLRouteConfig defaultRouteConfig].configDelegate route_selectedCityID];
}

+ (NSString *)route_provinceID {
    return [[TCTURLRouteConfig defaultRouteConfig].configDelegate route_provinceID];
}

+ (NSString *)route_selectedProvinceID {
    return [[TCTURLRouteConfig defaultRouteConfig].configDelegate route_selectedProvinceID];
}
@end
