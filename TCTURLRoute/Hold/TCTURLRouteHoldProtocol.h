//
//  TCTURLRouteHoldProtocol.h
//  TCTURLRoute
//
//  Created by maxfong on 15/7/21.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//

#import <Foundation/Foundation.h>

/** parameters的一些KEY */
extern NSString * const kRouteHoldLastViewController;   //堆栈的最后一个页面控制器
extern NSString * const kRouteHoldViewController;       //URL生成的ViewController
extern NSString * const kRouteHoldParameter;            //URL生成的属性参数

@protocol TCTURLRouteHoldProtocol <NSObject>

/**
 *  拦截URLRoute，自定义Hold
 *
 *  @param parameters 你所能得到的参数
 */
- (void)holdWithParameters:(NSDictionary *)parameters;

@end
