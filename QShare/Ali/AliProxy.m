//
//  AliProxy.m
//  ShareProxy
//
//  Created by 维农 on 16/7/21.
//  Copyright © 2016年 维农-quan. All rights reserved.
//

#import "AliProxy.h"
#import <AlipaySDK/AlipaySDK.h>

static NSString * const kAliErrorDomain = @"alipay_error_domain";

NSString * __nonnull const kQShareTypeAli = @"kQShare_Ali";

@interface AliProxy ()
@property (copy, nonatomic) NSString *aliPayScheme;
@end

@implementation AliProxy

+ (void)load{
    [[QShare sharedInstance] registerProxyObject:[[AliProxy alloc] init]  withName:kQShareTypeAli];
}

#pragma mark - reg
- (void)registerWithConfiguration:(NSDictionary *)configuration{
    if (configuration&&configuration.allKeys.count) {
        NSString *appScheme = configuration[kQShareAppSchemeKey];
        if (appScheme && appScheme.length) {
            self.aliPayScheme = appScheme;
        }
    }
}

- (BOOL)handleOpenURL:(NSURL *)url{
    if ([url.scheme.lowercaseString isEqualToString:self.aliPayScheme]) {
        [self payProcessOrderWithPaymentResult:url standbyBlock:^(NSDictionary * _Nullable dict, NSError * _Nullable error) {
            
        }];
        return YES;
    }else{
        return NO;
    }
}

- (BOOL)isRegistered{
    return self.aliPayScheme&&self.aliPayScheme.length;
}

- (BOOL)isPlatformAppInstalled{
    return YES;
}

- (BOOL)isLoginEnabledOnPlatform{
    return YES;
}

#pragma mark - pay
- (void)payOrder:(id)orderEntity block:(QPayBlock)payBlock{
    if (!payBlock) {
        return;
    }
    if (!self.aliPayScheme) {
        NSError * error = [NSError errorWithDomain:kAliErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey:@"需要配置支付宝支付的回调"}];
        payBlock(nil,error);
    }
    
    NSString * url = orderEntity;//需要确定这个是
    [[AlipaySDK defaultService] payOrder:url fromScheme:self.aliPayScheme callback:^(NSDictionary *resultDic) {
        NSLog(@"reslut = %@",resultDic);
        //        [win setHidden:YES];
        if ([[resultDic allKeys] containsObject:@"resultStatus"]) {
            int result = [resultDic[@"resultStatus"] intValue];
            
            if (payBlock) {
                if (result == 9000) {
                    result = 0;
                    NSString *resultMsg = @"支付成功";
                    payBlock(resultMsg,nil);
                    return ;
                }else if (result == 6001){
                    result = -2;
                }else{
                    result = -1;
                }
                NSError * error = [NSError errorWithDomain:kAliErrorDomain code:result userInfo:@{NSLocalizedDescriptionKey:@"支付失败"}];
                payBlock(nil,error);
            }
        }
    }];
}

- (BOOL)payProcessOrderWithPaymentResult:(NSURL *)url standbyBlock:(void (^)(NSDictionary * _Nullable, NSError * _Nullable))block{
    [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
        NSLog(@"result = %@",resultDic);
    }];
    return YES;
}

@end
