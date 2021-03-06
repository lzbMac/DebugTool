//
//  TCTRouteScheme.m
//  TCTURLRoute
//
//  Created by maxfong on 15/7/21.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//

#import "TCTRouteScheme.h"
#import "NSDictionary+URLQuery.h"
#import "NSString+CommonEncrypt.h"
#import "TCTGlobalManager.h"
#import "NSURL+TCTURLChar.h"
#import "NSURL+TCTURLTag.h"
#import "NSString+RemoveUnderscoreAndInitials.h"

NSString * const URLRouteVersion = @"URLRouteVersion";

NSString * const kRouteSchemeNative     = @"tctclient";     //跳转native页面
NSString * const kRouteSchemeExternal   = @"external";      //跳转外部
NSString * const kRouteSchemeWeb        = @"http";          //跳转web
NSString * const kRouteSchemeSECWeb     = @"https";         //跳转安全web
NSString * const kRouteSchemeFile       = @"file";          //
NSString * const kRouteSchemeClient     = @"tctravel";      //外部/浏览器启动客户端

@interface TCTRouteScheme ()

@property (nonatomic, strong, readwrite) NSURL *originalURL;
@property (nonatomic, strong, readwrite) NSURL *useableURL;
@property (nonatomic, strong, readwrite) NSString *query;
@property (nonatomic, strong, readwrite) NSString *scheme;
@property (nonatomic, strong, readwrite) NSString *module;           //模块
@property (nonatomic, strong, readwrite) NSString *page;             //页面
@property (nonatomic, strong, readwrite) NSDictionary *parameter;    //参数

@end

@implementation TCTRouteScheme

- (instancetype)initWithURL:(NSURL *)URL {
    self = [self init];
    if (self) {
        self.originalURL = URL;
        NSURL *aURL = self.originalURL;
        if ([aURL isInternal]) {
            aURL = [self.originalURL filterInternalTagURL];
        }
        self.scheme = aURL.scheme;
        //根据Scheme，生成不同的属性
        if ([self.scheme isEqualToString:kRouteSchemeNative] ||
            [self.scheme isEqualToString:kRouteSchemeWeb] ||
            [self.scheme isEqualToString:kRouteSchemeFile] ||
            [self.scheme isEqualToString:kRouteSchemeSECWeb]) {
            self.useableURL = aURL;
        }
        else if ([self.scheme isEqualToString:kRouteSchemeExternal] ||
                 [self.scheme isEqualToString:kRouteSchemeClient]) {
            NSString *newScheme = aURL.host;
            NSString *newPath = aURL.path;
            NSString *newQuery = aURL.query;
            NSString *newURLString = [NSString stringWithFormat:@"%@:/%@?%@", newScheme, newPath, newQuery];
            self.useableURL = [NSURL URLWithString:newURLString];
            
            if ([self.scheme isEqualToString:kRouteSchemeClient]) {
                self.scheme = self.useableURL.scheme;
            }
        }
        else {
            self.scheme = nil;
            self.useableURL = nil;
        }
        self.module = [self.useableURL.host removeUnderscoreAndInitials];
        NSString *path = self.useableURL.path;
        self.page = [[path.length ? path : nil substringFromIndex:1] removeUnderscoreAndInitials];
        self.query = self.useableURL.query;

        //兼容URL1.0传参形式
        NSString *urlMD5 = [self.originalURL.absoluteString md5];
        id param = [TCTGlobalManager objectForKey:urlMD5];
        NSDictionary *urlDict = [NSDictionary dictionaryWithURLQuery:self.useableURL.query];
        [urlDict setValue:@"2" forKey:URLRouteVersion];
        //兼容下划线首字母大写
        NSMutableDictionary *muteURLDict = [NSMutableDictionary dictionaryWithDictionary:urlDict];
        [urlDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [muteURLDict setObject:obj forKey:[key removeUnderscoreAndInitials]];
        }];
        self.parameter = param ?: muteURLDict;
    }
    return self;
}

+ (BOOL)isStandardURL:(NSURL *)url {
    NSString *scheme = url.scheme;
    BOOL isStandard = [TCTRouteScheme isStandardScheme:scheme];
    if (!isStandard && [scheme isEqualToString:kRouteSchemeClient]) {
        NSString *nScheme = url.host;
        isStandard = [TCTRouteScheme isStandardScheme:nScheme];
    }
    return isStandard;
}

+ (BOOL)isStandardScheme:(NSString *)scheme {
    return [scheme isEqualToString:kRouteSchemeNative] ||
    [scheme isEqualToString:kRouteSchemeExternal] ||
    [scheme isEqualToString:kRouteSchemeWeb] ||
    [scheme isEqualToString:kRouteSchemeFile] ||
    [scheme isEqualToString:kRouteSchemeSECWeb];
}

@end
