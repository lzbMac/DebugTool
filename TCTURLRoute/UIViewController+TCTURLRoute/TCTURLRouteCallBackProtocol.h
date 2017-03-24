//
//  TCTURLRouteCallBackProtocol.h
//  TCTURLRoute
//
//  Created by maxfong on 16/1/6.
//  Copyright © 2016年 maxfong. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TCTURLRouteCallBackProtocol <NSObject>

@optional

/**
 *  route回调数据，A->URLRoute[->Hold]->B，则A需要实现
 *
 *  @param callback B页面回传的数据
 */
- (void)routeCallBackWithParam:(NSDictionary *)callback;

@end
