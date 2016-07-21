//
//  WechatProxy.h
//  ShareProxy
//
//  Created by 维农 on 16/7/20.
//  Copyright © 2016年 维农-quan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QShare.h"

@class WXMediaMessage;

NS_ASSUME_NONNULL_BEGIN
FOUNDATION_EXTERN NSString * const kQShareTypeWechat;
FOUNDATION_EXTERN NSString * const kWechatSceneTypeKey;
typedef NS_ENUM(NSUInteger) {
    /*!
     *  @brief 聊天，默认
     */
    WeChatSceneSession = 0,
    /*!
     *  @brief 朋友圈
     */
    WeChatSceneTimeline = 1,
    /*!
     *  @brief 收藏
     */
    WeChatSceneFavorite = 2,
}WechatShareScene;

@interface WXProxy : NSObject <QRegisterProxyProtocol, QAuthProxyProtocol, QShareProxyProtocol,QPayProxyProtocol>

@end

@interface QMediaMessage (WeChat)
/*!
 *  @brief 生成微信分享内容对象
 *
 *  @return 微信终端和第三方程序之间传递消息的多媒体消息内容
 */
- (WXMediaMessage *)wechatMessage;
@end

@interface QImageMessage (WeChat)

@end
@interface QAudioMessage (WeChat)

@end
@interface QVideoMessage (WeChat)

@end
@interface QPageMessage (WeChat)

@end
NS_ASSUME_NONNULL_END