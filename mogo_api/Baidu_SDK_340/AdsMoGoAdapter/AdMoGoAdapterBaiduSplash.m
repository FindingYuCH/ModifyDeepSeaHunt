//
//  AdMoGoAdapterBaiduSplash.m
//  wanghaotest
//
//  Created by mogo on 13-11-15.
//
//

#import "AdMoGoAdapterBaiduSplash.h"
#import "AdMoGoAdNetworkRegistry.h"

@interface AdMoGoAdapterBaiduSplash()

@property (nonatomic, copy) NSString *appid;

@end

@implementation AdMoGoAdapterBaiduSplash

+ (AdMoGoAdNetworkType)networkType
{
    return AdMoGoAdNetworkTypeBaiduMobAd;
}

+ (void)load
{
    [[AdMoGoAdSDKSplashNetworkRegistry sharedRegistry] registerClass:self];
}


- (void)getAd
{
    isFail = NO;
    isSuccess = NO;
    splash = [[BaiduMobAdSplash alloc] init];
    splash.delegate = self;

    //把在mssp.baidu.com上新建获得的广告位id设置到这里
    self.appid = [self getAppID:self.ration];
    NSString *adPlaceID = [self getAdPlaceID:self.ration];
    splash.AdUnitTag = adPlaceID;
    splash.canSplashClick = YES;
    [splash loadAndDisplayUsingKeyWindow:[splashAds getWindow]];
    
    id _timeInterval = [self.ration objectForKey:@"to"];
    if ([_timeInterval isKindOfClass:[NSNumber class]]) {
        timer = [[NSTimer scheduledTimerWithTimeInterval:[_timeInterval doubleValue] target:self selector:@selector(loadAdTimeOut:) userInfo:nil repeats:NO] retain];
    } else {
        timer = [[NSTimer scheduledTimerWithTimeInterval:AdapterTimeOut5 target:self selector:@selector(loadAdTimeOut:) userInfo:nil repeats:NO] retain];
    }
}

- (void)stopTimer
{
    if (timer) {
        [timer invalidate];
        [timer release];
        timer = nil;
    }
}

- (void)stopBeingDelegate
{
    if(splash){
        splash.delegate = nil;
        [splash release],splash = nil;
    }
}

- (void)loadAdTimeOut:(NSTimer*)theTimer
{
    [super loadAdTimeOut:theTimer];
    
    if (timer) {
        [timer invalidate];
        [timer release];
        timer = nil;
    }
    [self stopBeingDelegate];
    [self adFailWith:nil];
}

- (void)dealloc
{
    self.appid = nil;
    
    [super dealloc];
}

#pragma mark BaiduMobAdInterstitialDelegate
/**
 *  应用在union.baidu.com上的APPID
 */
- (NSString *)publisherId
{
    return self.appid;
}

/**
 *  广告展示成功
 */
- (void)splashSuccessPresentScreen:(BaiduMobAdSplash *)splash
{
    [self stopTimer];
    [self adSuccess:splash];
}

/**
 *  广告展示失败
 */
- (void)splashlFailPresentScreen:(BaiduMobAdSplash *)splash withError:(BaiduMobFailReason) reason
{
    [self stopTimer];
    [self adFailWith:nil];
}

/**
 *  广告展示结束
 */
- (void)splashDidDismissScreen:(BaiduMobAdSplash *)splash
{
    [self.splashAds adSplash:self didDismiss:splash];
}

- (void)adSuccess:(id) _awSplash
{
    if (isSuccess==isFail && isSuccess == NO) {
        isSuccess = YES;
        [self.splashAds adSplashSuccess:self withSplash:_awSplash];
    }
}

- (void)adFailWith:(NSError *)error
{
    if (isSuccess==isFail && isFail == NO) {
        isFail = YES;
        [self.splashAds adSplashFail:self withError:error];
    }
}

#pragma mark utility method
- (NSString *)getAdPlaceID:(NSDictionary *)key_dict
{
    NSDictionary *key = [key_dict objectForKey:@"key"];
    if (key == nil || ![key isKindOfClass:[NSDictionary class]])
        return nil;
    
    NSString *placeid = [key objectForKey:@"AdPlaceID"];
    if (placeid == nil || ![placeid isKindOfClass:[NSString class]])
        return nil;
    
    return placeid;
}

- (NSString *)getAppID:(NSDictionary *)key_dict
{
    NSDictionary *key = [key_dict objectForKey:@"key"];
    if (key == nil || ![key isKindOfClass:[NSDictionary class]])
        return nil;
    
    NSString *appid = [key objectForKey:@"AppID"];
    if (appid == nil || ![appid isKindOfClass:[NSString class]])
        return nil;
    
    return appid;
}

@end
