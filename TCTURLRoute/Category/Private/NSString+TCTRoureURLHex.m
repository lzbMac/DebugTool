//
//  NSString+TCTRoureURLHex.m
//  TCTURLRoute
//
//  Created by maxfong on 15/8/3.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//

#import "NSString+TCTRoureURLHex.h"

@implementation NSString (TCTRoureURLHex)

/** 十六进制转换为普通字符串的 */
+ (NSString *)stringFromHexString:(NSString *)hexString {
    char *buffer = (char *)malloc((int)[hexString length] / 2 + 1);
    bzero(buffer, [hexString length] / 2 + 1);
    for (int i = 0; i < [hexString length] - 1; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [hexString substringWithRange:NSMakeRange(i, 2)];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        buffer[i / 2] = (char)anInt;
    }
    return [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
}

/** 普通字符串转换为十六进制的 */
+ (NSString *)hexStringFromString:(NSString *)string {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[data bytes];
    NSMutableString *hexStr = [NSMutableString string];
    for(int i = 0; i < [data length]; i++) {
        NSString *newHexStr = [NSString stringWithFormat:@"%x", bytes[i] & 0xff];
        if([newHexStr length] == 1) {
            newHexStr = [NSString stringWithFormat:@"0%@", newHexStr];
        }
        [hexStr appendString:newHexStr];
    }
    return hexStr;
}

@end
