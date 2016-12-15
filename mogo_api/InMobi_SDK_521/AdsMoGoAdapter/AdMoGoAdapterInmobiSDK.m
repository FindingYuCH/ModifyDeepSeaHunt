//
//  AdMoGoAdapterInmobiSDK.m
//  TestMOGOSDKAPP
//
//  Created by Daxiong on 13-9-12.
//  Copyright (c) 2012年 AdsMogo. All rights reserved.
//


#import "AdMoGoAdapterInmobiSDK.h"
#import "AdMoGoAdNetworkRegistry.h"
#import "AdMoGoConfigDataCenter.h"

@implementation AdMoGoAdapterInmobiSDK

+ (AdMoGoAdNetworkType)networkType
{
    return AdMoGoAdNetworkTypeInMobi;
}

+ (void)load
{
	[[AdMoGoAdSDKBannerNetworkRegistry sharedRegistry] registerClass:self];
}

- (void)getAd
{
    isStop = NO;
    [adMoGoCore adDidStartRequestAd];
    AdMoGoConfigDataCenter *configDataCenter = [AdMoGoConfigDataCenter singleton];
    AdMoGoConfigData *configData = [configDataCenter.config_dict objectForKey:adMoGoCore.config_key];
    AdViewType type = [configData.ad_type intValue];
    CGRect rect = CGRectZero;

    switch (type) {
        case AdViewTypeiPadNormalBanner: 
        case AdViewTypeNormalBanner:
            rect = CGRectMake(0, 0, 320, 48);
            break;
        case AdViewTypeRectangle:
        case AdViewTypeiPhoneRectangle:
            rect = CGRectMake(0, 0, 300, 250);
            break;
        case AdViewTypeMediumBanner:
            rect = CGRectMake(0, 0, 468, 60);
            break;
        case AdViewTypeLargeBanner:
            rect = CGRectMake(0, 0, 728, 90);
            break;
        default:
            [adMoGoCore adapter:self didFailAd:nil];
            return;
            break;
    }

    
    NSString *accountId = [[self.ration objectForKey:@"key"] objectForKey:@"ACCOUNT_ID"];
    long long placementId = [[[self.ration objectForKey:@"key"] objectForKey:@"PLACEMENT_ID"] longLongValue];
    [IMSdk setLogLevel:kIMSDKLogLevelNone];
    [IMSdk initWithAccountID:accountId];
    IMBanner *inmobiAdView = [[[IMBanner alloc] initWithFrame:rect placementId:placementId delegate:self] autorelease];
    [inmobiAdView shouldAutoRefresh:NO];
    [inmobiAdView load];
    self.adNetworkView = inmobiAdView;

    id _timeInterval = [self.ration objectForKey:@"to"];
    if ([_timeInterval isKindOfClass:[NSNumber class]]) {
        timer = [[NSTimer scheduledTimerWithTimeInterval:[_timeInterval doubleValue] target:self selector:@selector(loadAdTimeOut:) userInfo:nil repeats:NO] retain];
    } else {
        timer = [[NSTimer scheduledTimerWithTimeInterval:AdapterTimeOut8 target:self selector:@selector(loadAdTimeOut:) userInfo:nil repeats:NO] retain];
    }
}

- (void)stopAd
{
    [self stopBeingDelegate];
    isStop = YES;
    [self stopTimer];
}

- (void)stopBeingDelegate
{
    if (self.adNetworkView && [self.adNetworkView isKindOfClass:[IMBanner class]]) {
        [(IMBanner *)self.adNetworkView setDelegate:nil];
    }
}

- (void)dealloc
{
    [super dealloc];
}

#pragma mark InMobiAdDelegate methods
- (void)bannerDidFinishLoading:(IMBanner *)banner
{
    if (isStop) {
        return;
    }
    MGLog(MGD,@"inMobi接收横幅广告数据获取成功");
    [self stopTimer];
    [adMoGoCore adapter:self didGetAd:@"inmobisdk"];
    [adMoGoCore adapter:self didReceiveAdView:self.adNetworkView];
}

- (void)banner:(IMBanner *)banner didFailToLoadWithError:(IMRequestStatus *)error
{
    if (isStop) {
        return;
    }
    MGLog(MGD,@"inMobi接收横幅广告数据失败");
    MGLog(MGE, @"inMobi error %@",error);
    [self stopTimer];
    [adMoGoCore adapter:self didFailAd:error];
    banner.delegate = nil;
}

- (void)banner:(IMBanner *)banner didInteractWithParams:(NSDictionary *)params
{
    MGLog(MGD,@"inMobi接收横幅广告被点击");
    MGLog(MGT,@"%s",__FUNCTION__);
}

- (void)bannerWillPresentScreen:(IMBanner *)banner
{
    MGLog(MGD,@"inMobi接收横幅广告将要展示");
}

- (void)bannerDidPresentScreen:(IMBanner*)banner { }

- (void)bannerWillDismissScreen:(IMBanner *)banner
{
    MGLog(MGD,@"inMobi接收横幅广告将要消失");
    MGLog(MGT,@"%s",__FUNCTION__);
}

- (void)bannerDidDismissScreen:(IMBanner *)banner
{
    MGLog(MGD,@"inMobi接收横幅广告已经消失");
}

- (void)userWillLeaveApplicationFromBanner:(IMBanner*)banner
{
    MGLog(MGD,@"inMobi接收横幅广告将要离开应用");
    MGLog(MGT,@"%s",__FUNCTION__);
}

-(void)banner:(IMBanner*)banner rewardActionCompletedWithRewards:(NSDictionary*)rewards { }

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
    MGLog(MGD,@"inMobi接收横幅广告超时");
    
    if (isStop) {
        return;
    }
    
    [self stopTimer];
    if (self.adNetworkView && [self.adNetworkView isKindOfClass:[IMBanner class]]) {
        [(IMBanner *)self.adNetworkView setDelegate:nil];
    }
    
    [adMoGoCore adapter:self didFailAd:nil];
}
@end
