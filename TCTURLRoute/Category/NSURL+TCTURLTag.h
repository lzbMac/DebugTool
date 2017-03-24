//
//  NSURL+TCTURLTag.h
//  TCTURLRoute
//
//  Created by maxfong on 15/7/27.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kURLFetchInternalTagCodeNotification;
extern NSString * const kURLFetchInternalWebCodeNotification;

extern NSString * const kURLTagNativeCode;
extern NSString * const kURLTagWebCode;

@interface NSURL (TCTURLTag)

/** 从internal中获取Tag值 */
- (NSString *)internalTagCode;

/** 过滤掉internal内的tag值，并修改scheme为http或者https */
- (NSURL *)filterInternalTagURL;

/** 过滤掉tctravel，修改为http */
- (NSURL *)filterTravelURL;

/** 获取链接中的tag值，优先取新的方式，从query里取 */
- (NSDictionary *)requestTags;

@end
