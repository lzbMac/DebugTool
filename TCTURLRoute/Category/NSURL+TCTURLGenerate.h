//
//  NSURL+TCTURLGenerate.h
//  TCTURLRoute
//
//  Created by maxfong on 15/8/14.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kServiceGlobalSignInUrl;

@interface NSURL (TCTURLGenerate)

/** 会员签到链接 */
+ (NSString *)memberSignUrl;

@end
