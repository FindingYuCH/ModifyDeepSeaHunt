//
//  File: AdMoGoAdapterBaiduMobAd.m
//  Project: AdsMOGO iOS SDK
//  Version: 1.1.9
//
//  Copyright 2011 AdsMogo.com. All rights reserved.
//

#import "AdMoGoAdapterBaiduMobAd.h"
#import "AdMoGoAdNetworkRegistry.h"
#import "AdMoGoConfigDataCenter.h"

#define kAdMoGoBaiduAppIDKey @"AppID"
#define kAdMoGoBaiduAdPlaceID @"AdPlaceID"

@interface AdMoGoAdapterBaiduMobAd() <BaiduMobAdViewDelegate>

@property (nonatomic,copy) NSString *appid;
@property (nonatomic,retain) BaiduMobAdView *baiduBanner;

@end


@implementation AdMoGoAdapterBaiduMobAd

#pragma mark - AdNetworkAdapter method
+ (AdMoGoAdNetworkType)networkType
{
    return AdMoGoAdNetworkTypeBaiduMobAd;
}

+ (void)load
{
    [[AdMoGoAdSDKBannerNetworkRegistry sharedRegistry] registerClass:self];
}

- (id)initWithAdMoGoDelegate:(id<AdMoGoDelegate>)delegate view:(AdMoGoView *)view core:(AdMoGoCore *)core networkConfig:(NSDictionary *)netConf
{
    if (self = [super initWithAdMoGoDelegate:delegate view:view core:core networkConfig:netConf]) {
        self.appid = [self getAppID:self.ration];
        NSString *adPlaceID = [self getAdPlaceID:self.ration];
        
        self.baiduBanner = [[[BaiduMobAdView alloc] init] autorelease];
        //把在mssp.baidu.com上新建获得的广告位id设置到这里
        self.baiduBanner.AdUnitTag = ([adPlaceID length] == 0) ? @"" : adPlaceID;
        self.baiduBanner.delegate = self;
    }
    
    return self;
}

- (void)dealloc
{
    self.appid = nil;
    
    self.baiduBanner.delegate = nil;
    self.baiduBanner = nil;
    [self stopTimer];
    
    [super dealloc];
}

- (void)getAd
{
    isStop = NO;
    isLoad = NO;
    isShow = NO;
    [adMoGoCore adDidStartRequestAd];
    
    AdMoGoConfigDataCenter *configDataCenter = [AdMoGoConfigDataCenter singleton];
    AdMoGoConfigData *configData = [configDataCenter.config_dict objectForKey:adMoGoCore.config_key];
    AdViewType type = [configData.ad_type intValue];
    CGSize size = [self bannerSizeFromViewType:type];
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        [adMoGoCore adapter:self didFailAd:nil];
        return;
    }
    
    self.baiduBanner.frame = CGRectMake(0, 0, size.width, size.height);
    [self.baiduBanner start];
    
    id _timeInterval = [self.ration objectForKey:@"to"];
    double timeoutInterval = [_timeInterval isKindOfClass:[NSNumber class]] ? [_timeInterval doubleValue] : AdapterTimeOut8;
    timer = [[NSTimer scheduledTimerWithTimeInterval:timeoutInterval target:self selector:@selector(loadAdTimeOut:) userInfo:nil repeats:NO] retain];
}

- (void)stopAd
{
    isStop = true;
    [self stopTimer];
}

- (BOOL)isSDKSupportClickDelegate
{
    return YES;
}

- (void)stopBeingDelegate { }

- (void)loadAdTimeOut:(NSTimer *)theTimer
{
    if (isStop) {
        return;
    }
    
    [super loadAdTimeOut:theTimer];
    
    [self stopTimer];
    [self stopBeingDelegate];
    [adMoGoCore adapter:self didFailAd:nil];
}

#pragma mark - BaiduMobAdViewDelegate
/**
 *  应用的APPID
 */
- (NSString *)publisherId
{
    return self.appid;
}

- (void)willDisplayAd:(BaiduMobAdView *)adview { }

- (void)failedDisplayAd:(BaiduMobFailReason)reason
{
    if (isStop) {
        return;
    }
    
    [self stopTimer];
    [adMoGoCore adapter:self didFailAd:nil];
}

- (void)didAdImpressed
{
    if (isStop) {
        return;
    }
    if (!isLoad) {
        isLoad = YES;
    } else {
        return;
    }
    [adMoGoCore adapter:self didReceiveAdView:self.baiduBanner];
    [self stopTimer];
}

- (void)didAdClicked
{
    if (isStop) {
        return;
    }
    
    [adMoGoCore sdkplatformSendCLK:self];
}

#pragma mark - utility method

//百度返回的所有广告尺寸比例都是20:3的，他在枚举值中给出的矩形大小是没有的
- (CGSize)bannerSizeFromViewType:(AdViewType)type
{
    CGSize size = CGSizeZero;
    switch (type) {
        case AdViewTypeNormalBanner:
        case AdViewTypeiPadNormalBanner:
            size = kBaiduAdViewBanner320x48;
            break;
        case AdViewTypeMediumBanner:
            size = kBaiduAdViewBanner468x60;
            break;
        case AdViewTypeLargeBanner:
            size = kBaiduAdViewBanner728x90;
            break;
        default:
            break;
    }
    
    return size;
}

- (NSString *)getAdPlaceID:(NSDictionary *)key_dict
{
    NSDictionary *key = [key_dict objectForKey:@"key"];
    if (key == nil || ![key isKindOfClass:[NSDictionary class]])
        return nil;
    
    NSString *placeid = [key objectForKey:kAdMoGoBaiduAdPlaceID];
    if (placeid == nil || ![placeid isKindOfClass:[NSString class]])
        return nil;
    
    return placeid;
}

- (NSString *)getAppID:(NSDictionary *)key_dict
{
    NSDictionary *key = [key_dict objectForKey:@"key"];
    if (key == nil || ![key isKindOfClass:[NSDictionary class]])
        return nil;
    
    NSString *appid = [key objectForKey:kAdMoGoBaiduAppIDKey];
    if (appid == nil || ![appid isKindOfClass:[NSString class]])
        return nil;
    
    return appid;
}

- (void)stopTimer
{
    if (timer) {
        [timer invalidate];
        [timer release];
        timer = nil;
    }
}

@end