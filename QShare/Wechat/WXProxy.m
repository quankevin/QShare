//
//  WechatProxy.m
//  ShareProxy
//
//  Created by 维农 on 16/7/20.
//  Copyright © 2016年 维农-quan. All rights reserved.
//

#import "WXProxy.h"
#import <UIKit/UIKit.h>
#import "UIImage+QShare.h"
#import "WXApi.h"

static NSString * const kWechatErrorDomain = @"wechat_error_domain";
NSString * const kQShareTypeWechat = @"qShare_wechat";
NSString * const kWechatSceneTypeKey = @"wechat_scene_type_key";
////////////
static NSString * const kWX_GET_URL = @"https://api.weixin.qq.com/sns/";
static NSString * const kWX_GET_TOKEN_API = @"oauth2/access_token";
static NSString * const kWX_GET_USERINFO_API = @"userinfo";
////////////
@interface WXProxy ()<WXApiDelegate>{
    BOOL _shouldHandleWXPay;
}
@property (copy, nonatomic) NSString *wechatAppId;
@property (copy, nonatomic) NSString *wechatSecret;

@property (copy, nonatomic) NSString *wxCode;

@property (copy, nonatomic) QShareCompletedBlock block;
@property (copy, nonatomic) QPayBlock payBlock;
@end

@implementation WXProxy
+ (void)load{
    [[QShare sharedInstance] registerProxyObject:[[WXProxy alloc] init] withName:kQShareTypeWechat];
}
#pragma mark - reg
- (void)registerWithConfiguration:(NSDictionary *)configuration{
    self.wechatAppId = configuration[kQShareAppIdKey];
    self.wechatSecret = configuration[kQShareAppSecretKey];
    [WXApi registerApp:self.wechatAppId];
}

- (BOOL)handleOpenURL:(NSURL *)url{
    if ([self payProcessOrderWithPaymentResult:url standbyBlock:^(NSDictionary * _Nullable dict, NSError * _Nullable error) {
        
    }]){
        return YES;
    }
    return [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)isPlatformAppInstalled{
    return [WXApi isWXAppInstalled];
}

- (BOOL)isRegistered{
    return (self.wechatAppId && self.wechatAppId.length && self.wechatSecret && self.wechatSecret.length);
}

- (BOOL)isLoginEnabledOnPlatform{
    return [WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi];
}
#pragma mark - auth
- (void)loginToPlatform:(QShareCompletedBlock)completeBlock{
    if ([self isLoginEnabledOnPlatform]) {
        self.block = completeBlock;
        SendAuthReq *request = [[SendAuthReq alloc] init];
        request.scope = @"snsapi_message,snsapi_userinfo,snsapi_friend,snsapi_contact";
        request.state = [NSString stringWithFormat:@"wechat_auth_login_%@",[[NSBundle mainBundle] bundleIdentifier]];
        [WXApi sendReq:request];
    }else{
        NSError * error = [NSError errorWithDomain:kWechatErrorDomain code:kQShareErrorCodePlatformNotInstalled userInfo:@{NSLocalizedDescriptionKey:@"请先安装微信客户端"}];
        if (completeBlock) {
            completeBlock(nil, error);
        }
    }
}

- (void)handleWeChatAuthResp:(SendAuthResp *)resp{
    if (!self.block) {
        return;
    }
    
    if (resp.errCode == WXSuccess) {
        if (resp.code) {
            self.block(resp.code,nil);
            //只返回code，
            //让服务器用code做认证，并获取到用户的信息
            
            _wxCode = resp.code;
            //如果需要继续获取在手机端上获取用户的信息，调用  [self getPlatformUserInfo:self.block];
        }
    }
    
}

- (void)getPlatformUserInfo:(QShareCompletedBlock)completeBlock{
    self.block = completeBlock;
    [self getWeChatUserInfoWithCompleted:completeBlock];
}

- (void)logoutFromPlatform{
    
}

#pragma mark - httpRequest for get WeChat UserInfo
/*!
 *  @brief 通过两层api调用来获取用户信息,这部分信息，如果可以的话，服务器来做。
 *
 *  @param completedBlock 返回组装好的用户信息
 */
- (void)getWeChatUserInfoWithCompleted:(QShareCompletedBlock)completedBlock{
    if (!self.wxCode) {
        return;
    }
    [self getWeChatRequestWithPath:kWX_GET_TOKEN_API params:@{@"appid": self.wechatAppId, @"secret":self.wechatSecret, @"code":self.wxCode, @"grant_type": @"authorization_code"} completed:^(id  _Nullable result, NSError * _Nullable error) {
        if (result) {
            NSString *openId = result[@"openid"];
            NSString *accessToken = result[@"access_token"];
            if (openId && accessToken){
                [self getWeChatRequestWithPath:kWX_GET_USERINFO_API params:@{@"":openId, @"":accessToken} completed:^(id  _Nullable result, NSError * _Nullable error) {
                    QUser *qUser = nil;
                    if (result && result[@"unionid"]) {
                        qUser = [[QUser alloc] init];
                        qUser.uid = result[@"unionid"];
                        qUser.gender = [result[@"sex"] integerValue] == 1 ? @"1" : @"0";
                        qUser.nick = result[@"nickname"];
                        qUser.avatar = result[@"headimgurl"];
                        qUser.provider = @"wechat";
                        qUser.rawData = result;
                        qUser.accessToken = accessToken;
                        if (completedBlock) {
                            completedBlock(qUser,error);
                        }
                    }
                }];
            }
        }
    }];
}

- (void)getWeChatRequestWithPath:(NSString *)path
                          params:(NSDictionary *)params
                       completed:(void(^)(id __nullable result, NSError * __nullable error))completedBlock{
    NSString *baseUrlString = kWX_GET_URL;
    [self requestWithURL:[baseUrlString stringByAppendingString:path]
                  method:@"GET"
                  params:params
               completed:completedBlock];
    
}

- (void)requestWithURL:(NSString *)urlString
                              method:(NSString *)method
                              params:(NSDictionary *)params
                           completed:(void(^)(id __nullable result, NSError * __nullable error))completedBlock{
    NSURL *completedURL = [NSURL URLWithString:urlString];
    if (params && ![@[@"PUT",@"POST"] containsObject:method]) {
        completedURL = [self url:completedURL appendWithQueryDictionary:params];
    }
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:completedURL];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json; charset=utf8" forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod:method];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    if (params && [@[@"PUT", @"POST"] containsObject:method]){
        NSData *data = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
        if (data){
            [request setHTTPBody:data];
        }
    }
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        id result = nil;
        if (data) {
            result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        }
        if (completedBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completedBlock(result,error);
            });
        }
    }];
    [task resume];
    
}

/*!
 *  @brief 组装URL编码
 *
 *  @param object 传入的对象
 *
 *  @return 返回编码后的URLString
 */
static NSString *urlEncode(id object){
    return [[NSString stringWithFormat:@"%@", object] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

/*!
 *  @brief 拼接参数
 *
 *  @param url    源URL
 *  @param params get 入参
 *
 *  @return 返回URL拼接了入参的URLString
 */
- (NSURL *)url:(NSURL *)url appendWithQueryDictionary:(NSDictionary *)params;{
    if (params.count <= 0){
        return url;
    }
    
    NSMutableArray *parts = [NSMutableArray array];
    for (id key in params){
        id value = params[key];
        NSString *part = [NSString stringWithFormat: @"%@=%@", urlEncode(key), urlEncode(value)];
        [parts addObject: part];
    }
    
    NSString *queryString = [parts componentsJoinedByString: @"&"];
    NSString *sep = @"?";
    if (url.query){
        sep = @"&";
    }
    
    return [NSURL URLWithString:[url.absoluteString stringByAppendingFormat:@"%@%@", sep, queryString]];
}


#pragma mark - share
- (void)share:(QMessage *)message completed:(QShareCompletedBlock)completedBlock{
    if ([self isLoginEnabledOnPlatform]) {
        self.block = completedBlock;
        SendMessageToWXReq *wxReq = [[SendMessageToWXReq alloc] init];
        if ([message isKindOfClass:[QMediaMessage class]]) {
            wxReq.text = nil;
            wxReq.bText = NO;
            wxReq.message = [(QMediaMessage *)message wechatMessage];
        }else{
            wxReq.text = [(QTextMessage*)message text];
            wxReq.bText = YES;
        }
        wxReq.scene = WXSceneTimeline;
        if (message.userInfo && message.userInfo[kWechatSceneTypeKey]) {
            int scene = [message.userInfo[kWechatSceneTypeKey] intValue];
            if (scene >=0 && scene <=2) {
                wxReq.scene = scene;
            }
        }
        [WXApi sendReq:wxReq];
    }else{
        NSError * error = [NSError errorWithDomain:kWechatErrorDomain code:kQShareErrorCodePlatformNotInstalled userInfo:@{NSLocalizedDescriptionKey:@"请先安装微信客户端"}];
        if (completedBlock) {
            completedBlock(nil, error);
        }
    }
}

- (void)handleWeChatShareResp:(SendMessageToWXResp *)resp{
    
    if (resp.errCode == WXSuccess) {
        
        self.block(@"分享成功",nil);
        
    }
}

#pragma mark - pay
- (void)payOrder:(id)orderEntity block:(QPayBlock)payBlock{
    if (!payBlock) {
        return;
    }
    if ([self isLoginEnabledOnPlatform]) {
        
        NSDictionary *orderDict = orderEntity;
        //@"sign": @"0BD3E3AAB6C21BE9B4279EFBDC2E8A93",
//        @"appId": @"wxa41e061dee0cad3b",
//        @"timeStamp": @"1469091020",
//        @"prepayid": @"wx20160721165021daa96243a70504231043",
//        @"packageValue": @"Sign=WXPay",
//        @"partnerId": @"1261632901",
//        @"nonceStr": @"d0997de7af2f5d411d6b9c5ac64f53a0"
        PayReq *request = [[PayReq alloc] init];//以下的信息需要从orderEntity 获取
        request.partnerId = [orderDict objectForKey:@"partnerId"];
        request.prepayId = [orderDict objectForKey:@"prepayid"];
        request.package = [orderDict objectForKey:@"packageValue"];
        request.nonceStr = [orderDict objectForKey:@"nonceStr"];
        NSString *time = [orderDict objectForKey:@"timeStamp"];
        request.timeStamp = (UInt32)[time longLongValue];
        request.sign = [orderDict objectForKey:@"sign"];
        
        
        _shouldHandleWXPay = YES;
        BOOL result = [WXApi sendReq:request];
        if (!result) {
            _shouldHandleWXPay = NO;
            NSError * error = [NSError errorWithDomain:kWechatErrorDomain code:kQPayErrorCodePayFail userInfo:@{NSLocalizedDescriptionKey:@"无法支付"}];
            if (payBlock) {
                payBlock(nil, error);
            }
        }else{
            _payBlock = payBlock;
        }
        
    }else{
        NSError * error = [NSError errorWithDomain:kWechatErrorDomain code:kQShareErrorCodePlatformNotInstalled userInfo:@{NSLocalizedDescriptionKey:@"请先安装微信客户端"}];
        if (payBlock) {
            payBlock(nil, error);
        }
    }
}

- (void)handleWeChatPayResp:(PayResp *)resp{
    
    if (resp.errCode == WXSuccess) {
        
        self.payBlock(@"支付成功",nil);
        
    }else{
        NSError * error = [self error:resp.errCode];
        
        self.payBlock(nil, error);
    }
}

- (BOOL)payProcessOrderWithPaymentResult:(NSURL *)url standbyBlock:(void (^)(NSDictionary * __nullable, NSError * __nullable))block{
    if (_shouldHandleWXPay) {
        return[WXApi handleOpenURL:url delegate:self];
    }
    return NO;
}

#pragma mark - handle errMsg

- (NSError *)error:(int) errCode{
    NSError * error = [NSError errorWithDomain:kWechatErrorDomain code:kQAuthErrorCodeUnknown userInfo:@{NSLocalizedDescriptionKey:@"微信未知错误"}];
    if (errCode == WXErrCodeUserCancel){
        error = [NSError errorWithDomain:kWechatErrorDomain code:kQAuthErrorCodeUserCancel userInfo:@{NSLocalizedDescriptionKey:@"用户取消授权"}];
    }else if (errCode == WXErrCodeSentFail){
        error = [NSError errorWithDomain:kWechatErrorDomain code:kQAuthErrorCodeSendFail userInfo:@{NSLocalizedDescriptionKey:@"发送到微信失败"}];
        
    }else if (errCode == WXErrCodeAuthDeny){
        error = [NSError errorWithDomain:kWechatErrorDomain code:kQAuthErrorCodeAuthDeny userInfo:@{NSLocalizedDescriptionKey:@"授权失败"}];
        
    }else if (errCode == WXErrCodeUnsupport){
        error = [NSError errorWithDomain:kWechatErrorDomain code:kQAuthErrorCodeUnsupport userInfo:@{NSLocalizedDescriptionKey:@"微信不支持该功能"}];
    }
    return error;
}

#pragma mark - WeChat SDK Delegate

- (void)onReq:(BaseReq *)req{
    
}

- (void)onResp:(BaseResp *)resp{
    if (!self.block && !self.payBlock) {
        return;
    }
    
    
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        if (resp.errCode != WXSuccess) {
            NSError * error = [self error:resp.errCode];
            self.block (nil,error);
            return;
        }
        [self handleWeChatShareResp:(SendMessageToWXResp *)resp];
    }else if ([resp isKindOfClass:[SendAuthResp class]]){
        if (resp.errCode != WXSuccess) {
            NSError * error = [self error:resp.errCode];
            self.block (nil,error);
            return;
        }
        [self handleWeChatAuthResp:(SendAuthResp *)resp];
    }else if ([resp isKindOfClass:[PayResp class]]){
        if (resp.errCode != WXSuccess) {
            NSError * error = [self error:resp.errCode];
            self.payBlock (nil,error);
            return;
        }
        [self handleWeChatPayResp:(PayResp *)resp];
    }
     
}

@end

@implementation QMediaMessage (WeChat)
- (NSData *)getWxImageData{
    UIImage *contentImage = self.thumbnailableImage;
    NSData *imageData = UIImageJPEGRepresentation(contentImage, 1.0);
    CGSize thumbSize = self.thumbnailableImage.size;
    
    NSData *contentData = imageData;
    while (contentData.length > 32 * 1024) {  //缩略图不能超过32K
        thumbSize = CGSizeMake(thumbSize.width / 1.5, thumbSize.height / 1.5);
        contentImage = [contentImage QShare_resizedImage:thumbSize interpolationQuality:kCGInterpolationDefault];
        contentData = UIImageJPEGRepresentation(contentImage, 0.8);
    }
    return contentData;
}

- (WXMediaMessage *)wechatMessage{
    WXMediaMessage *msg = [WXMediaMessage message];
    msg.title = self.title;
    msg.description = self.desc;
    msg.thumbData = [self getWxImageData];
    return msg;
}

@end
@implementation QImageMessage (WeChat)

- (WXMediaMessage *)wechatMessage{
    WXMediaMessage *message = [super wechatMessage];
    message.thumbData = [super getWxImageData];
    
    WXImageObject *imageObect = [WXImageObject object];
    imageObect.imageData = self.imageData;
    message.mediaObject = imageObect;
    return message;
}

@end
@implementation QAudioMessage (WeChat)

- (WXMediaMessage *)wechatMessage
{
    WXMediaMessage *mesage = [super wechatMessage];
    
    WXMusicObject *musicObject = [WXMusicObject object];
    musicObject.musicUrl = self.audioUrl;
    musicObject.musicDataUrl = self.audioDataUrl;
    
    mesage.mediaObject = musicObject;
    
    return mesage;
}

@end

@implementation QVideoMessage (WeChat)

- (WXMediaMessage *)wechatMessage
{
    WXMediaMessage *message = [super wechatMessage];
    WXVideoObject *videoObject = [WXVideoObject object];
    videoObject.videoUrl = self.videoUrl;
    videoObject.videoLowBandUrl = self.videoDataUrl;
    message.mediaObject = videoObject;
    return message;
}

@end
@implementation QPageMessage (WeChat)

- (WXMediaMessage *)wechatMessage
{
    WXMediaMessage *message = [super wechatMessage];
//    [message setThumbImage:self.thumbnailableImage];
    WXWebpageObject *webPageObject = [WXWebpageObject object];
    webPageObject.webpageUrl = self.webPageUrl;
    message.mediaObject = webPageObject;
    return message;
}

@end



