//
//  QQProxy.m
//  ShareProxy
//
//  Created by 维农 on 16/7/20.
//  Copyright © 2016年 维农-quan. All rights reserved.
//

#import "QQProxy.h"
#import "UIImage+QShare.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>

static NSString *const kQQErrorDomain  = @"qq_error_domain";
NSString *const kQShareTypeQQ          = @"qShare_qq";
NSString *const kTencentQQSceneTypeKey = @"tencent_qq_scene_type_key";

@interface QQProxy ()<QQApiInterfaceDelegate, TencentSessionDelegate>
@property (copy, nonatomic) QShareCompletedBlock block;
@property (strong, nonatomic) TencentOAuth *tencentOAuth;
@end

@implementation QQProxy

+ (void)load{
    [[QShare sharedInstance] registerProxyObject:[[QQProxy alloc] init] withName:kQShareTypeQQ];
}
#pragma mark - reg
- (void)registerWithConfiguration:(NSDictionary *)configuration{
    self.tencentOAuth = [[TencentOAuth alloc] initWithAppId:configuration[kQShareAppIdKey] andDelegate:self];
}

- (BOOL)handleOpenURL:(NSURL *)url{
    BOOL qq = [QQApiInterface handleOpenURL:url delegate:self];
    BOOL tencent = [TencentOAuth HandleOpenURL:url];
    return qq||tencent;
}

- (BOOL)isPlatformAppInstalled{
    return [TencentOAuth iphoneQQInstalled];
}

- (BOOL)isRegistered{
    return self.tencentOAuth != nil;
}

- (BOOL)isLoginEnabledOnPlatform{
    return [QQApiInterface isQQInstalled] && [QQApiInterface isQQSupportApi];
}
#pragma mark - auth
- (void)loginToPlatform:(QShareCompletedBlock)completeBlock{
    self.block = completeBlock;
    if ([self isLoginEnabledOnPlatform]) {
        [self.tencentOAuth authorize:@[kOPEN_PERMISSION_GET_INFO,
                                       kOPEN_PERMISSION_GET_USER_INFO,
                                       kOPEN_PERMISSION_GET_SIMPLE_USER_INFO]
                            inSafari:YES];
    }else{
        NSError * error = [NSError errorWithDomain:kQQErrorDomain code:kQShareErrorCodePlatformNotInstalled userInfo:@{NSLocalizedDescriptionKey:@"请先安装QQ客户端"}];
        if (completeBlock) {
            completeBlock(nil, error);
        }
    }
}

- (void)getPlatformUserInfo:(QShareCompletedBlock)completeBlock{
    self.block = completeBlock;
    BOOL get = [self.tencentOAuth getUserInfo];
}

- (void)logoutFromPlatform{
    [self.tencentOAuth logout:self];
}
#pragma mark - share
- (void)share:(QMessage *)message completed:(QShareCompletedBlock)completedBlock{
    if ([self isLoginEnabledOnPlatform]) {
        self.block = completedBlock;
        QQApiObject *apiObject = [message qqMessage];
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:apiObject];
        QQApiSendResultCode resultCode;
        if (message.userInfo && message.userInfo[kTencentQQSceneTypeKey] && [message.userInfo[kTencentQQSceneTypeKey] intValue] == TencentSceneQZone) {
            apiObject.cflag = kQQAPICtrlFlagQZoneShareOnStart;
            resultCode = [QQApiInterface SendReqToQZone:req];
        }else{
            apiObject.cflag = kQQAPICtrlFlagQQShare;
            resultCode = [QQApiInterface sendReq:req];
        }
        NSString *errorMsg = [self handleQQSendResult:resultCode];
        if (errorMsg) {
            self.block = nil;
            NSError * error = [NSError errorWithDomain:kQQErrorDomain code:kQShareErrorCodePlatformNotInstalled userInfo:@{NSLocalizedDescriptionKey:errorMsg}];
            completedBlock(nil, error);
        }
    }else{
        NSError * error = [NSError errorWithDomain:kQQErrorDomain code:kQShareErrorCodePlatformNotInstalled userInfo:@{NSLocalizedDescriptionKey:@"请先安装QQ客户端"}];
        if (completedBlock) {
            completedBlock(nil, error);
        }
    }
}

//- (void)payOrder:(id)orderEntity block:(QPayBlock)payBlock{
//    NSError * error = [NSError errorWithDomain:kQQErrorDomain code:kQShareErrorCodePlatformNotInstalled userInfo:@{NSLocalizedDescriptionKey:@"QQ暂不支持支付功能"}];
//    if (payBlock) {
//        payBlock(nil, error);
//    }
//}
//
//- (void)payProcessOrderWithPaymentResult:(NSURL *)url standbyBlock:(void (^)(NSDictionary * __nullable, NSError * _Nonnull))block{
//    NSError * error = [NSError errorWithDomain:kQQErrorDomain code:kQShareErrorCodePlatformNotInstalled userInfo:@{NSLocalizedDescriptionKey:@"QQ暂不支持支付功能"}];
//    if (block) {
//        block(nil, error);
//    }
//}

#pragma mark - QQ error Msg
- (NSString *)handleQQSendResult:(QQApiSendResultCode)sendResult
{
    NSString *errorMessage = nil;
    switch (sendResult)
    {
        case EQQAPIAPPNOTREGISTED:
        {
            errorMessage = @"App 未注册";
            
            break;
        }
            
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID:
        {
            errorMessage = @"发送参数错误";
            
            break;
        }
            
        case EQQAPIQQNOTINSTALLED:
        {
            errorMessage = @"未安装手机 QQ";
            
            break;
        }
            
        case EQQAPIQQNOTSUPPORTAPI:
        {
            errorMessage = @"API 接口不支持";
            
            break;
        }
            
        case EQQAPISENDFAILD:
        {
            errorMessage = @"发送失败";
            
            break;
        }
            
        default:
        {
            break;
        }
    }
    
    return errorMessage;
}

#pragma mark - QQ SDK Delegate
- (void)tencentDidLogin{
    if (self.tencentOAuth.accessToken && self.tencentOAuth.accessToken.length) {
        QUser *qUser = [[QUser alloc] init];
        [qUser setAccessToken:self.tencentOAuth.accessToken];
        [qUser setUid:self.tencentOAuth.openId];
        if (self.block) {
            self.block(qUser, nil);
        }
    }else{
        NSError * error = [NSError errorWithDomain:kQQErrorDomain code:kQShareErrorCodePlatformNotInstalled userInfo:@{NSLocalizedDescriptionKey:@"登录失败"}];
        if (self.block) {
            self.block(nil, error);
        }
    }
}

- (void)tencentDidNotLogin:(BOOL)cancelled{
    NSString *errMsg = @"登录失败";
    if (cancelled) {
        errMsg = @"取消登录";
    }
    NSError * error = [NSError errorWithDomain:kQQErrorDomain code:kQShareErrorCodePlatformNotInstalled userInfo:@{NSLocalizedDescriptionKey:errMsg}];
    if (self.block) {
        self.block(nil, error);
    }
}

- (void)tencentDidNotNetWork{
    NSError * error = [NSError errorWithDomain:kQQErrorDomain code:kQShareErrorCodePlatformNotInstalled userInfo:@{NSLocalizedDescriptionKey:@"网络连接错误"}];
    if (self.block) {
        self.block(nil, error);
    }
}

- (void)getUserInfoResponse:(APIResponse *)response{
    if (!self.block) {
        return;
    }
    if (response.retCode == URLREQUEST_SUCCEED) {
        NSDictionary * userInfo = response.jsonResponse;
        QUser *qUser = nil;
        if (self.tencentOAuth.openId && userInfo) {
            qUser = [[QUser alloc] init];
            qUser.uid = self.tencentOAuth.openId;
            qUser.nick = userInfo[@"nickname"];
            qUser.gender = [userInfo[@"gender"] isEqualToString:@""] ? @"1" : @"0";
            qUser.avatar = userInfo[@"figureurl_qq_2"];
            qUser.provider = @"qqspace";
            qUser.accessToken = self.tencentOAuth.accessToken;
            qUser.rawData = userInfo;
            self.block(qUser, nil);
        }else{
            NSError * error = [NSError errorWithDomain:kQQErrorDomain code:kQShareErrorCodePlatformNotInstalled userInfo:@{NSLocalizedDescriptionKey:@"获取授权数据错误"}];
            self.block(nil, error);
        }
    }else{
        NSError * error = [NSError errorWithDomain:kQQErrorDomain code:kQShareErrorCodePlatformNotInstalled userInfo:@{NSLocalizedDescriptionKey:response.errorMsg}];
        self.block(nil, error);
    }
}

- (void)isOnlineResponse:(NSDictionary *)response{
    
}

- (void)onReq:(QQBaseReq *)req{
    /*! 处理来至QQ的请求*/
}

- (void)onResp:(QQBaseResp *)resp{
    if (!self.block) {
        return;
    }
    NSString *resultCode = resp.result;
    if ([resultCode isEqualToString:@"0"]) {//成功
        self.block(@"分享成功",nil);
    }else if ([resultCode isEqualToString:@"-4"]){
        self.block(@"取消分享",nil);
    }else{
        self.block(@"分享失败",nil);
    }
    
}

@end

@implementation QTextMessage (QQ)
- (QQApiObject *)qqMessage{
    QQApiTextObject *textObject = [QQApiTextObject objectWithText:self.text];
    return textObject;
}
@end

@implementation QMediaMessage (QQ)
- (NSData *)thumbnailableData{
    UIImage *thumbImage = self.thumbnailableImage;
    NSData *imageData = UIImageJPEGRepresentation(thumbImage, 1.0);
    CGSize thumbSize = self.thumbnailableImage.size;
    
    NSData *thumbData = imageData;
    while (thumbData.length > 1000 * 1024) {  //缩略图不能超过1M
        thumbSize = CGSizeMake(thumbSize.width / 1.5, thumbSize.height / 1.5);
        thumbImage = [thumbImage QShare_resizedImage:thumbSize interpolationQuality:kCGInterpolationDefault];
        thumbData = UIImageJPEGRepresentation(thumbImage, 0.5);
    }
    return thumbData;
    
}
-(QQApiObject *)qqMessage{
    NSAssert(false, @"Should implement this method.");
    
    return nil;
}
@end
@implementation QImageMessage (QQ)
- (NSData *)getImageData{
    if (self.shareImage) {
        UIImage *contentImage = self.shareImage;
        NSData *imageData = UIImageJPEGRepresentation(contentImage, 1.0);
        CGSize thumbSize = self.shareImage.size;
        
        NSData *contentData = imageData;
        while (contentData.length > 5 * 1000 * 1024) {  //缩略图不能超过1M
            thumbSize = CGSizeMake(thumbSize.width / 1.5, thumbSize.height / 1.5);
            contentImage = [contentImage QShare_resizedImage:thumbSize interpolationQuality:kCGInterpolationDefault];
            contentData = UIImageJPEGRepresentation(contentImage, 0.8);
        }
        return contentData;
    }
    return self.imageData;
}
- (QQApiObject *)qqMessage{
    return [QQApiImageObject objectWithData:[self getImageData]
                           previewImageData:[self thumbnailableData]
                                      title:self.title
                                description:self.desc];
}
@end
@implementation QAudioMessage (QQ)

- (QQApiObject *)qqMessage{
    return [QQApiAudioObject objectWithURL:[NSURL URLWithString:self.audioUrl]
                                     title:self.title
                               description:self.desc
                          previewImageData:[self thumbnailableData]];
}

@end

@implementation QVideoMessage (QQ)

- (QQApiObject *)qqMessage{
    return [QQApiVideoObject objectWithURL:[NSURL URLWithString:self.videoUrl]
                                     title:self.title
                               description:self.desc
                          previewImageData:[self thumbnailableData]];
}

@end
@implementation QPageMessage (QQ)

- (QQApiObject *)qqMessage{
    return [QQApiNewsObject objectWithURL:[NSURL URLWithString:self.webPageUrl]
                                    title:self.title
                              description:self.desc
                         previewImageData:[self thumbnailableData]];
}

@end