//
//  QShare.m
//  ShareProxy
//
//  Created by 维农 on 16/7/18.
//  Copyright © 2016年 维农-quan. All rights reserved.
//

#import "QShare.h"

NSString * __nonnull const kQShareAppIdKey = @"qshare_app_id";
NSString * __nonnull const kQShareAppSecretKey = @"qshare_app_secret";
NSString * __nonnull const kQShareAppSchemeKey = @"qshare_app_scheme";
NSString * __nonnull const kQShareAppRedirectUrlKey = @"qshare_app_redirect_url";
NSString * __nonnull const kQShareAppDebugModeKey = @"qshare_app_debug_mode";

@interface QShare ()

@property (strong, nonatomic) NSMutableDictionary * proxyObjects;
@property (copy, nonatomic) NSString *errorDomain;
@end

@implementation QShare
+ (instancetype)sharedInstance{
    static QShare * _qShare = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _qShare = [[QShare alloc] init];
    });
    return _qShare;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.proxyObjects = [NSMutableDictionary dictionary];
        self.errorDomain = [NSString stringWithFormat:@"%@.error",[[NSBundle mainBundle] bundleIdentifier]];
    }
    return self;
}

- (void)registerProxyObject:(id<QRegisterProxyProtocol>)object withName:(NSString *)name{
    self.proxyObjects[name] = object;
}

- (id __nullable)proxyForName:(NSString *)name{
    return [self.proxyObjects objectForKey:name];
}

- (void)registerWithConfigurations:(NSDictionary * __nonnull)configurations{
    [configurations enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        id<QRegisterProxyProtocol> proxy = [self proxyForName:key];
        [proxy registerWithConfiguration:obj];
    }];
}

- (BOOL)isInstalled:(NSString *)name{
    id<QRegisterProxyProtocol> proxy = [self proxyForName:name];
    return [proxy isPlatformAppInstalled];
}

- (BOOL)handleOpenURL:(NSURL *)url{
    BOOL success = NO;
    for (id<QRegisterProxyProtocol> proxy in self.proxyObjects.allValues) {
        success = success || [proxy handleOpenURL:url];
    }
    return success;
}

- (void)loginToPlatformWithName:(NSString *)name complete:(QShareCompletedBlock)completedBlock{
    id<QAuthProxyProtocol> proxy = [self proxyForName:name];
    if (proxy && [proxy conformsToProtocol:@protocol(QAuthProxyProtocol)]) {
        [proxy loginToPlatform:completedBlock];
    }else{
        if (completedBlock) {
            completedBlock(nil,[NSError errorWithDomain:self.errorDomain code:kQShareErrorCodeNotFound userInfo:@{NSLocalizedDescriptionKey:@"未知应用"}]);
        }
    }
}

- (void)getPlatformUserInfoWithName:(NSString *)name complete:(QShareCompletedBlock)completedBlock{
    id<QAuthProxyProtocol> proxy = [self proxyForName:name];
    if (proxy && [proxy conformsToProtocol:@protocol(QAuthProxyProtocol)]) {
        [proxy getPlatformUserInfo:completedBlock];
    }else{
        if (completedBlock) {
            completedBlock(nil,[NSError errorWithDomain:self.errorDomain code:kQShareErrorCodeNotFound userInfo:@{NSLocalizedDescriptionKey:@"未知应用"}]);
        }
    }
}

- (void)logoutFromPlatform{
    [self.proxyObjects enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id<QAuthProxyProtocol>  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj conformsToProtocol:@protocol(QAuthProxyProtocol)]) {
            [obj logoutFromPlatform];
        }
    }];
}

- (void)share:(QMessage *)message name:(NSString *)name completed:(QShareCompletedBlock)completedBlock{
    id<QShareProxyProtocol> proxy = [self proxyForName:name];
    if (proxy && [proxy conformsToProtocol:@protocol(QShareProxyProtocol)]) {
        [proxy share:message completed:completedBlock];
    }else{
        if (completedBlock) {
            completedBlock(nil,[NSError errorWithDomain:self.errorDomain code:kQShareErrorCodeNotFound userInfo:@{NSLocalizedDescriptionKey:@"未知应用"}]);
        }
    }
}

- (void)payOrder:(id)orderEntity name:(NSString *)name block:(QPayBlock)payBlock{
    id<QPayProxyProtocol> proxy = [self proxyForName:name];
    if (proxy && [proxy conformsToProtocol:@protocol(QPayProxyProtocol)]) {
        [proxy payOrder:orderEntity block:payBlock];
    }else{
        if (payBlock) {
            payBlock(nil,[NSError errorWithDomain:self.errorDomain code:kQShareErrorCodeNotFound userInfo:@{NSLocalizedDescriptionKey:@"未知应用"}]);
        }
    }
}
@end

#pragma mark - User
@implementation QUser
- (NSString *)description{
    return [NSString stringWithFormat:@"uid: %@ \n nick: %@ \n avatar: %@ \n gender: %@ \n provider: %@", self.uid, self.nick, self.avatar, self.gender, self.provider];
}
@end

#pragma mark - Message
@implementation QMessage
- (NSString *)description
{
    return @"No custom property.";
}
@end

@implementation QTextMessage
- (NSString *)description
{
    return [NSString stringWithFormat:@"text: %@ \n", self.text];
}
@end

@implementation QMediaMessage
- (NSString *)description
{
    return [NSString stringWithFormat:@"message Id: %@ \n title: %@ \n desc: %@ \n thumb data: %@ \n", self.messageId, self.title, self.desc, self.thumbnailableImage];
}
@end

@implementation QImageMessage
- (NSString *)description
{
    return [[super description] stringByAppendingFormat:@"image data: %@ \n", self.imageData];
}
@end

@implementation QAudioMessage
- (NSString *)description
{
    return [[super description] stringByAppendingFormat:@"audio url: %@ \n audio data url: %@ \n", self.audioUrl, self.audioDataUrl];
}
@end

@implementation QVideoMessage
- (NSString *)description
{
    return [[super description] stringByAppendingFormat:@"video url: %@ \n video data url: %@ \n", self.videoUrl, self.videoDataUrl];
}
@end


@implementation QPageMessage
- (NSString *)description
{
    return [[super description] stringByAppendingFormat:@"web page url: %@", self.webPageUrl];
}

@end
