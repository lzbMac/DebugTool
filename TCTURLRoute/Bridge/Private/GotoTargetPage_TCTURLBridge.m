//
//  GotoTargetPage.m
//  TCTravel_IPhone
//
//  Created by lyf3852 on 13-3-29.
//
//

#import "GotoTargetPage_TCTURLBridge.h"
#import "NSURL+TCTURLChar.h"
#import "NSURL+TCTURLTag.h"
#import "NSString+URLCode.h"
#import "NSDictionary+URLQuery.h"
#import "TCTURLRouteConfig+RouteUserInfo.h"
#import "TCTGlobalManager.h"
#import "NSString+CommonEncrypt.h"

extern NSString * const URLRouteVersion;

@implementation GotoTargetPage_TCTURLBridge

+ (NSURL *)URLWithString:(NSString *)aString
{
    if (!aString.length) return nil;
    
    NSURL *oldURL = [NSURL URLWithString:aString];
    if (oldURL && ![oldURL isInternal]) {
#ifdef TC_Server_Debug
        NSLog(@"URLRoute检测通过");
        NSLog(@"URLRoute链接不需要转换");
#endif
        return oldURL;
    }
    
    if (!oldURL) {
        NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (CFStringRef)aString, CFSTR(""), kCFStringEncodingUTF8));
        NSString *nURLString = [result stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        oldURL = [NSURL URLWithString:nURLString];
        
        NSAssert(oldURL, ([NSString stringWithFormat:@"%@无法转换", aString]));
    }
#ifdef TC_Server_Debug
    NSLog(@"URLRoute检测为老规则");
    NSLog(@"URLRoute正在转换老规则");
#endif
    
    //通知Tag变更
    NSDictionary *dictTags = [oldURL requestTags];
    NSString *tagCode = dictTags[kURLTagNativeCode];
    NSString *webCode = dictTags[kURLTagWebCode];
    if (tagCode.length) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kURLFetchInternalTagCodeNotification object:tagCode];
    }
    if (webCode.length) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kURLFetchInternalWebCodeNotification object:webCode];
    }
    
    NSString *urlString = aString;
    
    NSMutableString *newURLString = [NSMutableString string];
    [newURLString appendString:@"tctclient://"];
    
    NSDictionary *paramsDict = [NSDictionary dictionaryWithURLQuery:oldURL.query];
    
    //获取规则链接
    NSString *strRule = urlString;
    NSArray *array1 = [urlString componentsSeparatedByString:@"?"];
    if ([array1 count] >= 2) {
        strRule = [array1 firstObject];
    }
    
    //根据链接规则区分项目
    NSArray *array = [strRule componentsSeparatedByString:@"/"];
    if (array.count < 6) return oldURL; //不符合1.0规则
    
    NSString *condition = @"";        //internal,announcement,external
    
    if (array.count >= 4) {
        condition = [array objectAtIndex:3];
    }
    
    //应用内部,internal;公告页,announcement;浏览器,external
    if (![condition hasPrefix:@"internal"]) return oldURL;
    
    NSString *item=@"";             //酒机景自助游等
    NSString *scene=@"";            //列表详情等具体场景
    item        =[array objectAtIndex:4];
    scene       =[array objectAtIndex:5];
    
    //>>>>>>>>>>maxfong 规则path
    [newURLString appendString:[NSString stringWithFormat:@"%@/%@", item, scene]];
    //<<<<<<<<<<maxfong
    
    //应用内部
    //判断酒景机自助游
    gotoPagexxProjectType projectType = gotoPagexxProjectNone;        //项目种类：1,酒店；2，景区；3，机票 4，登陆 5，自助游；6，混合
    if ([item isEqualToString:@"hotel"])
    {
        //酒店
        projectType = gotoPagexxProjectHotel;
    }
    else if ([item isEqualToString:@"hotelgroupby"])
    {
        //酒店团购
        projectType = gotoPagexxProjectHotelgroupby;
    }
    
    else if ([item isEqualToString:@"scenery"])
    {
        //景区
        projectType = gotoPagexxProjectScenery;
    }
    else if ([item isEqualToString:@"flight"])
    {
        //机票
        projectType = gotoPagexxProjectFlight;
    }
    else if ([item isEqualToString:@"login"])
    {
        //登陆
        projectType = gotoPagexxProjectLogin;
    }
    else if ([item isEqualToString:@"selftrip"])
    {
        //自助游
        projectType = gotoPagexxProjectSelftrip;
    }
    else if ([item isEqualToString:@"holiday"])
    {
        //度假
        projectType = gotoPagexxProjectHoliday;
    }
    else if ([item isEqualToString:@"sign"])
    {
        //签到
        projectType = gotoPagexxProjectSign;
    }
    else if ([item isEqualToString:@"nearby"])
    {
        //酒店，景点，周边游 ，需要本地定位经纬度
        projectType = gotoPagexxProjectNearby;
    }
    else if ([item isEqualToString:@"share"])
    {
        //分享
        projectType = gotoPagexxShare;
    }
    else if ([item isEqualToString:@"guide"])
    {
        //攻略
        projectType = gotoPagexxProjectGuide;
    }
    else if ([item isEqualToString:@"train"])
    {
        //火车
        projectType = gotoPagexxTrain;
    }
    else if ([item isEqualToString:@"cruise"])
    {
        //游轮
        projectType = gotoPagexxShip;
    }
    else if ([item isEqualToString:@"common"])
    {
        //公共
        projectType = gotoPagexxCommon;
    }
    else if ([item isEqualToString:@"tchome"])
    {
        //tchome/tchome
        projectType = gotoPagexxHome;
    }
    else if ([item isEqualToString:@"yongche"])
    {
        //yongche
        projectType = gotoPagexxYongche;
    }
    else if ([item isEqualToString:@"taxi"]){
        projectType = gotoPagexxTaxi;
    }
    
    else if ([item isEqualToString:@"wallet"]){
        projectType = gotoPagexxWallet;
    }
    else if ([item isEqualToString:@"interflight"]) {
        projectType = gotoPagexxProjectInternalFlight;
    }
    else if ([item isEqualToString:@"movie"]) {
        projectType = gotoPagexxProjectMovie;
    }
    else if ([item isEqualToString:@"scream"]) {
        projectType = gotoPagexxProjectScream;
    }
    else if ([item isEqualToString:@"search"]) {
        projectType = gotoPagexxSearchAll;
    }
    else if ([item isEqualToString:@"ugc"]) {
        projectType = gotoPagexxUGC;
    }
    
    else if ([item isEqualToString:@"bus"]) {
        projectType = gotoPagexxProjectBus;
    }
    else if ([item isEqualToString:@"mine"]) {
        projectType = gotoPagexxMine;
    }
    else if ([item isEqualToString:@"travelnotes"]) {
        projectType = gotoPagexxLightTravel;
    }
    else if ([item isEqualToString:@"discovery"]) {
        projectType = gotoPagexxProjectDiscovery;
    }
    else if ([item isEqualToString:@"inland"])
    {
        projectType = gotoPagexxProjectInland;
    }
    else if ([item isEqualToString:@"strategy"])
    {
        projectType = gotoPagexxStrategy;
    }
    
    //判断具体内容
    gotoPagexxContentType contentType = gotoPagexxContentNone;
    
    // 周边游 所有分类
    if ([scene isEqualToString:@"alltypes"]) {
        /* 周边游首页全部标题 */
        contentType = gotoPagexxContentAllTypes;
    }
    else if ([scene isEqualToString:@"groupdetails"]){
        /* 周边游跟团详情页 */
        contentType = gotoPagexxContentGroupdetails;
    }
    else if ([scene isEqualToString:@"details"])
    {
        //酒店景点自助游度假详情
        contentType = gotoPagexxContentDetail;
    }
    else if ([scene isEqualToString:@"detail"])
    {
        //火车详情
        contentType = gotoPagexxContentCommonDetail;
    }
    else if ([scene isEqualToString:@"list"])
    {
        //酒机票自助游度假列表
        contentType = gotoPagexxContentList;
    }
    else if ([scene isEqualToString:@"nearby"])
    {
        //酒店经纬度列表
        contentType = gotoPagexxContentHotelNearby;
    }
    else if ([scene isEqualToString:@"orderdetails"])
    {
        //订单详情,酒景机自助游度假
        contentType = gotoPagexxContentOrderDetails;
    }
    else if ([scene isEqualToString:@"comment"])
    {
        //点评，酒景机
        contentType = gotoPagexxContentComment;
    }
    else if ([scene isEqualToString:@"home"])
    {
        //酒机景自助游度假首页
        contentType = gotoPagexxContentHome;
    }
    
    else if ([scene isEqualToString:@"hotel"])
    {
        //酒店
        contentType = gotoPagexxContentHotel;
    }
    else if ([scene isEqualToString:@"scenery"])
    {
        //景区
        contentType = gotoPagexxContentSceney;
    }
    else if ([scene isEqualToString:@"selftrip"])
    {
        //自助游
        contentType = gotoPagexxContentSelftrip;
    }
    else if ([scene isEqualToString:@"all"])
    {
        //调用分享页面
        contentType = gotoPagexxShareAll;
    }
    else if ([scene isEqualToString:@"weixin"])
    {
        //微信朋友圈
        contentType = gotoPagexxShareWeChatQuan;
    }
    else if ([scene isEqualToString:@"book"])
    {
        //预订
        contentType = gotoPagexxContentBook;
    }
    else if ([scene isEqualToString:@"citydetails"])
    {
        //guide/citydetails
        contentType = gotoPagexxContentGuideCitydetails;
    }
    else if ([scene isEqualToString:@"scenerydetails"])
    {
        //guide/citydetails
        contentType = gotoPagexxContengGuideScenerydetails;
    }
    else if ([scene isEqualToString:@"pay"])
    {
        //common/pay
        contentType = gotoPagexxCommonPay;
    }
    else if ([scene isEqualToString:@"close"])
    {
        //common/close
        contentType = gotoPagexxCommonClose;
    }
    
    else if ([scene isEqualToString:@"pushflight"])
    {
        contentType=gotoPagexxCommonPushflight;
    }
    else if ([scene isEqualToString:@"order"]){
        contentType=gotoPagexxContentOrder;
    }
    else if([scene isEqualToString:@"scenerylist"])
    {
        contentType=gotoPagexxContentScenerylist;
    }
    else if ([scene isEqualToString:@"feedback"]){
        contentType=gotoPagexxCommonFeedback;
    }
    else if ([scene isEqualToString:@"pics"]){
        contentType=gotoPagexxCommonPics;
    }
    else if ([scene isEqualToString:@"ticketfolders"]){
        contentType=gotoPagexxContentTicketfolders;
    }
    else if ([scene isEqualToString:@"memberinfo"]){
        contentType=gotoPagexxContentCommonMemberinfo;
    }
    else if ([scene isEqualToString:@"zuche"]) {
        contentType=gotoPagexxContentYongcheZuche;
    }
    else if ([scene isEqualToString:@"gradationpayment"]){
        contentType = gotoPagexxContentGradationPayment;//国际机票分次支付
    }
    else if ([scene isEqualToString:@"payment"]){
        contentType = gotoPagexxContentPayment;
    }
    else if ([scene isEqualToString:@"fillorder"]) {
        contentType = gotoPagexxContentFillOrder;
    }
    else if ([scene isEqualToString:@"smallroomfillorder"])
    {
        contentType = gotoPagexxContentSmallRoomFillOrder;
    }
    else if ([scene isEqualToString:@"search"]) {
        contentType = gotoPagexxContentSearch;
    }
    else if ([scene isEqualToString:@"codedetail"]) {
        contentType = gotoPagexxContentCodeDetail;
    }
    else if ([scene isEqualToString:@"elist"]) {
        contentType = gotoPagexxContentSceneyElist;
    }
    else if ([scene isEqualToString:@"dynamic"]) { //航班动态详情页
        contentType = gotoPagexxContentFlightDynamic;
    }
    else if ([scene isEqualToString:@"dynamichome"]) { //航班动态首页
        contentType = gotoPagexxContentFlightDynamicAttentionList;
    }
    
    else if ([scene isEqualToString:@"pricetrend"]) { //价格趋势首页
        contentType = gotoPagexxContentFlightPriceTendHome;
    }
    else if ([scene isEqualToString:@"bible"]) { //乘机宝典首页
        contentType = gotoPagexxContentFlightAirPortHome;
    }
    else if ([scene isEqualToString:@"orderlist"]) {
        contentType = gotoPagexxContentOrderlist;
    }
    else if ([scene isEqualToString:@"cardorderdetails"]){
        contentType = gotoPagexxContentCardOrderDetail;
    }
    
    else if ([scene isEqualToString:@"robtickets"]) {
        contentType = gotoPagexxContentrobtickets;
    }
    
    else if ([scene isEqualToString:@"litescenery"]){
        contentType = gotoPagexxContentLitescenery;
    }
    
    else if ([scene isEqualToString:@"bus"]){
        contentType = gotoPagexxContentBus;
    }
    else if ([scene isEqualToString:@"dest"]) {
        contentType = gotoPagexxContentDest;
    }
    
    else if ([scene isEqualToString:@"sche"]) {
        contentType = gotoPagexxContentSche;
    }
    
    else if ([scene isEqualToString:@"singlehome"]) {
        contentType = gotoPagexxContentSingeHome;
    }
    else if ([scene isEqualToString:@"purchwriteorder"]){
        contentType = gotoPagexxContentSpecialOfferWriteOrder;
    }
    else if ([scene isEqualToString:@"wealth"]) {
        contentType = gotoPagexxContentWealth;
    }
    else if ([scene isEqualToString:@"orders"]) {
        contentType = gotoPagexxContentMineOrders;
    }
    else if ([scene isEqualToString:@"cards"]) {
        contentType = gotoPagexxContentMineCards;
    }
    else if ([scene isEqualToString:@"messagebox"]) {
        contentType = gotoPagexxContentMineMessagebox;
    }
    else if ([scene isEqualToString:@"hotlist"]) {
        contentType = gotoPagexxContentHotRanking;
    }
    else if ([scene isEqualToString:@"payplatform"]) {
        contentType = gotoPagexxContentPayplatform;
    }
    else if ([scene isEqualToString:@"assistant"]) {
        contentType = gotoPagexxContentAssistant;
    }
    else if ([scene isEqualToString:@"writecomment"]) {
        contentType = gotoPagexxContentWritecomment;
    }
    else if ([scene isEqualToString:@"commentlist"]) {
        contentType = gotoPagexxContentCommentlist;
    }
    else if ([scene isEqualToString:@"uploadpicture"]) {
        contentType = gotoPagexxLightTravelUploadPic;
    }
    else if ([scene isEqualToString:@"collection"]) {
        contentType = gotoPagexxContentMyStar;
    }
    else if ([scene isEqualToString:@"destselect"]) {
        contentType = gotoPagexxContentDestination;
    }
    else if ([scene isEqualToString:@"pricecalendar"]) {
        contentType = gotoPagexxContentCalendar;
    }
    else if ([scene isEqualToString:@"routeurfavor"]) {
        contentType = gotoPagexxContentFavor;
    }
    else if ([scene isEqualToString:@"strategypoidetail"]) {
        contentType = gotoPagexxPoiDetail;
    }
    else if ([scene isEqualToString:@"bindmobile"]) {
        contentType = gotoPagexxContentCommonBindMobile;
    }
    else if ([scene isEqualToString:@"commentcenter"]) {
        contentType = gotoPagexxContentCommonDpHomePage;
    }
    
    //不符合的规则，直接返回
    if (projectType == gotoPagexxProjectNone && contentType == gotoPagexxContentNone) {
        return oldURL;
    }
    
    //>>>>>>>>>>maxfong
    //在URLRoute2.0设置_login即可
    //<<<<<<<<<<maxfong
    NSString *memberID_Public = [TCTURLRouteConfig route_memberID];
    NSString *memberID_H5 = [TCTURLRouteConfig route_externalMemberID];
    
    //>>>>>>>>>>maxfong
    //噩梦的开始，开始拼接query
    NSMutableDictionary *newQuery = [NSMutableDictionary dictionary];
    //<<<<<<<<<<maxfong
    switch (projectType)
    {
        case gotoPagexxProjectHotel:
        {
            //酒店
            switch (contentType)
            {
                case gotoPagexxContentDetail:
                {
                    //详情
                    if (array.count > 6)
                    {
                        NSString *hotelID = array[6];
                        //>>>>>>>>>>maxfong
                        [newQuery setValue:hotelID forKey:@"hotelId"];
                        //<<<<<<<<<<maxfong
                        //跳转到酒店详情
                    }
                }
                    break;
                case gotoPagexxContentOrderDetails:
                {
                    //订单详情
                    if (array.count > 7)
                    {
                        NSString *orderserialID = array[7];
                        //>>>>>>>>>>maxfong
                        [newQuery setValue:orderserialID forKey:@"orderserialID"];
                        //<<<<<<<<<<maxfong
                    }
                }
                    break;
                case gotoPagexxContentComment:
                {
                    //点评
                    if (array.count > 7)
                    {
                        NSString *orderserialID = array[7];
                        //>>>>>>>>>>maxfong
                        [newQuery setValue:orderserialID forKey:@"orderserialID"];
                        //<<<<<<<<<<maxfong
                    }
                }
                    break;
                case gotoPagexxContentHome:
                {
                    // http://shouji.17u.cn/internal/hotel/home/?backType=close(不做强制返回)|其他原逻辑
                    //酒店首页
                    BOOL bShouBackToIndex = YES;
                    if ([paramsDict[@"backType"] length] > 0
                        && [paramsDict[@"backType"] isEqualToString:@"close"]) {
                        bShouBackToIndex = NO;
                    }
                    //>>>>>>>>>>maxfong
                    [newQuery setValue:@(bShouBackToIndex) forKey:@"bShouBackToIndex"];
                    //<<<<<<<<<<maxfong
                }
                    break;
                case gotoPagexxContentList:
                {
                    //酒店列表
                    if (array.count > 6)
                    {
                        NSString *parameter=array[6];
                        NSArray *arrayParameter=[parameter componentsSeparatedByString:@"_"];
                        if (arrayParameter.count==6) {
                            NSString *tagName = arrayParameter[5];
                            if (tagName.length > 0) {
                                tagName = [tagName URLDecodedString];
                            }
                            //>>>>>>>>>>maxfong
                            [newQuery setValue:tagName forKey:@"tagName"];
                            [newQuery setValue:arrayParameter[0] forKey:@"ctype"];
                            [newQuery setValue:arrayParameter[1] forKey:@"cId"];
                            [newQuery setValue:arrayParameter[2] forKey:@"smallcid"];
                            [newQuery setValue:arrayParameter[3] forKey:@"tagtype"];
                            [newQuery setValue:arrayParameter[4] forKey:@"tagid"];
                            //<<<<<<<<<<maxfong
                        }
                    }
                    
                }
                    break;
                case gotoPagexxContentHotelNearby:
                {
                    //酒店经纬度列表
                    if (array.count > 6)
                    {
                        NSString *parameter=array[6];
                        NSArray *arrayParameter=[parameter componentsSeparatedByString:@"_"];
                        if (arrayParameter.count==7) {
                            
                            //>>>>>>>>>>maxfong
                            [newQuery setValue:arrayParameter[0] forKey:@"ctype"];
                            [newQuery setValue:arrayParameter[1] forKey:@"cId"];
                            [newQuery setValue:arrayParameter[2] forKey:@"lon"];
                            [newQuery setValue:arrayParameter[3] forKey:@"lat"];
                            [newQuery setValue:arrayParameter[4] forKey:@"tagtype"];
                            [newQuery setValue:arrayParameter[5] forKey:@"tagid"];
                            [newQuery setValue:[arrayParameter[6] URLDecodedString] forKey:@"tagname"];
                            //<<<<<<<<<<maxfong
                        }
                    }
                    
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case gotoPagexxProjectHotelgroupby:
        {
            switch (contentType) {
                case gotoPagexxContentList:
                {
                    if (array.count>7) {
                        //>>>>>>>>>>maxfong
                        [newQuery setValue:array[6] forKey:@"cityID"];
                        [newQuery setValue:[array[7] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"cityName"];
                        //<<<<<<<<<<maxfong
                    }else{
                    }
                }
                    break;
                case gotoPagexxContentDetail:
                {
                    if (array.count>6) {
                        //>>>>>>>>>>maxfong
                        [newQuery setValue:array[6] forKey:@"groupId"];
                        //<<<<<<<<<<maxfong
                    }
                }
                    break;
                case gotoPagexxContentPayment:
                {
                    //http://shouji.17u.cn/internal/hotelgroupby/payment/[orderSerialId]
                    if (array.count>6) {
                        //>>>>>>>>>>maxfong
                        [newQuery setValue:array[6] forKey:@"orderSerialId"];
                        //<<<<<<<<<<maxfong
                    }
                }
                    break;
                    
                case gotoPagexxContentOrderDetails:
                {
                    //http://shouji.17u.cn/internal/hotelgroupby/orderdetails/[sign memberid]/[orderserialid]
                    if (array.count>7) {
                        NSString *tempMemberID=memberID_Public;
                        NSString *orderserialid=array[7];
                        //>>>>>>>>>>maxfong
                        [newQuery setValue:tempMemberID forKey:@"memberId"];
                        [newQuery setValue:orderserialid forKey:@"orderserialId"];
                        //<<<<<<<<<<maxfong
                        
                    }
                }
                    break;
                    
                    
                default:
                    break;
            }
        }
            break;
        case gotoPagexxProjectScenery:
        {
            //景点
            switch (contentType)
            {
                case gotoPagexxContentList:
                {
                    if ([array count] > 7) {
                        NSString *cityId = array[7];
                        NSString *keyWord = array[6];
                        NSString *isKeyWord = [paramsDict objectForKey:@"iskeywordvalid"];
                        
                        //>>>>>>>>>>maxfong
                        [newQuery setValue:cityId forKey:@"cityId"];
                        [newQuery setValue:keyWord forKey:@"keyWord"];
                        [newQuery setValue:isKeyWord forKey:@"isKeyWord"];
                        //<<<<<<<<<<maxfong
                        
                    }
                    else if([array count] > 6)
                    {
                        NSString *keyWord = array[6];
                        //>>>>>>>>>>maxfong
                        [newQuery setValue:keyWord forKey:@"keyWord"];
                        //<<<<<<<<<<maxfong
                    }
                }
                    break;
                case gotoPagexxContentDetail:
                {
                    //详情
                    if (array.count > 6)
                    {
                        NSString *sceneryId = array[6];
                        NSString *priceId = [paramsDict objectForKey:@"priceId"];
                        
                        //>>>>>>>>>>maxfong
                        [newQuery setValue:sceneryId forKey:@"sceneryId"];
                        [newQuery setValue:priceId forKey:@"priceId"];
                        //<<<<<<<<<<maxfong
                        
                    }
                }
                    break;
                case gotoPagexxContentOrderDetails:
                {
                    //订单详情
                    if (array.count > 7)
                    {
                        NSString *orderserialID = array[7];
                        
                        //>>>>>>>>>>maxfong
                        [newQuery setValue:orderserialID forKey:@"orderserialID"];
                        [newQuery setValue:memberID_Public forKey:@"memberID"];
                        [newQuery setValue:[paramsDict objectForKey:@"backView"] forKey:@"backView"];
                        //<<<<<<<<<<maxfong
                        
                    }
                }
                    break;
                case gotoPagexxContentComment:
                {
                    // 景区点评需要登录
                    //点评
                    if (array.count > 7)
                    {
                        NSString *orderserialID = array[7];
                        
                        //>>>>>>>>>>maxfong
                        [newQuery setValue:orderserialID forKey:@"orderserialID"];
                        //<<<<<<<<<<maxfong
                        
                    }
                }
                    break;
                case gotoPagexxContentHome:
                {
                    //景点首页
                }
                    break;
                case gotoPagexxContentBook:
                {
                    //景点预订
                    NSString *sSceneryID = @"";
                    NSString *sPirceID   = @"";
                    NSString *sDate      = @"";
                    if (array.count > 7)
                    {
                        sSceneryID = array[6];
                        sPirceID   = array[7];
                        sDate = (array.count > 8) ? array[8] : @"";
                        
                        //>>>>>>>>>>maxfong
                        [newQuery setValue:sSceneryID forKey:@"sceneryID"];
                        [newQuery setValue:sPirceID forKey:@"pirceID"];
                        [newQuery setValue:sDate forKey:@"date"];
                        //<<<<<<<<<<maxfong
                        
                    }
                }
                    break;
                    
                    
                case gotoPagexxContentOrder:{
                    if (array.count>6) {
                        NSString *string=array[6];
                        
                        //>>>>>>>>>>maxfong
                        [newQuery setValue:array[6] forKey:@"typeString"];
                        //<<<<<<<<<<maxfong
                        
                        //一元票
                        if ([string isEqualToString:@"yiyuan"]) {
                            //>>>>>>>>>>maxfong
                            [newQuery setValue:memberID_Public forKey:@"memberId"];
                            //<<<<<<<<<<maxfong
                        }
                        else if ([string isEqualToString:@"pay"]) {
                            if (array.count>8) {
                                NSString *orderid=array[7];
                                NSString *orderSerialId=array[8];
                                
                                //>>>>>>>>>>maxfong
                                [newQuery setValue:orderid forKey:@"orderid"];
                                [newQuery setValue:orderSerialId forKey:@"orderSerialId"];
                                //<<<<<<<<<<maxfong
                            }else{

                            }
                        }
                        else if ([string isEqualToString:@"refund"]) {
                            if (array.count>8) {
                                NSString *orderid=array[7];
                                NSString *orderSerialId=array[8];
                                
                                //>>>>>>>>>>maxfong
                                [newQuery setValue:orderid forKey:@"orderid"];
                                [newQuery setValue:orderSerialId forKey:@"orderSerialId"];
                                //<<<<<<<<<<maxfong
                                
                            }else{

                            }
                        }
                    }else{

                    }
                }
                    break;
                    //票夹
                case gotoPagexxContentTicketfolders:
                {
                    if (array.count>7) {
                        NSString *name=array[6];
                        
                        //>>>>>>>>>>maxfong
                        [newQuery setValue:name forKey:@"name"];
                        //<<<<<<<<<<maxfong
                        
                        if ([name isEqualToString:@"cards"]) {
                            NSString *strIDS=array[7];
                            
                            //>>>>>>>>>>maxfong
                            [newQuery setValue:strIDS forKey:@"strIDS"];
                            //<<<<<<<<<<maxfong
                            
                        }else if ([name isEqualToString:@"myactivation"]){
                            
                            //>>>>>>>>>>maxfong
                            [newQuery setValue:memberID_Public forKey:@"memberId"];
                            //<<<<<<<<<<maxfong
                        }else{

                        }
                    }else{

                    }
                }
                    break;
                    
                    //带参数进入景区列表
                case gotoPagexxContentSceneyElist:
                {
                    if (array.count>7) {
                        
                        //>>>>>>>>>>maxfong
                        [newQuery setValue:array[6] forKey:@"searchType"];
                        [newQuery setValue:array[7] forKey:@"searchValue"];
                        //<<<<<<<<<<maxfong
                        
                    }
                }
                    break;
                    
                    
                case gotoPagexxContentHotRanking:
                {
                    //>>>>>>>>>>maxfong
                    
                    //<<<<<<<<<<maxfong
                    
                    
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case gotoPagexxProjectFlight:
        {
            //机票
            switch (contentType)
            {
                case gotoPagexxContentList:
                {
                    NSString *originCityCode = nil;                                //出发城市三字码
                    NSString *arrvieCityCode = nil;                                //到达城市三字码
                    NSString *date = nil;
                    NSString *toDate=nil;
                    
                    if ([array count] >= 8) {
                        originCityCode = array[6];
                        arrvieCityCode = array[7];
                        
                        if ([array count] > 8) {
                            date = array[8];
                        }
                    }
                    
                    if (array.count > 9) {
                        toDate = array[9];
                    }
                    
                    //>>>>>>>>>>maxfong
                    [newQuery setValue:originCityCode forKey:@"fromCityCode"];
                    [newQuery setValue:arrvieCityCode forKey:@"toCityCode"];
                    //<<<<<<<<<<maxfong
                    
                    if (toDate.length==0) {
                        //跳转到机场列表
                        NSString *goTripAcCode=paramsDict[@"acCode"];
                        
                        //>>>>>>>>>>maxfong
                        [newQuery setValue:date forKey:@"goTripDate"];
                        [newQuery setValue:goTripAcCode forKey:@"goTripAcCode"];
                        //<<<<<<<<<<maxfong
                        
                        
                    }else{
                        //往返 机场列表
                        NSString *goTripAcCode=paramsDict[@"acCode"];
                        NSString *backTripAcCode=paramsDict[@"backAcCode"];
                        
                        //>>>>>>>>>>maxfong
                        [newQuery setValue:goTripAcCode forKey:@"goTripAcCode"];
                        [newQuery setValue:backTripAcCode forKey:@"backTripAcCode"];
                        [newQuery setValue:date forKey:@"dateCome"];
                        [newQuery setValue:toDate forKey:@"dateTo"];
                        //<<<<<<<<<<maxfong
                        
                    }
                }
                    break;
                case gotoPagexxContentOrderDetails:
                {
                    //订单详情
                    if (array.count > 7)
                    {
                        NSString *orderserialID = array[7];
                        //跳转到机票订单详情
                        
                        //>>>>>>>>>>maxfong
                        [newQuery setValue:orderserialID forKey:@"orderId"];
                        //<<<<<<<<<<maxfong
                        
                    }
                }
                    break;
                case gotoPagexxContentComment:
                {
                    
                    //点评
                    if (array.count > 7)
                    {
                        NSString *orderserialID = array[7];
                        
                        //>>>>>>>>>>maxfong
                        [newQuery setValue:orderserialID forKey:@"orderserialID"];
                        //<<<<<<<<<<maxfong
                        
                    }
                }
                    break;
                case gotoPagexxContentHome:
                {
                    //机票首页
                    NSString *citys;
                    if (array.count > 6) {
                        citys= array[6];
                    }
                    
                    NSString *fromCityCode;
                    NSString *toCityCode;
                    NSArray *cityArr = [citys componentsSeparatedByString:@"_"];
                    
                    fromCityCode = cityArr[0];
                    toCityCode = cityArr[1];
                    if (fromCityCode.length == 0) {
                        fromCityCode = nil;
                    }
                    
                    if (toCityCode.length == 0) {
                        toCityCode = nil;
                    }
                    
                    //>>>>>>>>>>maxfong
                    [newQuery setValue:fromCityCode forKey:@"fromCityCode"];
                    [newQuery setValue:toCityCode forKey:@"toCityCode"];
                    //<<<<<<<<<<maxfong
                    
                }
                    break;
                case gotoPagexxContentFlightDynamic:
                {
                    NSString *routinfo=nil;
                    NSString *flightNo=nil;
                    NSString *flightDate=nil;
                    if ([array count] > 8) {
                        flightDate=[array lastObject];
                    }
                    routinfo=array[6];
                    flightNo=array[7];
                    if (routinfo.length>0 && flightNo.length>0)
                    {
                        
                        //>>>>>>>>>>maxfong
                        [newQuery setValue:flightNo forKey:@"flightNo"];
                        [newQuery setValue:flightDate forKey:@"flightDate"];
                        [newQuery setValue:routinfo forKey:@"routinfo"];
                        //<<<<<<<<<<maxfong
                        
                    }
                    
                }
                    break;
                case gotoPagexxContentFlightDynamicAttentionList:
                {
                }
                    break;
                    
                case gotoPagexxContentFlightPriceTendHome:
                {
                }
                    break;
                    
                case gotoPagexxContentFlightAirPortHome:
                {
                }
                    break;
                case gotoPagexxContentPayment:
                {
                    
                    //                        http://shouji.17u.cn/internal/flight/payment/orderid/orderserialid?isNeedOrderView=1//是否需要订单信息View
                    //                        array:"http:",
                    //                        "",
                    //                        "shouji.17u.cn",
                    //                        internal,
                    //                        flight,
                    //                        payment,
                    //                        521002,
                    //                        5512
                    //#warning wcq 国内机票跳转收银台 （非会员需要手机号没有memberId，怎么搞 ？）
                    NSString *orderId = nil;
                    NSString *orderSerialId = nil;
                    NSString *memberId = memberID_Public;
                    if (array.count > 7) {
                        orderId = array[6];
                        orderSerialId = array[7];
                    }
                    
                    //>>>>>>>>>>maxfong
                    [newQuery setValue:orderId forKey:@"orderId"];
                    [newQuery setValue:orderSerialId forKey:@"orderSerialId"];
                    [newQuery setValue:memberId forKey:@"memberID"];
                    
                    //<<<<<<<<<<maxfong
                    
                }
                    break;
                case gotoPagexxContentPayplatform: {
                    
                    //>>>>>>>>>>maxfong
                    
                    //<<<<<<<<<<maxfong
                    
                    break;
                }
                default:
                    break;
            }
        }
            break;
            
        case gotoPagexxProjectInternalFlight:
        {
            switch (contentType) {
                case gotoPagexxContentList:
                {
                    NSString *srcCity=nil;
                    NSString *destCity=nil;
                    NSString *queryDate=nil;
                    NSString *toDate=nil;
                    if (array.count>6) {
                        srcCity=array[6];
                    }
                    if (array.count>7) {
                        destCity=array[7];
                    }
                    if (array.count>8) {
                        queryDate=array[8];
                    }
                    if (array.count>9) {
                        toDate=array[9];
                    }
                    
                    //>>>>>>>>>>maxfong
                    [newQuery setValue:srcCity forKey:@"srcCity"];
                    [newQuery setValue:destCity forKey:@"destCity"];
                    [newQuery setValue:queryDate forKey:@"queryDate"];
                    [newQuery setValue:toDate forKey:@"toDate"];
                    
                    //<<<<<<<<<<maxfong
                    
                    
                }
                    break;
                    
                case gotoPagexxContentHome:
                {
                    if (array.count>6) {
                        NSString *city=array[6];
                        NSArray *arrayCity=[city componentsSeparatedByString:@"_"];
                        
                        NSString *srcCity=nil;
                        NSString *destCity=nil;
                        if (arrayCity.count>1) {
                            srcCity=arrayCity[0];
                            destCity=arrayCity[1];
                        }else{
                            srcCity=[arrayCity firstObject];
                        }
                        
                        //>>>>>>>>>>maxfong
                        [newQuery setValue:srcCity forKey:@"fromCityCode"];
                        [newQuery setValue:destCity forKey:@"toCityCode"];
                        //<<<<<<<<<<maxfong
                        
                        
                    }else{
                    }
                }
                    break;
                    
                case gotoPagexxContentOrderDetails:
                {
                    //http://shouji.17u.cn/internal/interflight/orderdetails/[sign memberid]/[orderId]
                    if (array.count>7) {
                        NSString *orderId=array[7];
                        
                        //>>>>>>>>>>maxfong
                        [newQuery setValue:orderId forKey:@"orderId"];
                        //<<<<<<<<<<maxfong
                        
                    }
                }
                    break;
                case gotoPagexxContentPayment://国际机票支付
                {
                    //http://shouji.17u.cn/internal/interflight/payment/orderid/orderserialid?isNeedOrderView=1//是否需要订单信息View
                    //                        array:"http:",
                    //                        "",
                    //                        "shouji.17u.cn",
                    //                        internal,
                    //                        interflight,
                    //                        payment,
                    //                        521002,
                    //                        5512
                    
                    NSString *orderId = nil;
                    NSString *orderSerialId = nil;
                    NSString *memberId = memberID_Public;
                    if (array.count > 7) {
                        orderId = array[6];
                        orderSerialId = array[7];
                    }
                    
                    //>>>>>>>>>>maxfong
                    [newQuery setValue:orderId forKey:@"orderId"];
                    [newQuery setValue:orderSerialId forKey:@"orderSerialId"];
                    [newQuery setValue:memberId forKey:@"memberID"];
                    
                    [newQuery setValue:@(YES) forKey:@"bInterPay"];
                    //<<<<<<<<<<maxfong
                    
                }
                    break;
                case gotoPagexxContentGradationPayment://国际机票分分次支付
                {
                    //#warning wcq 国际机票分分次支 待完成
                    //                        http://shouji.17u.cn/internal/interflight/gradationpayment/orderid/orderserialid/batchPayId/batchPrice/islastPay
                    //                        orderid	订单id	1
                    //                        orderserialid	订单流水号	1
                    //                        batchPayId	分次支付id	1
                    //                        batchPrice	分次支付金额
                    //                        islastPay	是否分次支付最后一笔   是传1，否则传0	1
                    NSString *orderId = nil;
                    NSString *orderSerialId = nil;
                    NSString *batchPayId = nil;
                    NSString *batchPrice = nil;
                    NSString *memberId = memberID_Public;
                    if (array.count > 10) {
                        orderId = array[6];
                        orderSerialId = array[7];
                        batchPayId = array[8];
                        batchPrice = array[9];
                    }
                    
                    //>>>>>>>>>>maxfong
                    [newQuery setValue:orderId forKey:@"orderId"];
                    [newQuery setValue:orderSerialId forKey:@"orderSerialId"];
                    [newQuery setValue:memberId forKey:@"memberID"];
                    [newQuery setValue:batchPayId forKey:@"batchPayId"];
                    [newQuery setValue:batchPrice forKey:@"batchPrice"];
                    
                    [newQuery setValue:@YES forKey:@"bInterPay"];
                    //<<<<<<<<<<maxfong
                    
                }
                    break;
                default:
                    break;
            }
        }
            break;
            
            
        case gotoPagexxProjectLogin:
        {
            [newURLString appendString:@"main"];
        }
            break;
            //自助游
        case gotoPagexxProjectSelftrip:
        {
            switch (contentType)
            {
                    
                case gotoPagexxContentHotRanking :{
                    //http://shouji.17u.cn/internal/sefltrip/hotlist?cityId={0}&cityName={1}
                    NSString *cityID = [paramsDict objectForKey:@"cityId"];
                    NSString *cityName = [paramsDict objectForKey:@"cityName"];
                    
                    //>>>>>>>>>>maxfong
                    [newQuery setValue:cityID forKey:@"cityID"];
                    [newQuery setValue:cityName forKey:@"cityName"];
                    //<<<<<<<<<<maxfong
                    
                }
                    break;
                    
                case gotoPagexxContentGroupdetails:{
                    
                }break;
                    // 全部分类
                case gotoPagexxContentAllTypes:
                {
//                    NSString *homeCityID = [paramsDict objectForKey:@"homeCityId"];
//                    NSString *moduleId = [paramsDict objectForKey:@"moduleId"];
//                    NSString *cityId = [paramsDict objectForKey:@"cityId"];
//                    NSString *localCityId = [paramsDict objectForKey:@"localCityId"];
//                    NSString *homeCityName = [paramsDict objectForKey:@"homeCityName"];
//                    NSString *isThemeCity = [paramsDict objectForKey:@"isThemeCity"];
//                    
                    
                    
                    
                }
                    break;
                    
                    //详情
                case gotoPagexxContentDetail:
                {
                    NSString *strLineId = nil;
                    NSString *strBookingDate = nil;
                    if (array.count > 6)
                    {
                        strLineId = array[6];
                        if (array.count > 7)
                        {
                            strBookingDate = array[7];
                        }
                    }
                    
                    //http://shouji.17u.cn/internal/selftrip/details/线路id/?sourceId=1
                    NSString *sourceId=[paramsDict objectForKey:@"sourceId"];
                    
                    //>>>>>>>>>>maxfong
                    [newQuery setValue:strLineId forKey:@"lineId"];
                    [newQuery setValue:strBookingDate forKey:@"bookingDate"];
                    [newQuery setValue:sourceId forKey:@"sourceId"];
                    //<<<<<<<<<<maxfong
                    
                }
                    break;
                    //列表
                case gotoPagexxContentList:
                {
                    NSString *strKeyword = nil;
                    NSString *cityId=nil;
                    if (array.count > 6)
                    {
                        strKeyword = array[6];
                        strKeyword=[strKeyword stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    }
                    if (array.count>7) {
                        cityId=array[7];
                    }
                    
                    NSString *tabProjects=[paramsDict objectForKey:@"tabProjects"];
                    //http://shouji.17u.cn/internal/selftrip/list/?tabProjects=3
                    
                    //>>>>>>>>>>maxfong
                    [newQuery setValue:strKeyword forKey:@"keyword"];
                    [newQuery setValue:cityId forKey:@"cityId"];
                    [newQuery setValue:tabProjects forKey:@"tabProjects"];
                    
                    //<<<<<<<<<<maxfong
                    
                    
                }
                    break;
                    //订单详情
                case gotoPagexxContentOrderDetails:
                {
                    NSString *strOrderId = nil;
                    if (array.count > 7)
                    {
                        strOrderId = array[7];
                    }
                    
                    //>>>>>>>>>>maxfong
                    [newQuery setValue:strOrderId forKey:@"orderId"];
                    //<<<<<<<<<<maxfong
                }
                    break;
                    //首页
                case gotoPagexxContentHome:
                {
                }
                    break;
                default:
                    break;
            }
        }
            break;
            //度假
        case gotoPagexxProjectHoliday:
        {
            switch (contentType)
            {
                case gotoPagexxContentDetail:
                    //度假详情
                {
                    //                        http://shouji.17u.cn/internal/holiday/details/线路id/活动id/期数id?tabNo=1
                    
                    NSString *strLineId = nil;
                    NSString *periodId=nil;
                    NSString *periodNo=nil;
                    if (array.count > 6)
                    {
                        strLineId = array[6];
                    }
                    
                    if (array.count>8){
                        periodId=array[7];
                        periodNo=array[8];
                    }
                    
                    NSString *tabNo = paramsDict[@"tabNo"];
                    
                    //>>>>>>>>>>maxfong
                    [newQuery setValue:strLineId forKey:@"lineId"];
                    [newQuery setValue:periodNo forKey:@"periodNo"];
                    [newQuery setValue:periodId forKey:@"periodId"];
                    [newQuery setValue:tabNo forKey:@"tabNo"];
                    //<<<<<<<<<<maxfong
                    
                }
                    break;
                    
                case gotoPagexxContentList:
                    //度假列表
                    //http://shouji.17u.cn/internal/holiday/list?lineType=1&destination=泰国&departCityId=226&lineThemeId=14&lineTheme=经典观光&isGenuine=1&isNotDestination=1&searchType=keyword
                    
                {
                    NSString *strKeyword = nil;
                    if (array.count > 6)
                    {
                        strKeyword = array[6];
                        strKeyword=[strKeyword stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    }
                    
                    //>>>>>>>>>>maxfong
                    [newQuery setValue:strKeyword forKey:@"keyword"];
                    
                    //<<<<<<<<<<maxfong
                    
                }
                    break;
                    //度假订单详情
                case gotoPagexxContentOrderDetails:
                {
                    NSString *strOrderId=nil;
                    NSString *strOrderSerialId=nil;
                    if (array.count > 7)
                    {
                        strOrderId = array[7];
                    }
                    if (array.count > 8)
                    {
                        strOrderSerialId = array[8];
                    }
                    
                    //>>>>>>>>>>maxfong
                    [newQuery setValue:strOrderId forKey:@"orderId"];
                    [newQuery setValue:strOrderSerialId forKey:@"orderSerialId"];
                    [newQuery setValue:@YES forKey:@"bFromGotoTargetPage"];
                    //<<<<<<<<<<maxfong
                    
                }
                    break;
                    //度假首页
                case gotoPagexxContentHome:
                {
                }
                    break;
                    //目的地选择页
                case gotoPagexxContentDestination:
                {
                    //目的地选择：http://shouji.17u.cn/internal/holiday/destselect?lineType=1&departCityId=【出发地Id】&departCity=【出发地】&regionName=欧洲
//                    NSString *lineType = paramsDict[@"lineType"];
//                    NSString *regionName = paramsDict[@"regionName"];
//                    NSString *departCityId = paramsDict[@"departCityId"];
//                    NSString *departCity = paramsDict[@"departCity"];
                    
                    break;
                }
                    //价格日历页
                case gotoPagexxContentCalendar:
                {
                    //                        http://shouji.17u.cn/internal/holiday/pricecalendar?lineId=[lineId]/activityId=[activityId]/periodId=[periodId]
//                    NSString *lineId = paramsDict[@"lineId"];
//                    NSString *activityId = paramsDict[@"activityId"];
//                    NSString *periodId = paramsDict[@"periodId"];
                    
                    
                    break;
                    
                }
                default:
                    break;
            }
        }
            break;
        case gotoPagexxProjectSign:
        {
            //签到
            [newURLString appendString:@"main"];
        }
            break;
            //酒店，景点，周边游 ，需要本地定位经纬度
        case gotoPagexxProjectNearby:
        {
            NSString *latitude  = [TCTURLRouteConfig route_latitude];
            NSString *longitude = [TCTURLRouteConfig route_longitude];
            
            switch (contentType)
            {
                case gotoPagexxContentHotel:
                {
                    
                    //>>>>>>>>>>maxfong
                    [newQuery setValue:longitude forKey:@"longitude"];
                    [newQuery setValue:latitude forKey:@"latitude"];
                    [newQuery setValue:@"11" forKey:@"ctype"];
                    //<<<<<<<<<<maxfong
                    //酒店周边
                }
                    break;
                case gotoPagexxContentSceney:
                {
                    //>>>>>>>>>>maxfong
                    //需要自定义Hold
                    [newQuery setValue:longitude forKey:@"longitude"];
                    [newQuery setValue:latitude forKey:@"latitude"];
                    [newQuery setValue:@"0" forKey:@"hiddenTopItem"];
                    //<<<<<<<<<<maxfong
                    
                    
                }
                    break;
                case gotoPagexxContentSelftrip:
                {
                    
                    //>>>>>>>>>>maxfong
                    
                    //<<<<<<<<<<maxfong
                }
                    break;
                case gotoPagexxContentLitescenery:
                {
                    //>>>>>>>>>>maxfong
                    [newQuery setValue:longitude forKey:@"longitude"];
                    [newQuery setValue:latitude forKey:@"latitude"];
                    [newQuery setValue:@"1" forKey:@"hiddenTopItem"];
                    //<<<<<<<<<<maxfong
                    
                    
                }
                    break;
                    
                default:
                    break;
            }
            break;
        }
            break;
        case gotoPagexxShare:
        {
            switch (contentType)
            {
                case gotoPagexxShareAll:
                {
                }
                    break;
                case gotoPagexxShareWeChatQuan:
                {
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case gotoPagexxProjectGuide:
        {
            switch (contentType) {
                case gotoPagexxContentHome:
                {
                    //guide/home
                }
                    break;
                    break;
                case gotoPagexxContentGuideCitydetails:
                {
                    //guide/citydetails
                    if (array.count>8)
                    {
                        NSString *itemKind   = array[6];
                        NSString *itemID = array[7];
                        NSString *itemName = [array[8] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                        
                        //>>>>>>>>>>maxfong
                        [newQuery setValue:itemID forKey:@"itemID"];
                        [newQuery setValue:itemKind forKey:@"itemKind"];
                        [newQuery setValue:itemName forKey:@"itemName"];
                        //<<<<<<<<<<maxfong
                        
                    }
                    
                }
                    break;
                case gotoPagexxContengGuideScenerydetails:
                {
                    //guide/scenerydetails
                    if (array.count>8) {
                        NSString *itemKind   = array[6];
                        NSString *itemID = array[7];
                        NSString *itemName = [array[8] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                        
                        //>>>>>>>>>>maxfong
                        [newQuery setValue:itemID forKey:@"itemID"];
                        [newQuery setValue:itemKind forKey:@"itemKind"];
                        [newQuery setValue:itemName forKey:@"itemName"];
                        //<<<<<<<<<<maxfong
                        
                    }
                }
                    break;
                    
                case gotoPagexxContentScenerylist:
                {
                    if (array.count>8) {
                        NSString *itemKind=array[6];
                        NSString *itemId=array[7];
                        NSString *itemName=array[8];
                        
                        //>>>>>>>>>>maxfong
                        [newQuery setValue:itemId forKey:@"itemID"];
                        [newQuery setValue:itemKind forKey:@"itemKind"];
                        [newQuery setValue:[itemName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"itemName"];
                        //<<<<<<<<<<maxfong
                        
                    }else{
                    }
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case gotoPagexxTrain:
        {
            switch (contentType) {
                case gotoPagexxContentHome:
                {
                    if (array.count > 6) {
                        NSString* city = array[6];
                        NSString* srcCity = nil;
                        NSString* destCity = nil;
                        
                        NSArray* arrayCity = [city componentsSeparatedByString:@"_"];
                        if (arrayCity.count > 1) {
                            srcCity = [arrayCity[0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                            destCity = [arrayCity[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                        }
                        else {
                            srcCity = [arrayCity firstObject];
                        }
                        
                        //>>>>>>>>>>maxfong
                        [newQuery setValue:srcCity forKey:@"srcCity"];
                        [newQuery setValue:destCity forKey:@"destCity"];
                        //<<<<<<<<<<maxfong
                        
                    }
                    else {
                        
                    }
                    
                }
                    break;
                case gotoPagexxContentCommonDetail: {
                    
                    //>>>>>>>>>>maxfong
                    
                    //<<<<<<<<<<maxfong
                    
                } break;
                case gotoPagexxContentOrderDetails:
                {
                    if (array.count > 7) {
                        NSString *orderID=array[7];
                        
                        BOOL bIsBack = YES;
                        if ([paramsDict[@"backType"] isEqualToString:@"allOrders"]) {
                            bIsBack = NO;
                        }
                        
                        //>>>>>>>>>>maxfong
                        [newQuery setValue:orderID forKey:@"orderID"];
                        [newQuery setValue:@(bIsBack) forKey:@"bIsBack"];
                        //<<<<<<<<<<maxfong
                        
                    }
                    
                }
                    break;
                case gotoPagexxContentList:
                {
                    NSString* srcCity = nil;
                    NSString* destCity = nil;
                    NSString* queryDate = nil;
                    if (array.count > 6) {
                        srcCity = [array[6] URLDecodedString];
                    }
                    if (array.count > 7) {
                        destCity = [array[7] URLDecodedString];
                    }
                    if (array.count > 8) {
                        queryDate = [array[8] URLDecodedString];
                    }
                    
                    //>>>>>>>>>>maxfong
                    [newQuery setValue:srcCity forKey:@"srcCity"];
                    [newQuery setValue:destCity forKey:@"destCity"];
                    [newQuery setValue:queryDate forKey:@"queryDate"];
                    //<<<<<<<<<<maxfong
                    
                    
                }
                    break;
                    
                case gotoPagexxContentOrderlist:
                {
                    //订单列表
                    
                    //>>>>>>>>>>maxfong
                    [newQuery setValue:@YES forKey:@"isBack"];
                    //<<<<<<<<<<maxfong
                    
                }
                    break;
                case gotoPagexxContentrobtickets:
                {
                    //抢票
                    
                }
                    break;
                    
                    
                default:
                    break;
            }
        }
            break;
            
            // 邮轮
        case gotoPagexxShip:
        {
            switch (contentType) {
                case gotoPagexxContentHome:
                {
                }
                    break;
                case gotoPagexxContentList:
                {
                    //                        列表：http://shouji.17u.cn/internal/cruise/list/[srcCityId]/[dest]/[标题]（需要转码）
                    if (array.count>8) {
                        NSString *srcCityId = array[6];
                        NSString *dest      = array[7];
                        NSString *title     = array[8];
                        title=[title stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                        
                        //>>>>>>>>>>maxfong
                        [newQuery setValue:srcCityId forKey:@"srcCityId"];
                        [newQuery setValue:dest forKey:@"dest"];
                        [newQuery setValue:title forKey:@"title"];
                        //<<<<<<<<<<maxfong
                        
                    }
                }
                    break;
                case gotoPagexxContentDetail:
                {
                    //http://shouji.17u.cn/internal/cruise/details/[线路id]
                    if (array.count>6) {
                        NSString *lineID=array[6];
                        
                        //>>>>>>>>>>maxfong
                        [newQuery setValue:lineID forKey:@"lineID"];
                        //<<<<<<<<<<maxfong
                        
                    }
                }
                    break;
                case gotoPagexxContentOrderDetails:
                {
                    //订单：http://shouji.17u.cn/internal/cruise/orderdetails/[memberId]/[orderid]/[orderserialID]?isBackTravelAssistant =1
                    if (array.count>8) {
                        NSString *orderid       = array[7];
                        NSString *orderserialID = array[8];
                        
                        //>>>>>>>>>>maxfong
                        [newQuery setValue:orderid forKey:@"orderid"];
                        [newQuery setValue:orderserialID forKey:@"orderserialID"];
                        
                        //<<<<<<<<<<maxfong
                        
                    }
                }
                    break;
                case gotoPagexxContentFillOrder:
                {
                    //下单跳转:http://shouji.17u.cn/internal/cruise/fillorder/[JsonString]
                    //JsonString定义格式请参考附件“邮轮进入下单页所需参数.txt”
                    if (array.count == 7) {
                        
                        NSString *jsonString = [[array objectAtIndex:6] URLDecodedString];
                        NSDictionary *dictInfo = nil;
                        if (jsonString.length>0) {
                            dictInfo = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
                        }
                        
                        //>>>>>>>>>>maxfong
                        if (dictInfo) {
                            [newQuery addEntriesFromDictionary:dictInfo];
                        }
                        [newQuery setValue:@"ShipHybridToOrderWrite" forKey:@"entityName"];
                        //<<<<<<<<<<maxfong
                        
                    }
                }
                    break;
                case gotoPagexxContentSmallRoomFillOrder:
                {
                    //大小房型下单跳转:http://shouji.17u.cn/internal/cruise/smallroomfillorder/[JsonString]
                    //JsonString定义格式请参考附件“邮轮进入下单页所需参数.txt”
                    if (array.count == 7) {
                        NSString *jsonString = [[array objectAtIndex:6] URLDecodedString];
                        NSDictionary *dictInfo = nil;
                        if (jsonString.length>0) {
                            dictInfo = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
                        }
                        
                        //>>>>>>>>>>maxfong
                        if (dictInfo) {
                            [newQuery addEntriesFromDictionary:dictInfo];
                        }
                        [newQuery setValue:@"ShipHybridToOrderWrite" forKey:@"entityName"];
                        //<<<<<<<<<<maxfong
                        
                        
                    }
                }
                    break;
                case gotoPagexxContentSearch:
                {
                    //邮轮搜索页链接：http://shouji.17u.cn/internal/cruise/search
                }
                    break;
                    //邮轮特卖订单填写页 ：http://shouji.17u.cn/internal/cruise/purchwriteorder/lineld/batchId/roomId
                case gotoPagexxContentSpecialOfferWriteOrder:
                {
                    if (array.count == 9)
                    {
                        //>>>>>>>>>>maxfong
                        [newQuery setValue:array[6] forKey:@"lineId"];
                        [newQuery setValue:array[7] forKey:@"batchId"];
                        [newQuery setValue:array[8] forKey:@"roomId"];
                        //<<<<<<<<<<maxfong
                        
                    }
                }
                    break;
                    //邮轮卡订单详情
                case gotoPagexxContentCardOrderDetail:
                {
                    //邮轮卡订单详情链接：http://shouji.17u.cn/internal/cruise/cardorderdetails/[orderid]
                    NSString *_orderId=nil;
                    if (array.count > 6)
                    {
                        _orderId = [array objectAtIndex:6];
                    }
                    
                    //>>>>>>>>>>maxfong
                    [newQuery setValue:_orderId forKey:@"orderId"];
                    //<<<<<<<<<<maxfong
                    
                }
                    break;
                case gotoPagexxContentPayment:
                {
                    //邮轮特卖支付方式详情链接：http://shouji.17u.cn/internal/cruise/payment/[JsonString]
                    NSString *jsonString = [[array objectAtIndex:6] URLDecodedString];
                    NSDictionary *dictInfo= nil;
                    if (jsonString.length>0) {
                        dictInfo = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
                    }
                    
                    //>>>>>>>>>>maxfong
                    if (dictInfo) {
                        [newQuery addEntriesFromDictionary:dictInfo];
                    }
                    //<<<<<<<<<<maxfong
                    
                }
                    break;
                case gotoPagexxContentComment:
                {
                    //邮轮点评列表链接：http://shouji.17u.cn/internal/cruise/comment/[lineid]
                    if (array.count >= 7)
                    {
                        NSString *lineId = array[6];
                        
                        //>>>>>>>>>>maxfong
                        [newQuery setValue:lineId forKey:@"lineId"];
                        //<<<<<<<<<<maxfong
                        
                    }
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case gotoPagexxCommon:
        {
            switch (contentType) {
                case gotoPagexxCommonPay:
                {
                    NSString *payway = nil;
                    NSString *projectId = nil;
                    NSString *orderSerialId = nil;
                    if (array.count>8) {
                        payway = array[6];
                        projectId = array[7];
                        orderSerialId = array[8];
                    }
                    else if (array.count >7) {
                        payway = array[6];
                        projectId = array[7];
                    }
                    else if (array.count > 6) {
                        payway = array[6];
                    }
                    
                    [newQuery setValue:payway forKey:@"payway"];
                    [newQuery setValue:projectId forKey:@"projectId"];
                    [newQuery setValue:orderSerialId forKey:@"orderSerialId"];
                }
                    break;
                case gotoPagexxCommonClose:
                {
                }
                    break;
                    
                case gotoPagexxCommonPushflight:
                {
                    if (array.count>6) {
                        //http://shouji.17u.cn/internal_v901v635539105944720352v/common/pushflight/2_3811196_FB54894D2A21002UB556_86b7070a5a6f4f3ec736f3bb98b92b65_111731451
                        //WSPLProjectId“_”WSPLId_"订单流水号"_memberId_orderId
                        NSString *para=array[6];
                        NSArray *tempParaArray=[para componentsSeparatedByString:@"_"];
                        if (tempParaArray.count>=5) {
                            NSString *projectId     = tempParaArray[0];
                            NSString *memberId      = memberID_H5;
                            NSString *orderSerialId = tempParaArray[2];
                            NSString *orderId       = tempParaArray[4];
                            
                            //>>>>>>>>>>maxfong
                            [newQuery setValue:memberId forKey:@"memberID"];
                            [newQuery setValue:projectId forKey:@"projectId"];
                            [newQuery setValue:orderId forKey:@"orderId"];
                            [newQuery setValue:orderSerialId forKey:@"orderSerialId"];
                            //<<<<<<<<<<maxfong
                            
                            
                        }else{
                        }
                    }else{
                    }
                }
                    break;
                    
                case gotoPagexxCommonFeedback:
                {
                }
                    break;
                    
                case gotoPagexxCommonPics:{
                    if (array.count>6) {
                        NSString *para=array[6];
                        para=[para stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                        NSData *data=[para dataUsingEncoding:NSUTF8StringEncoding];
                        NSDictionary *dicJson=nil;
                        if (data) {
                            dicJson=[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                        }
                        if (dicJson) {
                            //>>>>>>>>>>maxfong
                            [newQuery addEntriesFromDictionary:dicJson];
                            //<<<<<<<<<<maxfong
                        }
                    }
                    
                }
                    break;
                    
                case gotoPagexxContentCommonMemberinfo:
                {
                }
                    break;
                case gotoPagexxContentPayplatform: {
                    NSString *orderId = paramsDict[@"orderId"];
                    NSString *orderSerialId = paramsDict[@"orderSerialId"];
                    NSString *projectTag = paramsDict[@"projectTag"];
                    NSString *strOrderInfo = paramsDict[@"orderInfo"];
                    NSDictionary *orderInfoDict = nil;
                    if ([strOrderInfo isKindOfClass:[NSString class]]
                        && [strOrderInfo length] > 0)
                    {
                        id tempOrderInfo = [self deserializeObjectWithString:[strOrderInfo URLDecodedString]];
                        if ([tempOrderInfo isKindOfClass:[NSDictionary class]]) {
                            orderInfoDict = (NSDictionary *)tempOrderInfo;
                        }
                    }
                    id tempPayInfo = paramsDict[@"payInfo"];
                    NSString *payInfo = [tempPayInfo isKindOfClass:[NSString class]] ? (NSString *)tempPayInfo : nil;
                    
                    NSString *backType = paramsDict[@"backType"];
                    
                    //>>>>>>>>>>maxfong
                    [newQuery setValue:orderId forKey:@"orderId"];
                    [newQuery setValue:orderSerialId forKey:@"orderSerialId"];
                    [newQuery setValue:projectTag forKey:@"projectTag"];
                    [newQuery setValue:payInfo forKey:@"payInfo"];
                    [newQuery setValue:backType forKey:@"backType"];
                    if (orderInfoDict) {
                        [newQuery addEntriesFromDictionary:orderInfoDict];
                    }
                    //<<<<<<<<<<maxfong
                    
                }
                    break;
                case gotoPagexxContentWritecomment: {
                    if ([paramsDict[@"orderInfo"] length] > 0) {
                        NSDictionary *infoDict = [self deserializeObjectWithString:[paramsDict[@"orderInfo"] URLDecodedString]];
                        
                        //>>>>>>>>>>maxfong
                        if (infoDict) {
                            [newQuery addEntriesFromDictionary:infoDict];
                        }
                        [newQuery setValue:@"TCTCommonCommentsObj" forKey:@"objectName"];
                        //<<<<<<<<<<maxfong
                        
                        
                    }
                    break;
                }
                case gotoPagexxContentCommentlist: {
                    if ([paramsDict[@"resourceInfo"] length] > 0) {
                        NSDictionary *infoDict = [self deserializeObjectWithString:[paramsDict[@"resourceInfo"] URLDecodedString]];
                        
                        //>>>>>>>>>>maxfong
                        if (infoDict) {
                            [newQuery addEntriesFromDictionary:infoDict];
                        }
                        [newQuery setValue:@"TCTCommonCommentsObj" forKey:@"objectName"];
                        //<<<<<<<<<<maxfong
                        
                    }
                    break;
                }
                    //出境收藏页面
                case gotoPagexxContentMyStar:
                {
                    
                }
                    break;
                case gotoPagexxContentCommonBindMobile: {
                    break;
                }
                case gotoPagexxContentCommonDpHomePage:
                {
                    NSDictionary *dict = [self deserializeObjectWithString:[paramsDict[@"dpInfo"] URLDecodedString]];
                    [newQuery addEntriesFromDictionary:dict];
                    break;
                }
                default:
                    break;
            }
        }
            break;
            
        case gotoPagexxHome:
        {
            if (array.count>5) {
                NSString *home=array[5];
                
                //>>>>>>>>>>maxfong
                [newQuery setValue:home forKey:@"home"];
                
                //<<<<<<<<<<maxfong
                
            }
        }
            break;
        case gotoPagexxMine: {
            
            //>>>>>>>>>>maxfong
            
            //<<<<<<<<<<maxfong
            
            switch (contentType) {
                case gotoPagexxContentHome: {
                    
                    //>>>>>>>>>>maxfong
                    [newQuery addEntriesFromDictionary:@{@"tab":@"mine"}];
                    //<<<<<<<<<<maxfong
                    
                    break;
                }
                case gotoPagexxContentWealth: {
                    
                    break;
                }
                case gotoPagexxContentMineOrders: {
                    
                    break;
                }
                case gotoPagexxContentMineCards: {
                    
                    break;
                }
                case gotoPagexxContentMineMessagebox: {
                    break;
                }
                case gotoPagexxContentAssistant: {
                    NSString *strBackType = paramsDict[@"backType"];
                    
                    //>>>>>>>>>>maxfong
                    [newQuery setValue:strBackType forKey:@"strBackType"];
                    //<<<<<<<<<<maxfong
                    
                    break;
                }
                case gotoPagexxContentFavor:
                {
                    NSString *type = [paramsDict objectForKey:@"type"];
                    //>>>>>>>>>>maxfong
                    [newQuery setValue:type forKey:@"type"];
                    //<<<<<<<<<<maxfong
                    
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case gotoPagexxYongche:
        {
            switch (contentType) {
                case gotoPagexxContentYongcheZuche:
                {
                }
                    break;
                case gotoPagexxContentBus:
                {
                }
                    break;
                    
                    
                case gotoPagexxContentOrderDetails:
                {
                    //                        http://shouji.17u.cn/internal/yongche/orderdetails/[sign memberid]/[orderId]?subOrderType=chuzu
                    
                    if (array.count>7) {
                        NSString *orderId=array[7];
                        
                        //>>>>>>>>>>maxfong
                        [newQuery setValue:orderId forKey:@"orderId"];
                        
                        //<<<<<<<<<<maxfong
                        
                        
                    }
                }
                    break;
                    
                case gotoPagexxContentSingeHome:
                {
                }
                    break;
                case gotoPagexxContentNone:
                {
                    [newURLString appendString:@"singlehome"];
                }
                    
                default:
                {
                }
                    break;
            }
        }
            break;
            
        case gotoPagexxTaxi:
        {
            switch (contentType) {
                case gotoPagexxContentHome:
                {
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case gotoPagexxWallet:
        {
            switch (contentType) {
                case gotoPagexxContentHome:
                {
                }
                    break;
                case gotoPagexxContentCodeDetail:
                {
                    //激活码详情 codedetail   http://shouji.17u.cn/internal/wallet/codedetail/[sign memberid]/[activeCode]
                    if (array.count>6) {
                        NSString *memberid = memberID_Public;
                        NSString *activeCode=array[7];
                        
                        //>>>>>>>>>>maxfong
                        [newQuery setValue:memberid forKey:@"memberId"];
                        [newQuery setValue:activeCode forKey:@"activeCode"];
                        //<<<<<<<<<<maxfong
                        
                    }
                    
                    
                }
                    break;
                case gotoPagexxContentDetail:
                {
                    //http://shouji.17u.cn/internal/wallet/details/[sceneryid]/[priceid]/[友商ID]
                    if (array.count>7) {
                        NSString *sceneryid = array[6];
                        NSString *priceid = array[7];
                        NSString *friendId = [array count] > 8 ? array[8] : @"0";
                        
                        //>>>>>>>>>>maxfong
                        [newQuery setValue:sceneryid forKey:@"sceneryId"];
                        [newQuery setValue:priceid forKey:@"priceId"];
                        [newQuery setValue:friendId forKey:@"friendId"];
                        //<<<<<<<<<<maxfong
                        
                    }
                    
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case gotoPagexxProjectMovie:
        {
            switch (contentType) {
                case gotoPagexxContentHome:
                {
                    NSString *cityName = paramsDict[@"cityName"];
                    if ([cityName length] > 0) {
                        cityName = [cityName URLDecodedString];
                    }
                    //>>>>>>>>>>maxfong
                    [newQuery setValue:cityName forKey:@"cityName"];
                    //<<<<<<<<<<maxfong
                    
                }
                    break;
                    
                case gotoPagexxContentDetail:
                {
                    //http://shouji.17u.cn/internal/movie/details/[movieid]/[转码的 moviedetails]
                    if (array.count>6) {
                        NSString *movieID=array[6];
                        NSString *moviedetails= (array.count>7)?[array[7] URLDecodedString]:@"电影详情";
                        NSString *backType = @"0";
                        if ([paramsDict[@"backType"] length] > 0
                            && [paramsDict[@"backType"] isEqualToString:@"close"]) {
                            backType = @"1";
                        }
                        NSString *cityName = paramsDict[@"cityName"];
                        if ([cityName length] > 0) {
                            cityName = [cityName URLDecodedString];
                        }
                        
                        //>>>>>>>>>>maxfong
                        [newQuery setValue:movieID forKey:@"movieID"];
                        [newQuery setValue:moviedetails forKey:@"moviedetails"];
                        [newQuery setValue:backType forKey:@"backType"];
                        [newQuery setValue:cityName forKey:@"cityName"];
                        //<<<<<<<<<<maxfong
                        
                    }
                }
                    break;
                    
                case gotoPagexxContentOrderDetails:
                {
                    //http://shouji.17u.cn/internal/movie/orderdetails/[sign memberid]/[orderId]
                    
                    NSString *orderId=nil;
                    
                    if(array.count>7){
                        orderId=array[7];
                    }
                    
                    //>>>>>>>>>>maxfong
                    [newQuery setValue:orderId forKey:@"orderId"];
                    //<<<<<<<<<<maxfong
                    
                }
                    break;
                case gotoPagexxContentSche:
                {
                    //http://shouji.17u.cn/internal/movie/sche/[影院id][影院名称]/[返回逻辑，关闭|返回上一级]
                    NSString *cinemaID=nil;
                    NSString *cinemaName=nil;
                    NSString *switchValue=nil;
                    
                    if (array.count>6) {
                        cinemaID = array[6];
                    }
                    
                    if (array.count>7) {
                        cinemaName = [array[7] URLDecodedString];
                    }
                    
                    if (array.count>8) {
                        switchValue=array[8];
                    }
                    
                    NSString *movieId = @"0";
                    if ([paramsDict[@"movieId"] length] > 0) {
                        movieId = paramsDict[@"movieId"];
                    }
                    
                    //>>>>>>>>>>maxfong
                    [newQuery setValue:cinemaID forKey:@"cinemaID"];
                    [newQuery setValue:cinemaName forKey:@"cinemaName"];
                    [newQuery setValue:movieId forKey:@"movieId"];
                    [newQuery setValue:switchValue forKey:@"switchValue"];
                    //<<<<<<<<<<maxfong
                    
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case gotoPagexxSearchAll:
        {
            switch (contentType) {
                case gotoPagexxContentHome:
                {
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case gotoPagexxUGC:
        {
            switch (contentType) {
                case gotoPagexxContentDest:
                {
                }
                    break;
                    
                default:
                    break;
            }
            
        }
            break;
            
        case gotoPagexxProjectBus:
        {
            switch (contentType) {
                case gotoPagexxContentOrderDetails:
                {
                    //http://shouji.17u.cn/internal/bus/orderdetails/[sign memberid]/[orderId]
                    
                    NSString *orderId=nil;
                    if (array.count > 7) {
                        orderId = array[7];
                    }
                    
                    //>>>>>>>>>>maxfong
                    [newQuery setValue:orderId forKey:@"orderId"];
                    //<<<<<<<<<<maxfong
                    
                }
                    break;
                    
                case gotoPagexxContentHome:
                {
                    NSString *startcity = nil;
                    NSString *endcity = nil;
                    if (paramsDict) {
                        startcity = [[paramsDict objectForKey:@"startCity"] URLDecodedString];
                        endcity = [[paramsDict objectForKey:@"endCity"] URLDecodedString];
                    }
                    
                    //>>>>>>>>>>maxfong
                    [newQuery setValue:startcity forKey:@"startcity"];
                    [newQuery setValue:endcity forKey:@"endcity"];
                    //<<<<<<<<<<maxfong
                    
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case gotoPagexxLightTravel:
        {
            switch (contentType) {
                case gotoPagexxLightTravelUploadPic:
                {
                    NSString *parmString =paramsDict[@"uploadinfo"];
                    NSDictionary *parmDic = nil;
                    if (parmString.length>0) {
                        parmDic =[NSJSONSerialization JSONObjectWithData:[parmString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
                    }
                    
                    //>>>>>>>>>>maxfong
                    [newQuery addEntriesFromDictionary:parmDic];
                    //<<<<<<<<<<maxfong
                    
                }
                    break;
                    
                default:
                    break;
            }
            
        }
            break;
        case gotoPagexxProjectDiscovery:
        {
            if (array.count > 5) {
                NSString *content = array[5];
                if ([content isEqualToString:@"cameraDetail"]) {
                    //相机详情 http://shouji.17u.cn/internal/discovery/cameraDetail?tcId=XXX
                    NSString *tcid = paramsDict[@"tcId"];
                    
                    //>>>>>>>>>>maxfong
                    [newQuery setValue:tcid forKey:@"tcid"];
                    //<<<<<<<<<<maxfong
                }
            }
        }
            break;
        case gotoPagexxProjectInland:
        {
            NSString *typeStr = @"";
            if (array.count > 5)
            {
                typeStr = [array objectAtIndex:5];
            }
            
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic addEntriesFromDictionary:@{@"PageType":typeStr}];
            [dic addEntriesFromDictionary:paramsDict];
            
            //>>>>>>>>>>maxfong
            [newQuery addEntriesFromDictionary:dic];
            [newQuery setValue:@(1) forKey:@"PageGotoType"];
            //<<<<<<<<<<maxfong
            
            break;
        }
        case gotoPagexxStrategy:
        {
            switch (contentType) {
                case gotoPagexxPoiDetail:
                {
                    NSString *parmString = [array lastObject];
                    //>>>>>>>>>>maxfong
                    [newQuery setValue:parmString forKey:@"poiId"];
                    //<<<<<<<<<<maxfong
                    
                }
                    break;
                    
                default:
                    break;
            }
            
        }
        default:
        {
        }
            break;
    }
    [newQuery addEntriesFromDictionary:paramsDict];
    //>>>>>>>>>>maxfong
    NSMutableString *paramString = [NSMutableString string];
    [newQuery enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]]) {
            [paramString appendString:[NSString stringWithFormat:@"%@=%@&", key, obj]];
        }
        else if ([obj isKindOfClass:[NSArray class]] || [obj isKindOfClass:[NSDictionary class]]) {
            [paramString appendString:[NSString stringWithFormat:@"%@=%@&", key, @"对象数据已隐藏"]];
        }
        else if ([obj isKindOfClass:[NSNull class]]) { }
        else {
            NSAssert(nil, ([NSString stringWithFormat:@"URLRoute:链接Key:%@的数据无法转换", key]));
        }
    }];
    if (paramString.length) {
        NSString *newParamString = [paramString substringWithRange:NSMakeRange(0, [paramString length] - 1)];
        newParamString = [newParamString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [newURLString appendString:[NSString stringWithFormat:@"?%@", newParamString]];
    }
    //<<<<<<<<<<maxfong
    NSString *urlMD5 = [newURLString md5];
    
    //缓存转换数据，供使用地方调用
    [TCTGlobalManager setObject:newQuery forKey:urlMD5];
    
    [newQuery setValue:@"1" forKey:URLRouteVersion];
#ifdef TC_Server_Debug
    NSLog(@"URLRoute转换完毕");
#endif
    return [NSURL URLWithString:newURLString];
}

+ (id)deserializeObjectWithString:(NSString *)string {
    if ([string length] > 0) {
        return [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding]
                                               options:NSJSONReadingAllowFragments
                                                 error:nil];
    }
    return nil;
}

@end
