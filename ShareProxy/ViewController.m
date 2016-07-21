//
//  ViewController.m
//  ShareProxy
//
//  Created by 维农 on 16/7/18.
//  Copyright © 2016年 维农-quan. All rights reserved.
//

#import "ViewController.h"
#import "ShareHeader.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)qqLoginAction:(id)sender {

    [self loginWithType:kQShareTypeQQ];
}
- (IBAction)getqquserinfo:(id)sender {
    [self getuserinfoWithType:kQShareTypeQQ];
}

- (void)getuserinfoWithType:(NSString *)type{
    [[QShare sharedInstance] getPlatformUserInfoWithName:type complete:^(id  _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@",result);
    }];
}

- (void)loginWithType:(NSString *)type{
    [[QShare sharedInstance] loginToPlatformWithName:type complete:^(id  _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@",result);
    }];
}
- (IBAction)qqshareweb:(id)sender {
    [[QShare sharedInstance] share:[self generateWebPageMessage] name:kQShareTypeQQ completed:^(id  _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@",result);
    }];
}
- (IBAction)qqsharevideo:(id)sender {
    [[QShare sharedInstance] share:[self generateVideoMessage] name:kQShareTypeQQ completed:^(id  _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@",result);
    }];
}
- (IBAction)qqshareaudio:(id)sender {
    [[QShare sharedInstance] share:[self generateMusicMessage] name:kQShareTypeQQ completed:^(id  _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@",result);
    }];
}
- (IBAction)qqsharetext:(id)sender {
    [[QShare sharedInstance] share:[self generateTextMessage] name:kQShareTypeQQ completed:^(id  _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@",result);
    }];
}
- (IBAction)qqshareimage:(id)sender {
    [[QShare sharedInstance] share:[self generateImageMessage] name:kQShareTypeQQ completed:^(id  _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@",result);
    }];
}


- (IBAction)wblogin:(id)sender {
    [self loginWithType:kQShareTypeWeibo];
}

- (IBAction)getwbuserinfo:(id)sender {
    [self getuserinfoWithType:kQShareTypeWeibo];
}

- (IBAction)wbsharetext:(id)sender {
    [[QShare sharedInstance] share:[self generateTextMessage] name:kQShareTypeWeibo completed:^(id  _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@",result);
    }];
}

- (IBAction)wbsharepic:(id)sender {
    [[QShare sharedInstance] share:[self generateImageMessage] name:kQShareTypeWeibo completed:^(id  _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@",result);
    }];
}

- (IBAction)wbshareaudio:(id)sender {
    [[QShare sharedInstance] share:[self generateMusicMessage] name:kQShareTypeWeibo completed:^(id  _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@",result);
    }];
}

- (IBAction)wbsharevideo:(id)sender {
    [[QShare sharedInstance] share:[self generateVideoMessage] name:kQShareTypeWeibo completed:^(id  _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@",result);
    }];
}

- (IBAction)wbshareweb:(id)sender {
    [[QShare sharedInstance] share:[self generateWebPageMessage] name:kQShareTypeWeibo completed:^(id  _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@",result);
    }];
}




- (IBAction)loginwx:(id)sender {
    [self loginWithType:kQShareTypeWechat];
}

- (IBAction)getwxuserinfo:(id)sender {
    [[QShare sharedInstance] getPlatformUserInfoWithName:kQShareTypeWechat complete:^(id  _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@",result);
    }];
}

- (IBAction)wxsharetext:(id)sender {
    [[QShare sharedInstance] share:[self generateTextMessage] name:kQShareTypeWechat completed:^(id  _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@",result);
    }];
}


- (IBAction)wxsharepic:(id)sender {
    [[QShare sharedInstance] share:[self generateImageMessage] name:kQShareTypeWechat completed:^(id  _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@",result);
    }];
}
- (IBAction)wxshareaudio:(id)sender {
    [[QShare sharedInstance] share:[self generateMusicMessage] name:kQShareTypeWechat completed:^(id  _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@",result);
    }];
}
- (IBAction)wxsharevideo:(id)sender {
    [[QShare sharedInstance] share:[self generateVideoMessage] name:kQShareTypeWechat completed:^(id  _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@",result);
    }];
}

- (IBAction)wxshareweb:(id)sender {
    [[QShare sharedInstance] share:[self generateWebPageMessage] name:kQShareTypeWechat completed:^(id  _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@",result);
    }];
}
- (IBAction)alipay:(id)sender {
    NSString *string = @"_input_charset=utf-8&body=云南鹰嘴芒 49.8*1 49.8|&notify_url=https://api.wn517.com/vernonshop/alipay/callback&out_trade_no=20160721173856627110&partner=2088711090608345&payment_type=1&seller_id=2769459998@qq.com&service=mobile.securitypay.pay&subject=云南鹰嘴芒&total_fee=49.8&sign=eksSTop2iKQLDS1A6aYwbleMXiM7oFiSKH84YoUuD0jMtu0PgABpxW0wKIlu0mJfVrHBsF%2FSrEmg%2BfOVbBSJq9IFURAXCEPmoEQA1vkPI44EgYDj%2BP382NrOIwlZOGQWy3R4lObt41u1yLN9WjBJ3NKXnKKdRjU1wV%2FaH7v5DHA%3D&sign_type=RSA";
    [[QShare sharedInstance] payOrder:string name:kQShareTypeAli block:^(NSString * _Nullable signString, NSError * _Nullable error) {
        
    }];
    
}

- (IBAction)wxpay:(id)sender {
    NSDictionary * dict = @{@"sign": @"54ABCDC9F30C3C29013206CBB7127B08",
                            @"appId": @"wxa41e061dee0cad3b",
                            @"timeStamp": @"1469091539",
                            @"prepayid": @"wx201607211659005d9d66fe160925140891",
                            @"packageValue": @"Sign=WXPay",
                            @"partnerId": @"1261632901",
                            @"nonceStr": @"c5ab0bc60ac7929182aadd08703f1ec6"
                            
                            };
    [[QShare sharedInstance] payOrder:dict name:kQShareTypeWechat block:^(NSString * _Nullable signString, NSError * _Nullable error) {
        NSLog(@"%@",signString);
    }];
}


- (QMessage *)generateTextMessage
{
    QTextMessage *message = [[QTextMessage alloc] init];
    message.text = @"随便发点文字测试发送!";
    message.userInfo = @{kWechatSceneTypeKey: @(WeChatSceneTimeline), kTencentQQSceneTypeKey: @(TencentSceneQZone)};
    
    return message;
}

- (QMessage *)generateImageMessage
{
    QImageMessage *message = [[QImageMessage alloc] init];
    message.title = @"看看看看";
    message.desc = @"美女不会看你的";
    message.shareImage = [UIImage imageNamed:@"IMG_0965.jpg"];
    message.imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"rwe.jpg"], 0.75);
    message.thumbnailableImage = [UIImage imageNamed:@"rwe.jpg"];
    message.userInfo = @{kWechatSceneTypeKey: @(WeChatSceneSession), kTencentQQSceneTypeKey: @(TencentSceneQZone)};
    
    return message;
}

- (QMessage *)generateMusicMessage
{
    QAudioMessage *message = [[QAudioMessage alloc] init];
    message.messageId = @"123123123432";
    message.title = @"购买成功";
    message.desc = @"晚上打开空调，放一首舒缓的歌，洗头洗澡全身擦干放松，涂上味道令人愉快的身体乳，然后一头扎进洗晒得干净又蓬松的被窝里，就仿佛拥有了整个世界。";
    message.audioUrl = @"http://www.5tps.com/down/19542_52_1_1.html";
    message.audioDataUrl = @"http://163j-d.ysx8.net:8000/%E7%8E%84%E5%B9%BB%E5%B0%8F%E8%AF%B4/%E6%88%91%E6%98%AF%E5%A4%A9%E6%89%8D/%E7%AC%AC01%E7%AB%A0_%E6%88%91%E6%98%AF%E8%B0%81.mp3?17102539962721x1469092575x17102852575475-03346228792821721221?2";
    message.thumbnailableImage = [UIImage imageNamed:@"rwe.jpg"];
    message.userInfo = @{kWechatSceneTypeKey: @(WeChatSceneSession), kTencentQQSceneTypeKey: @(TencentSceneQZone)};
    
    return message;
}

- (QMessage *)generateVideoMessage
{
    QVideoMessage *message = [[QVideoMessage alloc] init];
    message.messageId = @"43554y7468fghwr";
    message.title = @"终极一班4：第27集";
    message.desc = @"铁时空的大战仍未止息，为了保护雷婷，大东委托东城卫首席战斗团团长修带着她先行回到金时空，自己与夏天并肩作战对抗魔界大军，雷婷万般不舍地离开大东。没想到修和雷婷在回金时空的路上却意外遇伏击分散，雷婷失踪！而此时终极一班群龙无首，辜战与止戈两兄弟为了当老大展开比武对决。修找到了终极一班，雷婷失踪引发了轩然大波，经过众人努力终于找到雷婷，让她重回老大位置。却发现她性情大变，原来这一切都是一场骗局……";
    message.videoUrl = @"http://v.youku.com/v_show/id_XMTY0NDk1MTU0OA==.html";
    message.videoDataUrl = @"http://player.youku.com/player.php/Type/Folder/Fid/27456198/Ob/1/sid/XMTY0NDk1MTU0OA==/v.swf";
    message.thumbnailableImage = [UIImage imageNamed:@"rwe.jpg"];
    message.userInfo = @{kWechatSceneTypeKey: @(WeChatSceneSession), kTencentQQSceneTypeKey: @(TencentSceneQZone)};
    return message;
}

- (QMessage *)generateWebPageMessage
{
    QPageMessage *message = [[QPageMessage alloc] init];
    message.title = @"对于知乎新人你们有什么好的建议";
    message.desc = @"我是一个知乎的新用户，各位大大们有什么好的关注话题推荐一下，或者一些好的建议，或者您认为有用的东西，都推荐一下。";
    message.webPageUrl = @"https://www.zhihu.com/question/30294504#answer-40379186";
    message.thumbnailableImage = [UIImage imageNamed:@"rwe.jpg"];
    message.userInfo = @{ kWechatSceneTypeKey: @(WeChatSceneSession),  kTencentQQSceneTypeKey: @(TencentSceneQZone)};
    
    return message;
}

@end
