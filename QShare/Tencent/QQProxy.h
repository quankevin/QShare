//
//  QQProxy.h
//  ShareProxy
//
//  Created by 维农 on 16/7/20.
//  Copyright © 2016年 维农-quan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QShare.h"


@class QQApiObject;

NS_ASSUME_NONNULL_BEGIN
FOUNDATION_EXTERN NSString * const kQShareTypeQQ;//每一个proxy 都需要声明一个自己的type
FOUNDATION_EXTERN NSString * const kTencentQQSceneTypeKey;//针对qq 有分享到空间和会话的key值

typedef NS_ENUM(NSUInteger) {
    /*!
     *  @brief QQ会话分享类型，默认
     */
    TencentSceneQQ = 1,
    /*!
     *  @brief QQ空间分享类型
     */
    TencentSceneQZone
}TencentShareScene;

@interface QQProxy : NSObject <QRegisterProxyProtocol, QAuthProxyProtocol, QShareProxyProtocol>

@end
@interface QMessage (QQ)
- (QQApiObject *)qqMessage;
@end

@interface QTextMessage (QQ)

@end

@interface QMediaMessage (QQ)

@end
@interface QImageMessage (QQ)

@end
@interface QAudioMessage (QQ)

@end
@interface QVideoMessage (QQ)

@end
@interface QPageMessage (QQ)

@end
NS_ASSUME_NONNULL_END