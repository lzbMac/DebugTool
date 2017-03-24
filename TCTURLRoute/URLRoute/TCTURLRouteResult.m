//
//  TCTURLRouteResult.m
//  TCTURLRoute
//
//  Created by maxfong on 15/7/21.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//

#import "TCTURLRouteResult.h"

NSString * const kRouteResultNative     = @"tctclient";     //跳转native页面
NSString * const kRouteResultExternal   = @"external";      //跳转外部
NSString * const kRouteResultWeb        = @"http";          //跳转web
NSString * const kRouteResultSECWeb     = @"https";         //跳转web
NSString * const kRouteResultFile       = @"file";          //等价web
NSString * const kRouteResultClient     = @"tctravel";      //外部浏览器启动客户端

NSString * const kRouteResultLastViewController = @"kRouteResultLastViewController";
NSString * const kRouteResultUseableURL = @"kRouteResultUseableURL";
NSString * const kRouteResultOriginalURL = @"kRouteResultOriginalURL";
NSString * const kRouteOriginalURLString = @"kRouteOriginalURLString";

@interface TCTURLRouteResult ()

@property (nonatomic, assign, readwrite) TCTURLRouteOpenType openType;

@end

@implementation TCTURLRouteResult

- (instancetype)initWithScheme:(NSString *)scheme {
    self = [self init];
    if (self) {
        if ([scheme isEqualToString:kRouteResultNative]) {
            self.openType = URLRouteOpenNative;
        }
        else if ([scheme isEqualToString:kRouteResultExternal]) {
            self.openType = URLRouteOpenExternal;
        }
        else if ([scheme isEqualToString:kRouteResultWeb] ||
                 [scheme isEqualToString:kRouteResultFile] ||
                 [scheme isEqualToString:kRouteResultSECWeb]) {
            self.openType = URLRouteOpenWeb;
        }
        else {
            self.openType = URLRouteOpenUndefine;
        }
    }
    return self;
}

@end
