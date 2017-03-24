//
//  TCTURLRouteHold.h
//  TCTURLRoute
//
//  Created by maxfong on 15/7/22.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCTURLRouteResult.h"
#import "TCTURLRouteHoldProtocol.h"

typedef void (^TCTURLRouteHoldCompleteBlock)(TCTURLRouteResult *result, NSDictionary *options);

@interface TCTURLRouteHold : NSObject

@property (nonatomic, assign) BOOL wantLogin;
@property (nonatomic, assign) BOOL wantLocation;
@property (nonatomic, strong) NSArray *checkKeys;
@property (nonatomic, strong) NSArray *passKeys;
@property (nonatomic, strong) NSString *holdController;

- (void)dealHoldWithRouteResult:(TCTURLRouteResult *)routeResult completeBlock:(TCTURLRouteHoldCompleteBlock)completeBlock;

@end
