//
//  AliProxy.h
//  ShareProxy
//
//  Created by 维农 on 16/7/21.
//  Copyright © 2016年 维农-quan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QShare.h"


FOUNDATION_EXTERN NSString * __nonnull const kQShareTypeAli;
NS_ASSUME_NONNULL_BEGIN
@interface AliProxy : NSObject <QRegisterProxyProtocol,QPayProxyProtocol>



@end
@interface QMessage (Ali)

@end
@interface QTextMessage (Ali)

@end

@interface QMediaMessage (Ali)

@end
@interface QImageMessage (Ali)

@end
@interface QAudioMessage (Ali)

@end
@interface QVideoMessage (Ali)

@end
@interface QPageMessage (Ali)

@end
NS_ASSUME_NONNULL_END