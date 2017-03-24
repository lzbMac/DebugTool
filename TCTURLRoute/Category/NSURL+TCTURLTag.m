//
//  NSURL+TCTURLTag.m
//  TCTURLRoute
//
//  Created by maxfong on 15/7/27.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//

#import "NSURL+TCTURLTag.h"
#import "NSDictionary+URLQuery.h"

NSString * const kURLFetchInternalTagCodeNotification = @"kURLFetchInternalTagCodeNotification";
NSString * const kURLFetchInternalWebCodeNotification = @"kURLFetchInternalWebCodeNotification";

NSString * const kURLTagNativeCode = @"tcnatag";
NSString * const kURLTagWebCode = @"tcwebtag";

@implementation NSURL (TCTURLTag)

/** 从internal中获取Tag值 */
- (NSString *)internalTagCode {
    //tctravel://shouji.17u.cn/internal_123/hotel/details/111736
    NSString *path = self.path;  //path is: /internal_123/hotel/details/111736
    NSMutableArray *array = [[path componentsSeparatedByString:@"/"] mutableCopy];
    [array removeObjectAtIndex:0];  //remove null
    if (([array.firstObject hasPrefix:@"internal"] ||
        [self.scheme isEqualToString:@"tctravel"]) &&
        array.count > 1) { //判断1是为了区分URL版本，2.0的URL page包含_，会影响1.0Tag统计
        NSArray *arrayComp = [array.firstObject componentsSeparatedByString:@"_"];
        if (arrayComp.count >= 2) {
            return arrayComp.lastObject;
        }
    }
    return nil;
}

/** 过滤掉internal内的tag值，并修改scheme为http或者https */
- (NSURL *)filterInternalTagURL {
    NSString *urlString = self.absoluteString;
    NSMutableArray *array = [[urlString componentsSeparatedByString:@"/"] mutableCopy];
    if (array.count > 4) {
        NSArray *arrayCode = [[array objectAtIndex:3] componentsSeparatedByString:@"_"];
        if (arrayCode.count == 2) {
            [array replaceObjectAtIndex:3 withObject:arrayCode.firstObject];
        }
        NSRange range = {0, 2};
        [array removeObjectsInRange:range];
        
        NSString *scheme = @"http";
        if ([self.scheme isEqualToString:@"https"]) {
            scheme = self.scheme;
        }
        NSString *URLString = [NSString stringWithFormat:@"%@://%@", scheme, [array componentsJoinedByString:@"/"]];
        return [NSURL URLWithString:URLString];
    }
    return self;
}

- (NSURL *)filterTravelURL {
    NSString *urlString = self.absoluteString;
    if ([urlString hasPrefix:@"tctravel"]) {
        urlString = [urlString stringByReplacingOccurrencesOfString:@"tctravel" withString:@"http"];
    }
    return [NSURL URLWithString:urlString];
}

/** 获取链接中的tag值，优先取新的方式，从query里取 */
- (NSDictionary *)requestTags {
    NSDictionary *tagDict = [NSDictionary dictionaryWithURLQuery:self.query];
    NSString *naTag = tagDict[kURLTagNativeCode] ?: ([self internalTagCode] ?: @"");
    NSString *webTag = tagDict[kURLTagWebCode] ?: @"";
    return @{kURLTagNativeCode : naTag, kURLTagWebCode : webTag};
}

@end
