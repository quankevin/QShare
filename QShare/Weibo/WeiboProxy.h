//
//  WeiboProxy.h
//  ShareProxy
//
//  Created by 维农 on 16/7/21.
//  Copyright © 2016年 维农-quan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QShare.h"

@class WBMessageObject;

FOUNDATION_EXTERN NSString * __nonnull const kQShareTypeWeibo;
NS_ASSUME_NONNULL_BEGIN
@interface WeiboProxy : NSObject <QRegisterProxyProtocol, QAuthProxyProtocol, QShareProxyProtocol>

@end
@interface QMessage (Weibo)
- (WBMessageObject * __nonnull)weiboMessage;
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