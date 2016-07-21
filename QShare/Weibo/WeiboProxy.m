//
//  WeiboProxy.m
//  ShareProxy
//
//  Created by 维农 on 16/7/21.
//  Copyright © 2016年 维农-quan. All rights reserved.
//

#import "WeiboProxy.h"
#import <WeiboSDK.h>
#import <WeiboUser.h>
static NSString * const kWeiboTokenKey = @"weibo_token";
static NSString * const kWeiboUserIdKey = @"weibo_user_id";
static NSString * const kWeiboErrorDomain = @"weibo_error_domain";

NSString * const kQShareTypeWeibo = @"qShare_weibo";

@interface WeiboProxy () <WeiboSDKDelegate>{
    BOOL isRegistered;
}

@property (copy, nonatomic) QShareCompletedBlock block;
@property (copy, nonatomic) NSString * redirectUrl;

@end

@implementation WeiboProxy

+ (void)load{
    [[QShare sharedInstance] registerProxyObject:[[WeiboProxy alloc] init] withName:kQShareTypeWeibo];
}

#pragma reg
- (void)registerWithConfiguration:(NSDictionary *)configuration{
    isRegistered = [WeiboSDK registerApp:configuration[kQShareAppIdKey]];
    [WeiboSDK enableDebugMode:[configuration[kQShareAppDebugModeKey] boolValue]];
    self.redirectUrl = configuration[kQShareAppRedirectUrlKey];
}

- (BOOL)handleOpenURL:(NSURL *)url{
    return [WeiboSDK handleOpenURL:url delegate:self];
}

- (BOOL)isPlatformAppInstalled{
    return [WeiboSDK isWeiboAppInstalled];
}

- (BOOL)isRegistered{
    return isRegistered;
}

- (BOOL)isLoginEnabledOnPlatform{
    return [WeiboSDK isWeiboAppInstalled] && [WeiboSDK isCanSSOInWeiboApp];
}

#pragma mark - auth
- (void)loginToPlatform:(QShareCompletedBlock)completeBlock{
    self.block = completeBlock;
    
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = self.redirectUrl;
    request.scope = @"all";
    request.userInfo = @{@"request_from": @"auth"};
    request.shouldShowWebViewForAuthIfCannotSSO = YES;
    
    [WeiboSDK sendRequest:request];
}

- (void)handleWeiboAuthResp:(WBAuthorizeResponse *)response{
    NSString *token = [(WBAuthorizeResponse *)response accessToken];
    NSString *userID = [(WBAuthorizeResponse *)response userID];
    
    if (token && userID) {
        [self updateWeiboToken:token userId:userID];
        QUser *qUser = [[QUser alloc] init];
        qUser.uid = userID;
        qUser.accessToken = token;
        self.block(qUser,nil);
    }
}
- (void)updateWeiboToken:(NSString *)token userId:(NSString *)userId
{
    [[NSUserDefaults standardUserDefaults] setObject:userId forKey:kWeiboUserIdKey];
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:kWeiboTokenKey];
}
- (void)getPlatformUserInfo:(QShareCompletedBlock)completeBlock{
    self.block = completeBlock;
    NSString *userId = [[NSUserDefaults standardUserDefaults] stringForKey:kWeiboUserIdKey];
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] stringForKey:kWeiboTokenKey];
    [WBHttpRequest requestForUserProfile:userId
                         withAccessToken:accessToken
                      andOtherProperties:nil
                                   queue:nil
                   withCompletionHandler:^(WBHttpRequest *httpRequest,  WeiboUser *user, NSError *error) {
                       QUser *qUser = nil;
                       if (user.userID)
                       {
                           qUser = [[QUser alloc] init];
                           qUser.uid = user.userID;
                           qUser.nick = user.screenName;
                           qUser.avatar = user.avatarHDUrl;
                           qUser.gender = [user.gender isEqualToString:@"m"] ?  @"1" : @"0";
                           qUser.provider = @"weibo";
                           qUser.accessToken = accessToken;
                           qUser.rawData = user.originParaDict;
                       }
                       
                       if (completeBlock)
                       {
                           completeBlock(qUser, error);
                       }
                   }];
}

- (void)logoutFromPlatform{
    
}

#pragma mark share
- (void)share:(QMessage *)message completed:(QShareCompletedBlock)completedBlock{
    self.block = completedBlock;
    
    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = self.redirectUrl;
    authRequest.scope = @"all";
    authRequest.userInfo = @{@"request_from": @"share_auth"};
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] stringForKey:kWeiboTokenKey];
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:[message weiboMessage]
                                                                                  authInfo:authRequest
                                                                              access_token:accessToken];
    request.userInfo = @{@"request_from": @"share"};
    [WeiboSDK sendRequest:request];
}

- (void)handleWeiboShareResp:(WBSendMessageToWeiboResponse *)resp{
    
    if (resp.statusCode == WeiboSDKResponseStatusCodeSuccess) {
        
        self.block(@"分享成功",nil);
        
    }
}
#pragma mark - pay

#pragma mark - Weibo SDK Delegate
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request{
    
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response{
    if (!self.block) {
        return;
    }
    if (response.statusCode != WeiboSDKResponseStatusCodeSuccess) {
        
        NSError * error = [NSError errorWithDomain:kWeiboErrorDomain code:response.statusCode userInfo:@{NSLocalizedDescriptionKey:@"微博请求失败"}];
        self.block(nil, error);
        return;
    }
    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class]) {
        WBSendMessageToWeiboResponse *sendMessageToWeiboResponse = (WBSendMessageToWeiboResponse *)response;
        [self handleWeiboShareResp:sendMessageToWeiboResponse];
    } else if ([response isKindOfClass:WBAuthorizeResponse.class]) {
        [self handleWeiboAuthResp:(WBAuthorizeResponse *)response];
    } else if ([response isKindOfClass:WBPaymentResponse.class]) {
        
        
    }
}
@end
@implementation QTextMessage (Weibo)
- (WBMessageObject * __nonnull)weiboMessage
{
    WBMessageObject *weiboMessage = [WBMessageObject message];
    weiboMessage.text = self.text;
    
    return weiboMessage;
}
@end


@implementation QMediaMessage (Weibo)
- (WBMessageObject * __nonnull)weiboMessage;
{
    WBMessageObject *weiboMessage = [WBMessageObject message];
    weiboMessage.text = self.desc;
    if (self.thumbnailableImage)
    {
        WBImageObject *imageObject = [WBImageObject object];
        imageObject.imageData = UIImageJPEGRepresentation(self.thumbnailableImage, 0.75);
        weiboMessage.imageObject = imageObject;
    }
    
    return weiboMessage;
}
@end


@implementation QImageMessage (Weibo)
- (WBMessageObject * __nonnull)weiboMessage
{
    WBMessageObject *weiboMessage = [WBMessageObject message];
    weiboMessage.text = self.desc;
    if (self.imageData)
    {
        WBImageObject *imageObject = [WBImageObject object];
        imageObject.imageData = self.imageData;
        weiboMessage.imageObject = imageObject;
    }
    
    return weiboMessage;
}
@end


@implementation QAudioMessage (Weibo)
- (WBMessageObject * __nonnull)weiboMessage
{
    WBMessageObject *weiboMessage = [super weiboMessage];
    weiboMessage.text = [NSString stringWithFormat:@"%@ %@", weiboMessage.text, self.audioUrl];
    
    return weiboMessage;
}
@end


@implementation QVideoMessage (Weibo)
- (WBMessageObject * __nonnull)weiboMessage
{
    WBMessageObject *weiboMessage = [super weiboMessage];
    weiboMessage.text = [NSString stringWithFormat:@"%@ %@", weiboMessage.text, self.videoUrl];
    
    return weiboMessage;
}
@end


@implementation QPageMessage (Weibo)
- (WBMessageObject * __nonnull)weiboMessage
{
    WBMessageObject *weiboMessage = [super weiboMessage];
    weiboMessage.text = [NSString stringWithFormat:@"%@ %@", weiboMessage.text, self.webPageUrl];
    
    return weiboMessage;
}
@end