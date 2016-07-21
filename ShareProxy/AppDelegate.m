//
//  AppDelegate.m
//  ShareProxy
//
//  Created by 维农 on 16/7/18.
//  Copyright © 2016年 维农-quan. All rights reserved.
//

#import "AppDelegate.h"
#import "ShareHeader.h"
#import "KeyConstants.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self configShareSDK];
    
    return YES;
}

- (void)configShareSDK{
    
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
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(nonnull NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(nonnull id)annotation{
    return [[QShare sharedInstance] handleOpenURL:url];
}

@end
