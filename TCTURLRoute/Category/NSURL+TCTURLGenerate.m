//
//  NSURL+TCTURLGenerate.m
//  TCTURLRoute
//
//  Created by maxfong on 15/8/14.
//  Copyright (c) 2015年 maxfong. All rights reserved.
//

#import "NSURL+TCTURLGenerate.h"
#import "TCTURLRouteConfig+RouteUserInfo.h"
#import "TCTCacheManager.h"
#import "TCTGlobalManager.h"
#import "NSString+CommonEncrypt.h"

NSString *const kServiceGlobalSignInUrl = @"serviceGlobalSignInUrl";

@implementation NSURL (TCTURLGenerate)

+ (NSString *)memberSignUrl {
    //格式http://172.16.8.132/deal/membersign.html?mid=123&pwd=fjlsdfljf&ts=4444444&sign=frewlj
    //mid:memberid;pwd,用户密码md5加密后全部字母小写，ts时间戳整数；
    //sign: string Md5Str = MD5Help.GetMD5(mid + pwd.ToLower() + ts + key, "utf-8");
    //key :        wl865@#$(!dd76dfg82
    
    /*
     1.原来正常的登录，添加一个stype=0
     stype = 0时，mid，pwd有效 md5:MD5Help.GetMD5(mid + stype + pwd.ToLower() + ts + key, "utf-8");
     url格式：http://172.16.8.132/deal/membersign.html?mid=xxx&stype=0&pwd=yyyyyy&ts=1234&sign=fdsfl
     2.
     第三方登录的自动登录后走这个逻辑
     stype：1 ：QQ 2 ：新浪微博 3 ：支付宝 是第三方的socialType
     stype != 0时，mid,stype, uid,有效 md5:MD5Help.GetMD5(mid + stype + uid + ts + key, "utf-8");
     url格式：http://172.16.8.132/deal/membersign.html?mid=xxx&stype=(1,2,3任意一种)&uid=xxxxxx&ts
     */
    
    if (![TCTURLRouteConfig route_isLogin]) {
        return nil;
    }
    
    NSString *userId=[[TCTCacheManager defaultManager] objectForKey:@"userId"];
    NSString *socialType=[[TCTCacheManager defaultManager] objectForKey:@"socialType"];
    NSString *memberid  =  [[TCTCacheManager defaultManager] objectForKey:@"externalMemberId"];
    
    //    NSString *pwd=[ProtocolEngine aesDecryptAndBase64Decode:TCTUserDefaultEntity.accountPassWord];
    //    NSString *pwdmd5       =[pwd MD5EncodedString];
    NSString *pwdmd5lower=@"";//[pwdmd5 lowercaseString];
    
    int ts=(int)[[NSDate date] timeIntervalSince1970];
    
    NSString *key=@"wl865@#$(!dd76dfg82";
    
    NSString *sign=nil;
    NSString *url=nil;
    
    NSInteger type=[socialType integerValue];
    if (type==0) {
        const char *s=[[[NSString stringWithFormat:@"%@%@%@%d%@",memberid,@(type),pwdmd5lower,ts,key] md5] UTF8String];
        sign=[NSString stringWithUTF8String:s];
        url=[NSString stringWithFormat:@"stype=0&mid=%@&pwd=%@&ts=%d&sign=%@",memberid,pwdmd5lower,ts,sign];
    }else{
        const char *s=[[[NSString stringWithFormat:@"%@%@%@%d%@",memberid,@(type),userId,ts,key] md5] UTF8String];
        sign=[NSString stringWithUTF8String:s];
        
        url=[NSString stringWithFormat:@"stype=%@&mid=%@&uid=%@&ts=%d&sign=%@",@(type),memberid,userId,ts,sign];
    }
    
    if (url.length==0) {
        return nil;
    }
    
//    NSString *baseUrl = AppDelegateEntity.getHomeIndex.writeList.signIn.url;
    NSString *baseUrl = [TCTGlobalManager objectForKey:kServiceGlobalSignInUrl];
    //如果接口没返用以下写死的连接
    if (baseUrl.length<=0) {
        baseUrl = @"http://app.ly.com/deal/membersign.html?wvc2=1&wvc3=1&";
    }
    NSString *returnUrl=[NSString stringWithFormat:@"%@%@",baseUrl,url];
    return returnUrl;
}

@end
