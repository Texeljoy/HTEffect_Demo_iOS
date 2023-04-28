//
//  AppDelegate.m
//  HTEffectDemoiOS
//
//  Created by Paul on 2019/8/23.
//  Copyright © 2020 Tillusory Tech. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import <HTEffect/HTEffect.h>

NSString *isSDKInit = @"未初始化";

@interface AppDelegate ()<HTEffectDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[HomeViewController alloc] init]];
    [self.window makeKeyAndVisible];
//    #error----在线鉴权密钥
    [[HTEffect shareInstance] initHTEffect:@"Your AppId" withDelegate:self];
    return YES;
}

- (void)onInitFailure {
    isSDKInit = @"初始化失败";
}

- (void)onInitSuccess {
    isSDKInit = @"初始化成功";
}

@end
