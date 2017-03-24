//
//  NSDictionary+URLCode.h
//  TCTURLRoute
//
//  Created by maxfong on 16/8/23.
//  Copyright © 2016年 maxfong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (URLQuery)

/**
 *  根据URL.query查询参数的值
 *
 *  @param query URL.query
 *
 *  @return dictionary
 */
+ (instancetype)dictionaryWithURLQuery:(NSString *)query;

@end
