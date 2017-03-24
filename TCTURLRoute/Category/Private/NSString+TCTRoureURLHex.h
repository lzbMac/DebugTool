//
//  NSString+TCTRoureURLHex.h
//  TCTURLRoute
//
//  Created by maxfong on 15/8/3.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (TCTRoureURLHex)

/** 十六进制转换为普通字符串的 */
+ (NSString *)stringFromHexString:(NSString *)hexString;

/** 普通字符串转换为十六进制的 */
+ (NSString *)hexStringFromString:(NSString *)string;

@end
