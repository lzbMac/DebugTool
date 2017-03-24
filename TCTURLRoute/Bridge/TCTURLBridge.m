//
//  TCTURLBridge.m
//  TCTURLRoute
//
//  Created by maxfong on 15/7/21.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//

#import "TCTURLBridge.h"
#import "GotoTargetPage_TCTURLBridge.h"
#import "NSString+URLCode.h"

@implementation TCTURLBridge

+ (NSURL *)routeURLFromString:(NSString *)aSting {
    return [GotoTargetPage_TCTURLBridge URLWithString:aSting];
}

+ (NSURL *)routeURLWithModule:(NSString *)module page:(NSString *)page parameter:(NSDictionary *)parameter {
    NSMutableString *paramString = [NSMutableString string];
    [parameter enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [paramString appendFormat:@"%@=%@&", key, obj];
    }];
    NSString *param = [paramString substringToIndex:(paramString.length-1)];    //去掉最后一位&
    NSString *URLString = [NSString stringWithFormat:@"%@://%@/%@?%@", @"tctclient", module, page, param];
    return [NSURL URLWithString:URLString];
}

//其实是废弃方法，暂时存放，获取string里有多个?的参数字段
+ (NSDictionary *)dictionaryWithString:(NSString *)aString {
    NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] init];
    NSArray *array = [aString componentsSeparatedByString:@"?"];
    if ([array count] >= 2) {
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (idx >= 1) {
                NSString *h5ParamUrl = [array objectAtIndex:idx];
                NSArray *paramsArr = [h5ParamUrl componentsSeparatedByString:@"&"];
                if ([paramsArr count] > 0) {
                    for (NSString *str in paramsArr) {
                        NSArray *keyValues = [str componentsSeparatedByString:@"="];
                        if ([keyValues count] == 2) {
                            NSString *key   = keyValues[0];
                            NSString *value = keyValues[1];
                            if ( key.length> 0 && value.length > 0) {
                                value = [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                                [paramsDict setValue:value forKey:key];
                            }
                        }
                    }
                }
            }
        }];
    }
    return paramsDict;
}

@end
