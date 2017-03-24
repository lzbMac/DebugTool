//
//  SHDebugModuleData.m
//  Debug_Demo
//
//  Created by ChuanRao on 2017/3/2.
//  Copyright © 2017年 ChuanRao. All rights reserved.
//

#import "SHDebugModuleData.h"

NSString* const SHDebugDefulatModuleDataPlistName = @"SHDebugConfigSupport";
NSString* const SHDebugPlistModules = @"module";

@interface SHDebugModuleData ()
@property (nonatomic, strong)NSDictionary* datas;
@property (nonatomic) NSMutableArray <SHDebugModuleProtocol> * theModules;
@end
@implementation SHDebugModuleData
+ (instancetype)defaultManager{
    static id instan;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instan = self.new;
    });
    return instan;
}
#pragma mark +
+ (NSArray<SHDebugModuleProtocol> *)modules{
    return [SHDebugModuleData defaultManager].theModules;
}
#pragma mark -
- (NSDictionary *)datas{
    return _datas?:({
        NSString* path = [[NSBundle mainBundle]pathForResource:SHDebugDefulatModuleDataPlistName ofType:@"plist"];
        _datas = [NSDictionary dictionaryWithContentsOfFile:path];
    });
}

- (NSMutableArray<SHDebugModuleProtocol> *)theModules{
    if (!_theModules) {
        NSMutableArray* arrayT = [NSMutableArray new];
        [self.datas[SHDebugPlistModules] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            Class cls = NSClassFromString(obj);
            if (cls) {
                [arrayT addObject:cls];
            }
        }];
        _theModules = [arrayT mutableCopy];
    }
    return _theModules;
}
@end
