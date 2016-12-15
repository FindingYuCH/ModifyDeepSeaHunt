//
//  AdMoGoAdapterInmobiSDKFullScreen.m
//  TestMOGOSDKAPP
//
//  Created by Daxiong on 12-11-21.
//
//

#import "AdMoGoAdapterInmobiSDKFullScreen.h"
#import "AdMoGoAdNetworkRegistry.h"
#import "AdMoGoConfigDataCenter.h"

@implementation AdMoGoAdapterInmobiSDKFullScreen

+ (AdMoGoAdNetworkType)networkType
{
    return AdMoGoAdNetworkTypeInMobi;
}

+ (void)load
{
	[[AdMoGoAdSDKInterstitialNetworkRegistry sharedRegistry] registerClass:self];
}

- (void)getAd
{
    isStop = NO;
    isReady = NO;
    canRemove = YES;

    AdMoGoConfigDataCenter *configDataCenter = [AdMoGoConfigDataCenter singleton];
    AdMoGoConfigData *configData = [configDataCenter.config_dict objectForKey:[self getConfigKey]];
    AdViewType type =[configData.ad_type intValue];

	if (type == AdViewTypeFullScreen || type == AdViewTypeiPadFullScreen) {
        NSString *accountId = [[self.ration objectForKey:@"key"] objectForKey:@"ACCOUNT_ID"];
        long long placementId = [[[self.ration objectForKey:@"key"] objectForKey:@"PLACEMENT_ID"] longLongValue];
        [IMSdk setLogLevel:kIMSDKLogLevelNone];
        [IMSdk initWithAccountID:accountId];
        
        interstitialAd = [[IMInterstitial alloc] initWithPlacementId:placementId delegate:self];
        [interstitialAd load];
        [self adapterDidStartRequestAd:self];
        
        id _timeInterval = [self.ration objectForKey:@"to"];
        if ([_timeInterval isKindOfClass:[NSNumber class]]) {
            timer = [[NSTimer scheduledTimerWithTimeInterval:[_timeInterval doubleValue] target:self selector:@selector(loadAdTimeOut:) userInfo:nil repeats:NO] retain];
        } else {
            timer = [[NSTimer scheduledTimerWithTimeInterval:AdapterTimeOut15 target:self selector:@selector(loadAdTimeOut:) userInfo:nil repeats:NO] retain];
        }
    } else {
        [self adapter:self didFailAd:nil];
    }
}

- (void)stopAd
{
    [self stopBeingDelegate];
    isStop = YES;
}

- (void)stopBeingDelegate
{
    if (interstitialAd && canRemove) {
        MGLog(MGT,@"%s",__FUNCTION__);
        interstitialAd.delegate = nil;
        [interstitialAd release],interstitialAd = nil;
    }
}

- (void)dealloc
{
    if (interstitialAd && canRemove) {
        interstitialAd.delegate = nil;
        [interstitialAd release],interstitialAd = nil;
    }
    
    [super dealloc];
}

- (void)stopTimer
{
    if (timer) {
        [timer invalidate];
        [timer release];
        timer = nil;
    }
}

- (void)loadAdTimeOut:(NSTimer*)theTimer
{
    MGLog(MGD,@"inmobi插屏广告请求超时");
    if (isStop) {
        return;
    }
    
    [self stopTimer];
    [self stopBeingDelegate];
    [self adapter:self didFailAd:nil];
}


- (BOOL)isReadyPresentInterstitial
{
    return isReady;
}

- (void)presentInterstitial
{
    // 呈现插屏广告
    if (interstitialAd.isReady) {
        [interstitialAd showFromViewController:[adMoGoDelegate viewControllerForPresentingModalView]];
    } else {
        MGLog(MGT,@"%s ad is not ready",__FUNCTION__);
        MGLog(MGD,@"inmobi插屏广告还没有准备好");
    }
}

#pragma mark - Inmobi delegate
- (void)interstitialDidFinishLoading:(IMInterstitial *)interstitial
{
    MGLog(MGD,@"inmobi插屏广告数据获取成功");
    if(isStop){
        return;
    }
    [self stopTimer];
    
    isReady = YES;
    [self adapter:self didReceiveInterstitialScreenAd:nil];
}

- (void)interstitial:(IMInterstitial*)interstitial didFailToLoadWithError:(IMRequestStatus *)error
{
    MGLog(MGE,@"inMobi error-->%@",error);
    MGLog(MGD,@"inmobi插屏广告数据获取失败");
    if (isStop) {
        return;
    }
    [self stopTimer];
    [self stopBeingDelegate];
    [self adapter:self didFailAd:error];

}

- (void)interstitialWillPresent:(IMInterstitial *)interstitial
{
    if (isStop) {
        return;
    }
    canRemove = NO;
    MGLog(MGD,@"inmobi插屏广告将要展示");
    [self adapter:self willPresent:interstitial];
}

- (void)interstitialDidPresent:(IMInterstitial *)interstitial
{
    MGLog(MGD,@"inmobi插屏广告已经展示");
    [self adapter:self didShowAd:interstitial];
}

-(void)interstitial:(IMInterstitial*)interstitial didFailToPresentWithError:(IMRequestStatus*)error
{
    MGLog(MGD,@"inmobi插屏广告展示失败");
    MGLog(MGT,@"%s",__FUNCTION__);
}

- (void)interstitialWillDismiss:(IMInterstitial *)interstitial
{
    MGLog(MGT,@"%s",__FUNCTION__);
    MGLog(MGD,@"inmobi插屏广告将要消失");
}

- (void)interstitialDidDismiss:(IMInterstitial *)interstitial
{
    if (isStop) {
        return;
    }
    canRemove = YES;
    MGLog(MGD,@"inmobi插屏广告已经消失");
    [self adapter:self didDismissScreen:interstitial];
}

-(void)userWillLeaveApplicationFromInterstitial:(IMInterstitial*)interstitial
{
    MGLog(MGD,@"inmobi插屏广告将要离开应用");
    MGLog(MGT,@"%s",__FUNCTION__);
}

- (void)interstitial:(IMInterstitial *)interstitial didInteractWithParams:(NSDictionary *)params
{
    MGLog(MGD,@"inmobi插屏广告被点击");
    MGLog(MGT,@"%s %@",__FUNCTION__,params);
    [self specialSendRecordNum];
}

-(void)interstitial:(IMInterstitial*)interstitial rewardActionCompletedWithRewards:(NSDictionary*)rewards { }

@end
