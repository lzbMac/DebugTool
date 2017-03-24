//
//  TCTURLRoute.m
//  TCTURLRoute
//
//  Created by maxfong on 15/7/21.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//

#import "TCTURLRoute.h"
#import <UIKit/UIViewController.h>
#import "TCTURLRouteConfig.h"
#import "TCTURLRouteResult.h"
#import "TCTURLRouteHold.h"
#import "TCTRouteScheme.h"
#import "NSURL+TCTURLChar.h"

static NSMutableDictionary *routeControllersMap = nil;

@interface TCTURLRoute ()

@property (nonatomic, strong) NSDictionary *routeDictionary;

@end

@implementation TCTURLRoute

+ (instancetype)defaultURLRoute {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = self.new;
    });
    return instance;
}

- (NSDictionary *)routeDictionary {
    return _routeDictionary ?: ({ _routeDictionary = [TCTURLRouteConfig routeDictionary]; });
}

- (BOOL)routeWithURL:(NSURL *)URL options:(NSDictionary *)options completeblock:(TCTURLRouteCompleteBlock)completeBlock {
    BOOL isStandard = [TCTRouteScheme isStandardURL:URL];
    if (isStandard) {   //新规则
        NSMutableDictionary *blockParam = [NSMutableDictionary dictionary];
        [blockParam addEntriesFromDictionary:options];
        //根据URL在TCTRoute得到dict，或者是一个对象，可以得到项目、页面
        TCTRouteScheme *routeScheme = [[TCTRouteScheme alloc] initWithURL:URL];
        //根据规则修改成可用URL
        [blockParam addEntriesFromDictionary:routeScheme.parameter];
        blockParam[kRouteResultUseableURL] = routeScheme.useableURL;
        blockParam[kRouteResultOriginalURL] = routeScheme.originalURL;
        
        TCTURLRouteResult *routeResult = [[TCTURLRouteResult alloc] initWithScheme:routeScheme.scheme];
        routeResult.lastViewController = blockParam[kRouteResultLastViewController];
        routeResult.parameter = blockParam;
        
        switch (routeResult.openType) {
            case URLRouteOpenNative: {
                //根据这个对象在routeDictionary里获取对应的ViewController类
                NSDictionary *schemeDictionary = self.routeDictionary[routeScheme.scheme];
                if (!schemeDictionary) return NO;
                NSDictionary *moduleDictionary = schemeDictionary[routeScheme.module];
                if (!moduleDictionary) {
                    NSLog(@"%@", [NSString stringWithFormat:@"TCTURLRoute module值错误：“%@”不存在", routeScheme.module]);
                    return NO;
                }
                NSDictionary *pageDictionary = moduleDictionary[routeScheme.page];
                if (!pageDictionary) {
                    NSLog(@"%@", [NSString stringWithFormat:@"TCTURLRoute page值错误：“%@”不存在", routeScheme.page]);
                    return NO;
                }

                NSString *bundleName = pageDictionary[kRouteConfigBundle] ?: moduleDictionary[kRouteConfigBundle];
                routeResult.viewController = [self viewControllerWithPageDictionary:pageDictionary withBundleName:bundleName];
                
                TCTURLRouteHold *routeHold = [self routeHoldWithPageDictionary:pageDictionary];
                //从链接中获取是否需要登录
                BOOL needLogin = [URL isNeedLogin];
                if (needLogin) routeHold.wantLogin = YES;
                if (routeHold) {
                    [routeHold dealHoldWithRouteResult:routeResult completeBlock:completeBlock];
                }
                else {
                    if (completeBlock) completeBlock(routeResult, blockParam);
                }
            }
                break;
            case URLRouteOpenWeb: {
                NSDictionary *pageDictionary = self.routeDictionary[routeScheme.scheme];
                if (!pageDictionary) {
                    NSLog(@"%@", [NSString stringWithFormat:@"TCTURLRoute page值错误：“%@”不存在", routeScheme.scheme]);
                    return NO;
                }
                routeResult.viewController = [self viewControllerWithPageDictionary:pageDictionary withBundleName:nil];
                routeResult.parameter = blockParam;    //将UseableURL传出去
                
                TCTURLRouteHold *routeHold = [self routeHoldWithPageDictionary:pageDictionary];
                BOOL needLogin = [URL isNeedLogin]; //
                if (needLogin) routeHold.wantLogin = YES;
                if (routeHold) {
                    [routeHold dealHoldWithRouteResult:routeResult completeBlock:completeBlock];
                }
                else {
                    if (completeBlock) completeBlock(routeResult, blockParam);
                }
            }
                break;
            case URLRouteOpenExternal: {
                if (completeBlock) completeBlock(routeResult, blockParam);
            }
                break;
            default: {
                //FIXME:默认操作，打开一个网址，传入无法解析的URL
            }
                break;
        }
    }
    else {  //20160307 错误规则直接跳转外部
        NSString *scheme = @"http";
        TCTURLRouteResult *routeResult = [[TCTURLRouteResult alloc] initWithScheme:scheme];
        routeResult.lastViewController = options[kRouteResultLastViewController];
        routeResult.parameter = options;
        
        NSDictionary *pageDictionary = self.routeDictionary[scheme];
        routeResult.viewController = [self viewControllerWithPageDictionary:pageDictionary withBundleName:nil];
        routeResult.parameter = options;    //将UseableURL传出去
        
        TCTURLRouteHold *routeHold = [self routeHoldWithPageDictionary:pageDictionary];
        if (routeHold) {
            [routeHold dealHoldWithRouteResult:routeResult completeBlock:completeBlock];
        }
        else {
            if (completeBlock) completeBlock(routeResult, options);
        }
        return NO;
    }
    return YES;
}

- (UIViewController *)viewControllerWithPageDictionary:(NSDictionary *)pageDictionary withBundleName:(NSString *)bundleName {
    NSString *pageClassName = pageDictionary[kRouteConfigClass];
    if (pageClassName.length) {
        NSString *pageBundleName = pageDictionary[kRouteConfigBundle] ?: bundleName;
        NSString *pageNibName = pageDictionary[kRouteConfigNib] ?: pageClassName;
        
        Class cls = NSClassFromString(pageClassName);
        if (cls && [cls isSubclassOfClass:[UIViewController class]]) {
            NSBundle *bundle = nil;
            if (pageBundleName.length) {
                bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:pageBundleName ofType:@"bundle"]];
            }
            pageNibName = [pageNibName length] > 0 ? pageNibName : nil;
            id retObj = bundle ? ([[cls alloc] initWithNibName:pageNibName bundle:bundle]) : ([[cls alloc] init]);
            return retObj;
        }
        else {
            NSLog(@"%@", [NSString stringWithFormat:@"TCTURLRoute %@类不存在", pageClassName]);
        }
    }
    return nil;
}

- (TCTURLRouteHold *)routeHoldWithPageDictionary:(NSDictionary *)pageDictionary {
    NSDictionary *pageHoldDictionary = pageDictionary[kRouteConfigHold];
    if ([pageHoldDictionary isKindOfClass:[NSDictionary class]]) {
        TCTURLRouteHold *routeHold = TCTURLRouteHold.new;
        routeHold.holdController = pageHoldDictionary[kRouteConfigClass];    //类最后处理
        routeHold.wantLogin = [pageHoldDictionary[kRouteConfigWantLogin] boolValue];
        routeHold.wantLocation = [pageHoldDictionary[kRouteConfigWantLocation] boolValue];
        routeHold.passKeys = pageHoldDictionary[kRouteConfigPassKeys];
        routeHold.checkKeys = pageHoldDictionary[kRouteConfigCheckKeys];
        return routeHold;
    }
    return nil;
}

@end
