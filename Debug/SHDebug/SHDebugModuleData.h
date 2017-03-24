//
//  SHDebugModuleData.h
//  Debug_Demo
//
//  Created by ChuanRao on 2017/3/2.
//  Copyright © 2017年 ChuanRao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHDebugModuleProtocol.h"
@interface SHDebugModuleData : NSObject

+ (NSArray <SHDebugModuleProtocol> *) modules;
@end
