//
//  TCTURLRouteResult.h
//  TCTURLRoute
//
//  Created by maxfong on 15/7/21.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIViewController;

extern NSString * const kRouteResultLastViewController;
extern NSString * const kRouteResultUseableURL;
extern NSString * const kRouteResultOriginalURL;
extern NSString * const kRouteOriginalURLString;

typedef NS_ENUM(NSUInteger, TCTURLRouteOpenType) {
    URLRouteOpenUndefine,
    URLRouteOpenWeb,
    URLRouteOpenNative,
    URLRouteOpenExternal
};

@interface TCTURLRouteResult : NSObject

@property (nonatomic, assign, readonly) TCTURLRouteOpenType openType;

/** 将要打开的页面控制器 */
@property (nonatomic, strong) UIViewController *viewController;
/** 上一个页面控制器 */
@property (nonatomic, strong) UIViewController *lastViewController;
/** 代理给页面控制器的参数 */
@property (nonatomic, strong) NSDictionary *parameter;

/** 根据TCTRouteScheme.scheme初始化Result，生成openType */
- (instancetype)initWithScheme:(NSString *)scheme;

@end
