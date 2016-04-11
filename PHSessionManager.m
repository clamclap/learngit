//
//  PHSessionManager.m
//  p2p
//
//  Created by Philip on 9/18/15.
//  Copyright © 2015 PHSoft. All rights reserved.
//

#import "PHSessionManager.h"
#import <Bolts/Bolts.h>
#import "UIViewController+addition.h"
#import <BlocksKit/BlocksKit+UIKit.h>

NSString * const PHNotificationLoggedIn = @"PHNotificationLoggedIn";
NSString * const PHNotificationLoggedOut = @"PHNotificationLoggedOut";
NSString * const PHNotificationGoToHome = @"PHNotificationWebViewGoToHome";
NSString * const PHNotificationGoToWealthManager = @"PHNotificationGoToWealthManager";
NSString * const PHNotificationGoToActivity = @"PHNotificationGoToActivity";
NSString * const PHNotificationGoToMessage = @"PHNotificationGoToMessage";
NSString * const PHNotificationOpenMenu = @"PHNotificationOpenMenu";
NSString * const PHNotificationPopShareView = @"PHNotificationPopShareView";

@interface PHSessionManager()
@end

@implementation PHSessionManager

+ (instancetype)sharedInstance {
    static PHSessionManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [PHSessionManager new];
    });
    
    return instance;
}

-  (instancetype)init {
    if (self = [super init]) {
        _authKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"authKey"];
        [self addObserver:self forKeyPath:@"authKey" options:NSKeyValueObservingOptionNew context:nil];
    }
    
    return self;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"authKey"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"authKey"]) {
        if ([self isLoggedIn]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:PHNotificationLoggedIn object:nil];
        } else {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"authKey"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[NSNotificationCenter defaultCenter] postNotificationName:PHNotificationLoggedOut object:nil];
        }
    }
}

- (BFTask *)taskToPerformLogout {
    self.authKey = nil;
    return [BFTask taskWithResult:@YES];
}

- (NSURL *)baseURL{
    return [NSURL URLWithString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"PHBaseUrl"]];
}

- (NSURL *)URLWithChannelIDAndAuthKeyAndDestination:(NSString *)destination {
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    [params setObject:@"FHLSFH" forKey:@"channelKey"];
    
    if (self.authKey.length && self.isLoggedIn) {
        [params setObject:self.authKey forKey:@"authKey"];
    }
    
    if (destination.length) {
        [params setObject:destination forKey:@"destinationUrl"];
    }
    
    NSMutableArray *paramPairs = [NSMutableArray new];
    for (NSString *key in params.allKeys) {
        [paramPairs addObject:[NSString stringWithFormat:@"%@=%@", key, params[key]]];
    }
    
    NSString *paramString = [paramPairs componentsJoinedByString:@"&"];
    
    return [NSURL URLWithString:[self.baseURL.absoluteString stringByAppendingString:[NSString stringWithFormat:@"/transfer.do?%@", paramString]]];
}

- (BOOL)isLoggedIn {
    return (self.authKey.length);
}

- (NSURL *)loginURL
{
    return [self URLWithChannelIDAndAuthKeyAndDestination:@"toHfaxappLoginInit.do"];登录
}

- (NSURL *)registerURL
{
    return [self  URLWithChannelIDAndAuthKeyAndDestination:@"toHfaxappRegInit.do"];注册
}

- (NSURL *)rechargeURL
{
    return [self URLWithChannelIDAndAuthKeyAndDestination:@"rechargeBundInitChpy.do"];充值
}

- (NSURL *)withdrawURL
{
    return [self URLWithChannelIDAndAuthKeyAndDestination:@"withdrawH5AllinpayInit.do"];提现
}

- (NSURL *)bankCardManagerURL
{
    return [self URLWithChannelIDAndAuthKeyAndDestination:@"checkPassword.do"];
}

- (NSURL *)pincodeManagerURL
{
    return [self URLWithChannelIDAndAuthKeyAndDestination:@"toHfaxappPasswordManage.do"];密码管理
}

- (NSURL *)shareManagerURL
{
    return [self URLWithChannelIDAndAuthKeyAndDestination:@"toHfaxAppInviteFriend.do"];邀请好友
}

- (NSURL *)investCardManagerURL
{
    return [self URLWithChannelIDAndAuthKeyAndDestination:@"toHfaxappInvestCardManage.do"];投资劵
}

- (NSURL *)floatingAdvertiseURL
{
    return [self URLWithChannelIDAndAuthKeyAndDestination:@"toHfaxapploginAdvertisement.do"];首页
}

- (NSURL *)manageFinanceURL
{
    return [self URLWithChannelIDAndAuthKeyAndDestination:@"toHfaxAppFinaceIndex.do?hfax:tabShow"];理财页
}

- (NSURL *)activityURL
{
    return [self URLWithChannelIDAndAuthKeyAndDestination:@"toHfaxAppQueryActivity.do?hfax:tabShow"];活动
}

- (NSURL *)messageURL
{
    return [self URLWithChannelIDAndAuthKeyAndDestination:@"toHfaxAppQuerySysMessages.do?hfax:tabShow"];系统消息
}

- (NSURL *)homeURL
{
    return [self URLWithChannelIDAndAuthKeyAndDestination:@"queryRecommenList.do?hfax:tabShow"];首页1111
}

@end