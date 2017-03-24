//
//  NSString+RemoveUnderscoreAndInitials.m
//  TCTURLRoute
//
//  Created by maxfong on 15/11/10.
//  Copyright © 2015年 maxfong. All rights reserved.
//

#import "NSString+RemoveUnderscoreAndInitials.h"

@implementation NSString (RemoveUnderscoreAndInitials)

- (NSString *)removeUnderscoreAndInitials {
    NSString *aString = self;
    NSString *separateString = @"_";
    NSRange range = [aString rangeOfString:separateString];
    if (range.location != NSNotFound) {
        NSArray *subStrings = [aString componentsSeparatedByString:separateString];
        NSMutableArray *muteStrings = [NSMutableArray arrayWithArray:subStrings];
        [subStrings enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            //首字母有数字则次位大写
            if (idx > 0) [muteStrings replaceObjectAtIndex:idx withObject:[obj capitalizedString]];
        }];
        return [muteStrings componentsJoinedByString:@""];
    }
    return aString;
}

@end
