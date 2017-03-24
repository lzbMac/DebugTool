//
//  UIViewController+TCTURLRouteCallBack.m
//  TCTURLRoute
//
//  Created by maxfong on 16/1/22.
//  Copyright © 2016年 maxfong. All rights reserved.
//

#import "UIViewController+TCTURLRouteCallBack.h"
#import <objc/runtime.h>
#import "TCTURLRouteCallBackProtocol.h"

NSString *TCTURLRouteCallBackSourceClass = @"TCTURLRouteCallBackSourceClass";

@implementation UIViewController (TCTURLRouteCallBack)

- (UIViewController *)routeCallBackViewController {
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setRouteCallBackViewController:(UIViewController *)routeCallBackViewController {
    objc_setAssociatedObject(self, @selector(routeCallBackViewController), routeCallBackViewController, OBJC_ASSOCIATION_ASSIGN);
}

//B页面调用，将callback数据给前一个页面
- (void)routeCallBack:(NSDictionary *)callback {
    UIViewController *lastViewController = self.routeCallBackViewController;
    if ([lastViewController respondsToSelector:@selector(routeCallBackWithParam:)]) {
        [(UIViewController<TCTURLRouteCallBackProtocol> *)lastViewController routeCallBackWithParam:callback];
    }
}

@end
