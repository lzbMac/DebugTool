//
//  NSString+URLEncoded.h
//  TCTCategory
//
//  Created by maxfong on 15/5/7.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (TCTURLCode)

/** 字符串是否包含空格 */
- (BOOL)isWhitespace;
/** 字符串是否包含空格或长度要大于0 */
- (BOOL)isEmptyOrWhitespace;
/** 检查字符串是否包含给定字符串 */
- (BOOL)containString:(NSString *)string;
/** 检查字符串是否包含给定的字符串,同时允许定义比较形式 */
- (BOOL)containsString:(NSString*)string options:(NSStringCompareOptions)options;

#pragma mark -
/** 对URL的参数编码 */
- (NSString *)URLEncodedString;
/** 对URL的参数解码 */
- (NSString *)URLDecodedString;

@end
