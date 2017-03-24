//
//  TCTURLRouteConfig.m
//  TCTURLRoute
//
//  Created by maxfong on 15/7/21.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//

#import "TCTURLRouteConfig.h"
#import "TCTURLRoute_STDLIB.h"
#import "NSString+TCTRoureURLHex.h"

NSString * const kRouteConfigClass      = @"_class";
NSString * const kRouteConfigBundle     = @"_bundle";
NSString * const kRouteConfigNib        = @"_nib";

NSString * const kRouteConfigHold       = @"_hold";
NSString * const kRouteConfigWantLogin  = @"_login";
NSString * const kRouteConfigWantHybrid = @"_hybrid";
NSString * const kRouteConfigCheckKeys  = @"_checkKeys";
NSString * const kRouteConfigPassKeys   = @"_passKeys";
NSString * const kRouteConfigWantLocation = @"_location";

extern NSString *const kRouteResultNative;
extern NSString *const kRouteResultWeb;
extern NSString *const kRouteResultFile;
extern NSString * const kRouteResultSECWeb;

@interface TCTURLRouteConfig ()

@property (nonatomic, strong) NSMutableDictionary *p_routeDictionary;
@property (nonatomic, strong) id<TCTURLRouteConfigDelegate> configDelegate;

@end

@implementation TCTURLRouteConfig

+ (instancetype)defaultRouteConfig {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = self.new;
    });
    return instance;
}

+ (void)addRouteDictionary:(NSDictionary *)routeDictionary {
    if ([routeDictionary isKindOfClass:[NSDictionary class]]) {
        TCTURLRouteConfig *routeConfig = [TCTURLRouteConfig defaultRouteConfig];
        [@[kRouteResultNative, kRouteResultWeb, kRouteResultFile, kRouteResultSECWeb] enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
            NSMutableDictionary *oldDict = [routeConfig.p_routeDictionary[key] mutableCopy] ?: [NSMutableDictionary dictionary];
            NSDictionary *newDict = routeDictionary[key];
            if (newDict) {
                [oldDict addEntriesFromDictionary:newDict];
            }
            if (oldDict) {
                routeConfig.p_routeDictionary[key] = oldDict;
            }
        }];
    }
}

+ (void)addRouteWithPlistPath:(NSString *)path {
    if ([path isKindOfClass:[NSString class]]) {
        NSData *plistData = [NSData dataWithContentsOfFile:path];
        if (plistData) {
            NSDictionary *dictionary = [NSPropertyListSerialization propertyListWithData:plistData
                                                                                 options:NSPropertyListImmutable
                                                                                  format:nil
                                                                                   error:nil];
            [self addRouteDictionary:dictionary];
        }
        else {
            NSAssert(plistData, ([NSString stringWithFormat:@"%@文件不存在", path]));
        }
    }
}

+ (void)addRouteWithPlistPaths:(NSArray *)paths {
    [paths enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self addRouteWithPlistPath:obj];
    }];
}

+ (NSDictionary *)routeDictionary {
    TCTURLRouteConfig *routeConfig = [TCTURLRouteConfig defaultRouteConfig];
    NSDictionary *routeDictionary = [routeConfig.p_routeDictionary copy];
    return routeDictionary;
}

+ (void)registerURLRouteConfigClass:(Class<TCTURLRouteConfigDelegate>)configClass {
    NSAssert(configClass, ([NSString stringWithFormat:@"%@ Class：不存在", NSStringFromClass(configClass)]));
    TCTURLRouteConfig *routeConfig = [TCTURLRouteConfig defaultRouteConfig];
    routeConfig.configDelegate = configClass.new;
}

#pragma mark -
- (NSMutableDictionary *)p_routeDictionary {
    return _p_routeDictionary ?: ({
        _p_routeDictionary = [NSMutableDictionary dictionary];
//        _p_routeDictionary = [[TCTURLRouteConfig p_RouteData] mutableCopy];
    });
}

#pragma mark - 需结合STDLIB方案
+ (NSDictionary *)p_RouteData {
#ifdef TC_Server_Debug
//    NSData *plistData = [NSData dataWithContentsOfFile:filePath];
//    NSDictionary *dictionary = [NSPropertyListSerialization propertyListWithData:plistData
//                                                                         options:NSPropertyListImmutable
//                                                                          format:nil
//                                                                           error:nil];
    NSDictionary *dictionary = nil;
#else
    NSString *routeString = [NSString stringFromHexString:TCTURLRoute_STDLIB];
    NSData *routeData = [routeString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:routeData
                                                               options:NSJSONReadingAllowFragments
                                                                 error:nil];
#endif
    return dictionary;
}

@end

#pragma mark - 预留STDLIB方案，数据转换HEX
@interface TCTURLRouteConfig (STDLIB)

//生成STDLIBString的方法，只支持Plist文件
+ (NSString *)STDLIBStringFromFilePath:(NSString *)filePath;

@end

@implementation TCTURLRouteConfig (STDLIB)

+ (NSString *)STDLIBStringFromFilePath:(NSString *)filePath {
    NSData *plistData = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *parameters = [NSPropertyListSerialization propertyListWithData:plistData
                                                                         options:NSPropertyListImmutable
                                                                          format:nil
                                                                           error:nil];
    NSData *stringData = [NSJSONSerialization dataWithJSONObject:parameters
                                                         options:NSJSONWritingPrettyPrinted
                                                           error:nil];
    NSString *resultString = [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
    return [NSString hexStringFromString:resultString];
}

@end