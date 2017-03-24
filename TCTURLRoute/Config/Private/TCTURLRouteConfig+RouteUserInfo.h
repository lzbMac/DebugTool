//
//  TCTURLRouteConfig+RouteUserInfo.h
//  TCTURLRoute
//
//  Created by maxfong on 15/8/4.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//

#import "TCTURLRouteConfig.h"

@interface TCTURLRouteConfig (RouteUserInfo)

+ (BOOL)route_isLogin;
+ (NSString *)route_memberID;
+ (NSString *)route_externalMemberID;
+ (NSString *)route_latitude;
+ (NSString *)route_longitude;
+ (NSString *)route_locationCityID;
+ (NSString *)route_version;
+ (NSString *)route_versionType;
+ (NSString *)route_refid;
+ (NSString *)route_deviceID;
+ (NSString *)route_selectedCityID;
+ (NSString *)route_provinceID;
+ (NSString *)route_selectedProvinceID;
@end
