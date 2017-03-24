//
//  NSDictionary+URLCode.m
//  TCTURLRoute
//
//  Created by maxfong on 16/8/23.
//  Copyright © 2016年 maxfong. All rights reserved.
//

#import "NSDictionary+URLQuery.h"

@implementation NSDictionary (URLQuery)

+ (instancetype)dictionaryWithURLQuery:(NSString *)query {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (query.length && [query rangeOfString:@"="].location != NSNotFound) {
        NSArray *keyValuePairs = [query componentsSeparatedByString:@"&"];
        for (NSString *keyValuePair in keyValuePairs) {
            NSArray *pair = [keyValuePair componentsSeparatedByString:@"="];
            NSString *paramValue = pair.count == 2 ? pair.lastObject : @"";
            parameters[pair.firstObject] = ({
                NSString *input = [paramValue stringByReplacingOccurrencesOfString:@"+" withString:@" " options:NSLiteralSearch range:NSMakeRange(0, paramValue.length)];
                [input stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            }) ?: @"";
        }
    }
    return parameters;
}

@end
