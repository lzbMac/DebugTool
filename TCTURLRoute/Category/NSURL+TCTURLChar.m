//
//  NSURL+TCTURLChar.m
//  TCTURLRoute
//
//  Created by maxfong on 15/7/25.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//

#import "NSURL+TCTURLChar.h"
#import "TCTURLRouteConfig+RouteUserInfo.h"

NSString *const kURLRouteCharacterWebViewMemberId = @"tcwvmid";
NSString *const kURLRouteCharacterWebViewVersion = @"tcwvver";
NSString *const kURLRouteCharacterWebViewLongitude = @"tcwvlon";
NSString *const kURLRouteCharacterWebViewLatitude = @"tcwvlat";
NSString *const kURLRouteCharacterWebViewCityID = @"tcwvcid";
NSString *const kURLRouteCharacterWebViewProvinceID = @"tcwvpid";
NSString *const kURLRouteCharacterWebViewSelectCityID = @"tcwvscid";    //大首页当前城市id
NSString *const kURLRouteCharacterWebViewSelectProvinceID = @"tcwvspid";    //大首页当前省份id
NSString *const kURLRouteCharacterWebViewVersionType = @"tcwvvtp";
NSString *const kURLRouteCharacterWebViewRefID = @"tcwvrefid";
NSString *const kURLRouteCharacterWebViewDeviceId = @"tcwvdeviceid";    //tcwvdeviceid:deviceid替换

NSString *const kURLRouteCharacherWebViewOpenNew = @"tcwvcnew";         //打开新页面
NSString *const kURLRouteCharacherWebViewBrowserOpen = @"tcwvcexurl";   //用浏览器打开当前链接

NSString *const kURLRouteCharacherWebViewLogin = @"tcwvclogin";         //链接需要登录

@implementation NSURL (TCTURLChar)

#pragma mark -
- (BOOL)isInternal {
    NSString *URLString = [self absoluteString];
    NSString *internalString = @"http://shouji.17u.cn/internal";
    NSRange range = [URLString rangeOfString:internalString];
    return !(range.location == NSNotFound);
}

- (BOOL)isRouteScheme {
    NSString *scheme = @"tctclient";
    return [[self.scheme lowercaseString] isEqualToString:scheme];
}

- (BOOL)isNeedLogin {
    NSString *URLString = [self absoluteString];
    NSRange range = [URLString rangeOfString:kURLRouteCharacherWebViewLogin];
    return !(range.location == NSNotFound);
}

- (BOOL)isContainWebViewCharacter {
    __block BOOL contain = NO;
    NSString *URLString = [self absoluteString];
    [replaceWebViewCharacters() enumerateObjectsUsingBlock:^(NSString *character, NSUInteger idx, BOOL *stop) {
        if ([URLString rangeOfString:character].location != NSNotFound) {
            *stop = contain = YES;
        }
    }];
    return contain;
}

- (BOOL)isContainWebViewCharacterOpenNew {
    NSString *URLString = [self absoluteString];
    if ([URLString rangeOfString:kURLRouteCharacherWebViewOpenNew].location != NSNotFound) {
        return YES;
    }
    return NO;
}

- (BOOL)isContainWebViewCharacterBrowserOpen {
    NSString *URLString = [self absoluteString];
    if ([URLString rangeOfString:kURLRouteCharacherWebViewBrowserOpen].location != NSNotFound) {
        return YES;
    }
    return NO;
}

#pragma mark -
- (NSURL *)replaceOpenNewCharacter {
    NSString *absoluteString = [self absoluteString];
    NSString *URLString = [absoluteString stringByReplacingOccurrencesOfString:kURLRouteCharacherWebViewOpenNew withString:@"noeffect"];
    return [NSURL URLWithString:URLString];
}

- (NSURL *)replaceWebViewCharacter {
    NSMutableDictionary *charDictionary = [NSMutableDictionary dictionary];
    charDictionary[kURLRouteCharacterWebViewMemberId] = [TCTURLRouteConfig route_externalMemberID] ?: @"";
    charDictionary[kURLRouteCharacterWebViewVersion] = [TCTURLRouteConfig route_version] ?: @"";
    charDictionary[kURLRouteCharacterWebViewLatitude] = [TCTURLRouteConfig route_latitude] ?: @"";
    charDictionary[kURLRouteCharacterWebViewLongitude] = [TCTURLRouteConfig route_longitude] ?: @"";
    charDictionary[kURLRouteCharacterWebViewCityID] = [TCTURLRouteConfig route_locationCityID] ?: @"";
    charDictionary[kURLRouteCharacterWebViewSelectCityID] = [TCTURLRouteConfig route_selectedCityID] ?: @"";
    charDictionary[kURLRouteCharacterWebViewVersionType] = [TCTURLRouteConfig route_versionType] ?: @"";
    charDictionary[kURLRouteCharacterWebViewRefID] = [TCTURLRouteConfig route_refid] ?: @"";
    charDictionary[kURLRouteCharacterWebViewDeviceId] = [TCTURLRouteConfig route_deviceID] ?: @"";
    charDictionary[kURLRouteCharacterWebViewProvinceID] = [TCTURLRouteConfig route_provinceID] ?: @"";
    charDictionary[kURLRouteCharacterWebViewSelectProvinceID] = [TCTURLRouteConfig route_selectedProvinceID] ?: @"";
    
    __block NSString *URLString = [self absoluteString];
    [replaceWebViewCharacters() enumerateObjectsUsingBlock:^(NSString *character, NSUInteger idx, BOOL *stop) {
        NSString *repString = charDictionary[character];
        URLString = [URLString stringByReplacingOccurrencesOfString:character withString:repString];
    }];
    return [NSURL URLWithString:URLString];
}

#pragma mark - 
static NSArray *replaceWebViewCharacters() {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = @[kURLRouteCharacterWebViewMemberId,
                     kURLRouteCharacterWebViewVersion,
                     kURLRouteCharacterWebViewLatitude,
                     kURLRouteCharacterWebViewLongitude,
                     kURLRouteCharacterWebViewCityID,
                     kURLRouteCharacterWebViewSelectCityID,
                     kURLRouteCharacterWebViewVersionType,
                     kURLRouteCharacterWebViewRefID,
                     kURLRouteCharacterWebViewDeviceId,
                     kURLRouteCharacterWebViewProvinceID,
                     kURLRouteCharacterWebViewSelectProvinceID];
    });
    return instance;
}

@end
