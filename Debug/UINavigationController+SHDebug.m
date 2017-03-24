//
//  UINavigationController+SHDebug.m
//  Debug_Demo
//
//  Created by ChuanRao on 2017/3/2.
//  Copyright © 2017年 ChuanRao. All rights reserved.
//

#import "SHDebugTableViewController.h"
#import "NSObject+Swizzle.h"

#define SH_Debug

@implementation UINavigationController (SHDebug)
+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL vdl = @selector(viewDidLoad);
        SEL new_vdl = @selector(shdebug_viewDidLoad);
        [self swizzleInstanceSelector:vdl withNewSelector:new_vdl];
    });
}

- (void)shdebug_viewDidLoad{
//    [self shdebug_viewDidLoad];

#ifdef SH_Debug
    // 添加长按手势出配置界面
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(shdebug_pushConfigView:)];
    gesture.minimumPressDuration = 0.8f;
    [self.view addGestureRecognizer:gesture];
#endif
}

- (void)shdebug_pushConfigView:(UILongPressGestureRecognizer *)recoginzer {
    if ([recoginzer state] == UIGestureRecognizerStateBegan) {
        SHDebugTableViewController *debugVC = [SHDebugTableViewController defaultManager];
        debugVC.currentVc = self.topViewController;
        [self pushViewController:debugVC animated:YES];
    }
}
@end
