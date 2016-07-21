#QShare
 这个项目是根据 https://github.com/lingochamp/Diplomat 这个开源项目改造的，感谢写这个整合的大神。

#集成
QShare.h 
QShare.m
  这两个是算是管理各个第三方的容器。


##初始化:
```objc
[[QShare sharedInstance] registerWithConfigurations: @{
kQShareTypeWeibo: @{
kQShareAppIdKey: sinaAppKey,
kQShareAppRedirectUrlKey: sinaRedirectURI
},
kQShareTypeWechat: @{
kQShareAppIdKey: wxAppKey,
kQShareAppSecretKey: wxAppSecret,
},
kQShareTypeQQ: @{
kQShareAppIdKey: qqAppKey
},
kQShareTypeAli:@{
kQShareAppSchemeKey: alischeme
}
}];
```


##代理
@protocol QRegisterProxyProtocol <NSObject>  //注册的代理
@protocol QAuthProxyProtocol <NSObject>     //认证
@protocol QShareProxyProtocol <NSObject>     //分享
@protocol QPayProxyProtocol <NSObject>        //支付

理论上所有的第三方都要写注册代理，然后根据需要自己接入 认证或分享或支付代理

###用微信作为例子:
WXProxy.h
```objc
FOUNDATION_EXTERN NSString * const kQShareTypeWechat;
FOUNDATION_EXTERN NSString * const kWechatSceneTypeKey;//声明这个第三方需要的一些参数

    @interface WXProxy : NSObject <QRegisterProxyProtocol, QAuthProxyProtocol, QShareProxyProtocol,QPayProxyProtocol>//几个代理都加上，再重写各个方法，
    @end
```

WXProxy.m
```objc

+ (void)load{
[[QShare sharedInstance] registerProxyObject:[[WXProxy alloc] init] withName:kQShareTypeWechat];
}//初始化，在load保证各个第三方可以创建在容器中。
```

