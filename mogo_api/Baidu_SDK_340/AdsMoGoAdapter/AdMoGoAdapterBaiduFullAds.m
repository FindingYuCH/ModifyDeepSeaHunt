//
//  AdMoGoAdapterBaiduFullAds.m
//  TestV1.3.1
//
//  Created by wang hao on 13-9-17.
//
//

#import "AdMoGoAdapterBaiduFullAds.h"
#import "AdMoGoAdSDKInterstitialNetworkRegistry.h"

typedef enum AdsMogoBaiduMobInterstitialState {
    AdsMogoBMobIState_INIT = 0,
    AdsMogoBMobIState_LOADSUC,
    AdsMogoBMobIState_LOADFAI,
    AdsMogoBMobIState_PRESENT,
    AdsMogoBMobIState_CLOSED
} AdsMogoBMobIState;

@interface AdMoGoAdapterBaiduFullAds()<UIGestureRecognizerDelegate>{
    AdsMogoBMobIState curState;
}

@property (nonatomic, copy) NSString *appid;

@end

@implementation AdMoGoAdapterBaiduFullAds

+ (AdMoGoAdNetworkType)networkType
{
    return AdMoGoAdNetworkTypeBaiduMobAd;
}

+ (void)load
{
    [[AdMoGoAdSDKInterstitialNetworkRegistry sharedRegistry] registerClass:self];
}

- (void)getAd
{
    isStop = NO;
    curState = AdsMogoBMobIState_INIT;
    baiduInterstitial = [[BaiduMobAdInterstitial alloc] init];
    
    //把在mssp.baidu.com上新建获得的广告位id设置到这里
    self.appid = [self getAppID:self.ration];
    NSString *adPlaceID = [self getAdPlaceID:self.ration];
    baiduInterstitial.AdUnitTag = adPlaceID;
    baiduInterstitial.delegate = self;
    baiduInterstitial.interstitialType = BaiduMobAdViewTypeInterstitialOther;
    [baiduInterstitial load];
    [self adapterDidStartRequestAd:self];
    
    id _timeInterval = [self.ration objectForKey:@"to"];
    if ([_timeInterval isKindOfClass:[NSNumber class]]) {
        timer = [NSTimer scheduledTimerWithTimeInterval:[_timeInterval doubleValue] target:self selector:@selector(loadAdTimeOut:) userInfo:nil repeats:NO];
    } else {
        timer = [NSTimer scheduledTimerWithTimeInterval:AdapterTimeOut15 target:self selector:@selector(loadAdTimeOut:) userInfo:nil repeats:NO] ;
    }
}

- (void)stopTimer
{
    @synchronized(self){
        if (timer) {
            [timer invalidate];
            timer = nil;
        }
    }
}

- (void)stopBeingDelegate
{
    isStop = YES;
    if(baiduInterstitial){
        baiduInterstitial.delegate = nil;
        [baiduInterstitial release],baiduInterstitial = nil;
    }
}

- (BOOL)isReadyPresentInterstitial
{
    return baiduInterstitial.isReady;
}

- (void)presentInterstitial
{
    curState = AdsMogoBMobIState_PRESENT;
    UIViewController *viewController = [self rootViewControllerForPresent];
    [baiduInterstitial presentFromRootViewController:viewController];
}

- (void)loadAdTimeOut:(NSTimer*)theTimer
{
    [super loadAdTimeOut:theTimer];
    [self stopTimer];
    [self stopBeingDelegate];
    [self failAd];
}

- (void)dealloc
{
    isStop = YES;
    self.appid = nil;
    
    [super dealloc];
}

- (void)failAd
{
    if (curState != AdsMogoBMobIState_INIT) {
        return;
    }
    baiduInterstitial.delegate = nil;
    curState = AdsMogoBMobIState_LOADFAI;
    
    [self adapter:self didFailAd:nil];
    
}

#pragma mark BaiduMobAdInterstitialDelegate
/**
 *  应用在mounion.baidu.com上的id
 */
- (NSString *)publisherId
{
    return self.appid;
}

/**
 *  广告预加载成功
 */
- (void)interstitialSuccessToLoadAd:(BaiduMobAdInterstitial *)_interstitial
{
    
    if (isStop) {
        return;
    }
    
    curState = AdsMogoBMobIState_LOADSUC;
    
    [self adapter:self didReceiveInterstitialScreenAd:nil];
    [self stopTimer];
}

/**
 *  广告预加载失败
 */
- (void)interstitialFailToLoadAd:(BaiduMobAdInterstitial *)_interstitial
{
    if (isStop) {
        return;
    }
    [self stopTimer];
    [self failAd];
}

/**
 *  广告即将展示
 */
- (void)interstitialWillPresentScreen:(BaiduMobAdInterstitial *)_interstitial
{
    if (isStop) {
        return;
    }
    [self adapter:self willPresent:baiduInterstitial];
}

/**
 *  广告展示成功
 */
- (void)interstitialSuccessPresentScreen:(BaiduMobAdInterstitial *)_interstitial
{
    if (isStop) {
        return;
    }
    [self adapter:self didShowAd:_interstitial];
}

/**
 *  广告展示失败
 */
- (void)interstitialFailPresentScreen:(BaiduMobAdInterstitial *)_interstitial withError:(BaiduMobFailReason) reason
{
    
    [self stopTimer];
    
    if (isStop) {
        return;
    }
    
    if (curState != AdsMogoBMobIState_INIT) {
        return;
    }
    [self failAd];
    
}

/**
 *  广告展示结束
 */
- (void)interstitialDidDismissScreen:(BaiduMobAdInterstitial *)_interstitial
{
    if (isStop) {
        return;
    }
    curState = AdsMogoBMobIState_CLOSED;
    [self adapter:self didDismissScreen:_interstitial];
}

- (void)interstitialDidAdClicked:(BaiduMobAdInterstitial *)interstitial
{
    [self specialSendRecordNum];
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
