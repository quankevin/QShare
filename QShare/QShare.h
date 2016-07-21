//
//  QShare.h
//  ShareProxy
//
//  Created by 维农 on 16/7/18.
//  Copyright © 2016年 维农-quan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
FOUNDATION_EXTERN NSString * const kQShareAppIdKey;
FOUNDATION_EXTERN NSString * const kQShareAppSecretKey;
FOUNDATION_EXTERN NSString * const kQShareAppSchemeKey;
FOUNDATION_EXTERN NSString * const kQShareAppRedirectUrlKey;
FOUNDATION_EXTERN NSString * const kQShareAppDebugModeKey;

typedef enum {
    kQAuthErrorCodeUserCancel               =-10,
    kQAuthErrorCodeSendFail                 =-11,
    kQAuthErrorCodeAuthDeny                 =-12,
    kQAuthErrorCodeUnsupport                =-13,
    kQAuthErrorCodeUnknown                  =-14,
    kQShareErrorCodeNotFound                = -1,
    kQShareErrorCodePlatformNotInstalled    = -2,
    kQPayErrorCodePayFail                   = -3,
    
}QErrorCode;


@class QMessage;

typedef void(^QShareCompletedBlock)(id __nullable result,NSError * __nullable error);//认证，分享成功后用这个返回
typedef void(^QPayBlock)(NSString  *__nullable signString,NSError * __nullable error);//支付成功后用这个返回数据

/*!
 *  @brief 注册第三方代理
 */
@protocol QRegisterProxyProtocol <NSObject>

/*!
 *  @brief 初始化第三方库
 *
 *  @param configuration 配置项
 */
- (void)registerWithConfiguration:(NSDictionary * __nonnull)configuration;

/*!
 *  @brief 处理应用回调URL
 *
 *  @param url 传入URL
 *
 *  @return YES则处理成功
 */
- (BOOL)handleOpenURL:(NSURL * __nullable)url;

/*!
 *  @brief 是否已经安装
 *
 *  @return YES 已安装 NO 未安装
 */
- (BOOL)isPlatformAppInstalled;

/*!
 *  @brief 是否已经初始化了
 *
 *  @return YES 初始化成功   NO 初始化失败
 */
- (BOOL)isRegistered;

/*!
 *  @brief 第三方是否支持登录
 *
 *  @return YES 支持 NO 不支持
 */
- (BOOL)isLoginEnabledOnPlatform;

@end
/*!
 *  @brief 第三方认证代理
 */
@protocol QAuthProxyProtocol <NSObject>

/*!
 *  @brief 第三方登录
 *
 *  @param completeBlock 登录回调返回信息
 */
- (void)loginToPlatform:(QShareCompletedBlock __nullable)completeBlock;

/*!
 *  @brief 获取用户在第三方的资料
 *
 *  @param completeBlock 返回的资料
 */
- (void)getPlatformUserInfo:(QShareCompletedBlock __nullable)completeBlock;

/*!
 *  @brief 登出 ，暂时应用在qq
 */
- (void)logoutFromPlatform;

@end
/*!
 *  @brief 分享代理
 */
@protocol QShareProxyProtocol <NSObject>
/*!
 *  @brief 分享
 *
 *  @param message 分享内容
 *  @param completedBlock 分享之后的回调
 */
- (void)share:(QMessage * __nonnull)message completed:(QShareCompletedBlock __nullable)completedBlock;

@end
/*!
 *  @brief 支付代理
 */
@protocol QPayProxyProtocol <NSObject>

/*!
 *  @brief 支付请求
 *
 *  @param orderEntity 支付的订单，可以是字符串，可以是实体，根据支付平台自身所需要的
 *  @param payBlock    回调支付信息
 */
- (void)payOrder:(id __nonnull)orderEntity block:(QPayBlock __nullable)payBlock;

/*!
 *  @brief 回调处理
 *
 *  @param url   回调的URL
 *  @param block 处理回调
 */
- (BOOL)payProcessOrderWithPaymentResult:(NSURL *)url
                            standbyBlock:(void(^)(NSDictionary * __nullable dict, NSError * __nullable error))block;

@end


@interface QShare : NSObject

+ (nonnull instancetype)sharedInstance;

/*!
 *  @brief 根据第三方名字来创建 proxy 对象
 *
 *  @param name 对应的第三方对象名字
 *
 *  @return 返回第三方对应的proxy 可能为nil。
 */
- (id __nullable)proxyForName:(NSString *)name;

/*!
 *  @brief 注册第三方库Proxy 到QShare
 *
 *  @param object 实现了 QShareProxyProtocol 协议的对象
 *  @param name   Proxy 对应得第三方名字
 */
- (void)registerProxyObject:(id<QRegisterProxyProtocol> __nonnull)object withName:(NSString * __nonnull)name;

/*!
 *  @brief 使用第三方的APPID 或者APPKey 和 APPSecret 来配置QShare
 *  @param configurations 配置好的第三方
 *  configurations 是第三方组件的集合
 *  每个Proxy中需要写入第三方自己的名字，如微博WeiboProxy 中需要加入常量kQShareTypeWeibo;
 *  kQShareTypeWeibo作为configurations 的key，value 配置一个NSDictionary key为 kQShareAppIdKey，kQShareAppSecretKey，kQShareAppSchemeKey，kQShareAppRedirectUrlKey，kQShareAppDebugModeKey 对应的每个第三方有自己所不同需要的值
 *
 */
- (void)registerWithConfigurations:(NSDictionary * __nonnull)configurations;

/*!
 *  @brief sso跳转处理
 *  @discussion 在 sso 跳转回到应用中，为了能从授权的第三方跳回应用并处理，需要配置好对应的URL Schemes。
 *
 *
 *  @param url 需要处理的url
 *
 *  @return YES 处理成功
 */
- (BOOL)handleOpenURL:(NSURL * __nullable)url;

/*!
 *  @brief 通过第三方授权登录
 *
 *  @param name           第三方的名称
 *  @param completedBlock 登录授权结束后，成功或者失败都要回调。
 */
- (void)loginToPlatformWithName:(NSString * __nonnull)name complete:(QShareCompletedBlock __nullable)completedBlock;

/*!
 *  @brief 获得用户在第三方的一些资料
 *
 *  @param name           第三方的名称
 *  @param completedBlock 返回的User信息
 */
- (void)getPlatformUserInfoWithName:(NSString * __nonnull)name complete:(QShareCompletedBlock __nullable)completedBlock;

/*!
 *  @brief 第三方登出，主要用来清除授权信息
 */
- (void)logoutFromPlatform;

/*!
 *  @brief 第三方是否被安装
 *
 *  @param name 第三方名称
 *
 *  @return YES 已安装
 */
- (BOOL)isInstalled:(NSString * __nonnull)name;

/*!
 *  @brief 分享
 *
 *  @param message        通过不同的内容来分享文本 QTextMessage，图片QIMageMessage，语音QAudioMessage，视频QVideoMessage，文章QPageMessage。
 *  @param name           第三方名称
 *  @param completedBlock 分享成功或失败都应该有回调
 */
- (void)share:(QMessage * __nonnull)message name:(NSString * __nonnull)name completed:(QShareCompletedBlock __nullable)completedBlock;

/*!
 *  @brief 第三方支付，非必需
 *
 *  @param orderEntity 需要传入第三方的内容，字符串或者组装的实体
 *  @param name        第三方的名称
 *  @param payBlock    支付成功与否的回调
 */
- (void)payOrder:(id __nonnull)orderEntity name:(NSString * __nonnull)name block:(QPayBlock __nullable)payBlock;

@end

//返回的数据组装的user信息
@interface QUser : NSObject
/*!
 *  @brief 第三方的UID，如
 */
@property (copy, nonatomic, nonnull) NSString *uid;
@property (copy, nonatomic, nonnull) NSString *nick;
@property (copy, nonatomic, nullable) NSString *avatar;
/*!
 *  @brief 登录授权时第三方来源，例如：weibo
 */
@property (copy, nonatomic, nonnull)NSString *provider;
/*!
 *  @brief 获取到的性别，接收时处理为1男 0女，如果没有获取到默认女
 */
@property (copy, nonatomic, nullable) NSString *gender;
/*!
 *  @brief 第三方返回的 accessToken
 */
@property (copy, nonatomic, nonnull) NSString *accessToken;
/*!
 *  @brief 获取到的完整的原始用户信息
 */
@property (strong, nonatomic, nonnull)NSDictionary *rawData;

@end

//发出分享的消息体
@interface QMessage : NSObject
/*!
 *  @brief 分享的扩展信息，如：微信分享时的好友，朋友圈，收藏
 */
@property (strong, nonatomic, nullable) NSDictionary *userInfo;
@end

@interface QTextMessage : QMessage
@property (copy ,nonatomic, nonnull) NSString *text;
@end

@interface QMediaMessage : QMessage
/*!
 *  @brief 分享微博多媒体内容时需要指定一个自己APP的唯一ID
 */
@property (copy, nonatomic, nullable) NSString *messageId;
@property (copy, nonatomic, nullable) NSString *title;
@property (copy, nonatomic, nullable) NSString *desc;
/** @brief 会根据分享到不同的第三方进行缩略图操作。 */
@property (strong, nonatomic, nullable) UIImage *thumbnailableImage;
@end

@interface QImageMessage : QMediaMessage
/** @brief 分享的图片,imageData根据这个UIImage而来 */
@property (strong, nonatomic, nullable) UIImage *shareImage;
/*!
 *  @brief 分享一张图片，图片的二进制数据
 */
@property (strong, nonatomic, nullable) NSData *imageData;
/*!
 *  @brief 当分享一张图片时，图片的远程 URL。与 imageData 二选一。 
 */
@property (copy, nonatomic, nullable) NSString *imageUrl DEPRECATED_MSG_ATTRIBUTE("Use `imageData` instead. url not work in Wechat SDK 1.7.1");
@end
@interface QAudioMessage  : QMediaMessage

/** @brief 语音播放页面的地址。 */
@property (copy, nonatomic, nonnull) NSString *audioUrl;

/** @brief 语音数据的地址。 */
@property (copy, nonatomic, nonnull) NSString *audioDataUrl;

@end

@interface QVideoMessage : QMediaMessage

/** @brief 视频播放页面的地址。 */
@property (copy, nonatomic, nonnull) NSString *videoUrl;

/** @brief 视频数据的地址。 */
@property (copy, nonatomic, nonnull) NSString *videoDataUrl;

@end

@interface QPageMessage : QMediaMessage

/** @brief 分享的文章，新闻的链接地址。 */
@property (copy, nonatomic, nonnull) NSString *webPageUrl;

@end
NS_ASSUME_NONNULL_END
