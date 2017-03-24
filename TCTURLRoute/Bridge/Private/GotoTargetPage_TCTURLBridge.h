//
//  GotoTargetPage.h
//  TCTravel_IPhone
//
//  Created by lyf3852 on 13-3-29.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    gotoPagexxProjectNone,
    gotoPagexxProjectHotel, //酒店
    gotoPagexxProjectHotelgroupby, //酒店团购
    gotoPagexxProjectScenery, //景区
    gotoPagexxProjectFlight, //机票
    gotoPagexxProjectInternalFlight, //国际机票
    gotoPagexxProjectLogin, //登陆
    gotoPagexxProjectSelftrip, //自助游
    gotoPagexxProjectHoliday, //度假
    gotoPagexxProjectSign, //签到
    gotoPagexxProjectNearby, //酒店，景点，周边游 ，需要本地定位经纬度
    gotoPagexxShare, //分享
    gotoPagexxProjectGuide, //攻略
    gotoPagexxTrain, //火车
    gotoPagexxShip, //邮轮
    gotoPagexxCommon, //公共
    gotoPagexxHome, //首页
    gotoPagexxMine, //我的
    gotoPagexxYongche, //用车
    gotoPagexxTaxi, // taxi
    gotoPagexxWallet, //票夹
    gotoPagexxProjectMovie, //电影
    gotoPagexxProjectScream, //爱的尖叫
    gotoPagexxSearchAll, //搜索
    gotoPagexxUGC, // UGC项目
    gotoPagexxProjectBus, //汽车
    gotoPagexxProjectDiscovery, //发现
    gotoPagexxLightTravel, //轻游记
    gotoPagexxStrategy, //内容攻略
    gotoPagexxProjectInland //国内游
} gotoPagexxProjectType;

typedef enum
{
    gotoPagexxContentNone,
    gotoPagexxContentDetail,              //酒店景点自助游度假详情
    gotoPagexxContentList,                //酒机票自助游度假列表
    gotoPagexxContentHotelNearby,              //酒店列表，经纬度
    gotoPagexxContentOrderDetails,        //订单详情,酒景机自助游度假
    gotoPagexxContentBook,                //预订，暂只景点
    gotoPagexxContentComment,             //点评，酒景机
    gotoPagexxContentHome,                 //酒机景自助游度假一筐搜首页
    gotoPagexxContentHotel,               //伤感的修改，上下逻辑混乱了，无奈彷徨又迷茫
    gotoPagexxContentSceney,
    gotoPagexxContentSelftrip
    ,gotoPagexxShareAll                   //调用分享页面
    ,gotoPagexxShareWeChatQuan               //微信朋友圈
    ,gotoPagexxContentGuideCitydetails        //城市详情
    ,gotoPagexxContengGuideScenerydetails     //景点详情
    ,gotoPagexxCommonPay                      //公共-支付
    ,gotoPagexxCommonClose                    //公共-关闭当前页面
    ,gotoPagexxCommonPushflight                     //行程助手
    ,gotoPagexxCommonFeedback                     //意见反馈页面
    ,gotoPagexxCommonPics                         //公共图片
    ,gotoPagexxContentOrder                      //order
    ,gotoPagexxContentScenerylist             //scenerylist
    ,gotoPagexxContentTicketfolders           //票夹
    ,gotoPagexxContentCommonMemberinfo        //进入个人资料修改中心
    ,gotoPagexxContentYongcheZuche            //用车 自驾租车 首页
    ,gotoPagexxContentPayment                 //支付
    ,gotoPagexxContentGradationPayment        //国际机票分次支付
    ,gotoPagexxContentFillOrder               //邮轮填写订单
    ,gotoPagexxContentSmallRoomFillOrder      //邮轮大小房型订单填写页
    ,gotoPagexxContentSearch                  //邮轮搜索页
    ,gotoPagexxContentSpecialOfferWriteOrder  //邮轮特卖订单填写页
    ,gotoPagexxContentSceneyElist             //景区带参数列表
    ,gotoPagexxContentFlightDynamic           //机票动态跳转
    ,gotoPagexxContentFlightDynamicAttentionList //机票航班动态已关注列表
    ,gotoPagexxContentFlightPriceTendHome        //机票价格趋势首页
    ,gotoPagexxContentFlightAirPortHome       //机票乘机宝典首页
    ,gotoPagexxContentOrderlist               //订单列表
    ,gotoPagexxContentCardOrderDetail         //邮轮卡订单详情
    ,gotoPagexxContentrobtickets              //火车抢票
    ,gotoPagexxContentCodeDetail              //codeDetail
    ,gotoPagexxContentLitescenery             //轻量级景区
    ,gotoPagexxContentBus                     //bus
    ,gotoPagexxContentDest                    //目的地
    ,gotoPagexxContentSche                    //电影院排期
    ,gotoPagexxContentSingeHome
    ,gotoPagexxContentWealth                  //我的财富
    ,gotoPagexxContentMineOrders              //我的订单中心
    ,gotoPagexxContentMineCards               //我的卡票
    ,gotoPagexxContentMineMessagebox          //系统消息页面
    ,gotoPagexxContentCommonDetail
    ,gotoPagexxContentHotRanking              //周边游热搜
    ,gotoPagexxContentAllTypes                // 周边游 所有分类
    ,gotoPagexxContentPayplatform             //支付收银台
    ,gotoPagexxContentAssistant               //行程助手
    ,gotoPagexxContentWritecomment            //写点评
    ,gotoPagexxContentCommentlist             //全部点评
    ,gotoPagexxContentFlightCashierDesk       //机票 -》收银台
    ,gotoPagexxLightTravelUploadPic      //轻游记-》上传图片
    ,gotoPagexxContentMyStar                  //收藏
    ,gotoPagexxContentDestination             //出境目的地选择页
    ,gotoPagexxContentCalendar             //出境价格日历页
    ,gotoPagexxContentFavor                   //猜你喜欢
    ,gotoPagexxPoiDetail                      //poi详情
    ,gotoPagexxContentGroupdetails            //跟团详情
    ,gotoPagexxContentCommonBindMobile        //绑定手机号
    ,gotoPagexxContentCommonDpHomePage        //点评个人主页
} gotoPagexxContentType;

@interface GotoTargetPage_TCTURLBridge : NSObject

/** 规则转换 */
+ (NSURL *)URLWithString:(NSString *)aString;

@end
