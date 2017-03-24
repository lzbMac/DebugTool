//
//  NSURL+TCTURLChar.h
//  TCTURLRoute
//
//  Created by maxfong on 15/7/25.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (TCTURLChar)

/** 是否包含 shouji.17u.cn/internal 链接 */
- (BOOL)isInternal;
/** scheme是否为tctclient */
- (BOOL)isRouteScheme;
/** 是否包含需要登录 */
- (BOOL)isNeedLogin;
/** 链接需要替换部分字符串 */
- (BOOL)isContainWebViewCharacter;
/** 需要打开新页面 */
- (BOOL)isContainWebViewCharacterOpenNew;
/** 包含浏览器打开 */
- (BOOL)isContainWebViewCharacterBrowserOpen;

#pragma mark -
/** 替换打开新页面tcwvcnew为noeffect */
- (NSURL *)replaceOpenNewCharacter;

/** 替换webview需要的数据 */
- (NSURL *)replaceWebViewCharacter;

@end
