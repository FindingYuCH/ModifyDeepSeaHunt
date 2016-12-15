//
//  AdMoGoAdapterGDTSplash.m
//  AdsMoGoSample
//
//  Created by GaoBin on 16/3/9.
//  Copyright © 2016年 MOGO. All rights reserved.
//

#import "AdMoGoAdapterGDTSplash.h"
#import "GDTSplashAd.h"

@interface AdMoGoAdapterGDTSplash() <GDTSplashAdDelegate>
{
    BOOL isSuccess;
    BOOL isFail;
}

@property (nonatomic, retain) GDTSplashAd *splash;
@property (nonatomic, retain) NSTimer *timer;

@end

@implementation AdMoGoAdapterGDTSplash

+ (AdMoGoAdNetworkType)networkType
{
    return AdMoGoAdNetworkTypeGDTMob;
}

+ (void)load
{
    [[AdMoGoAdSDKSplashNetworkRegistry sharedRegistry] registerClass:self];
}

- (void)getAd
{
    isFail = NO;
    isSuccess = NO;
    
    NSString *appid = [[self.ration objectForKey:@"key"] objectForKey:@"appid"];
    NSString *pid = [[self.ration objectForKey:@"key"] objectForKey:@"pid"];
    self.splash = [[[GDTSplashAd alloc] initWithAppkey:appid placementId:pid] autorelease];
    self.splash.delegate = self;
    [self.splash loadAdAndShowInWindow:[splashAds getWindow]];
    [self.splashAds adapterDidStartRequestSplashAd:self];
    
    id _timeInterval = [self.ration objectForKey:@"to"];
    if ([_timeInterval isKindOfClass:[NSNumber class]]) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:[_timeInterval doubleValue] target:self selector:@selector(loadAdTimeOut:) userInfo:nil repeats:NO];
    } else {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:AdapterTimeOut5 target:self selector:@selector(loadAdTimeOut:) userInfo:nil repeats:NO];
    }
}

- (void)stopTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)stopBeingDelegate
{
    self.splash.delegate = nil;
    self.splash = nil;
}

- (void)loadAdTimeOut:(NSTimer *)theTimer
{
    [super loadAdTimeOut:theTimer];
    
    self.timer = nil;
    [self stopBeingDelegate];
    [self adFailWith:nil];
}

- (void)dealloc
{
    self.splash.delegate = nil;
    self.splash = nil;
    self.timer = nil;
    
    [super dealloc];
}

#pragma mark - GDTSplashAdDelegate
- (void)splashAdSuccessPresentScreen:(GDTSplashAd *)splashAd
{
    [self stopTimer];
    [self adSuccess:self.splash];
}

- (void)splashAdFailToPresent:(GDTSplashAd *)splashAd withError:(NSError *)error
{
    [self stopTimer];
    [self adFailWith:nil];
}

- (void)splashAdClicked:(GDTSplashAd *)splashAd
{
    [self.splashAds sendClickCountWithAdAdpter:self];
}

- (void)splashAdApplicationWillEnterBackground:(GDTSplashAd *)splashAd
{
    [self.splashAds adSplash:self didDismiss:self.splash];
}

- (void)splashAdClosed:(GDTSplashAd *)splashAd
{
    [self.splashAds adSplash:self didDismiss:self.splash];
}

- (void)splashAdWillPresentFullScreenModal:(GDTSplashAd *)splashAd {}

- (void)splashAdDidDismissFullScreenModal:(GDTSplashAd *)splashAd
{
    [self.splashAds adSplash:self didDismiss:self.splash];
}

- (void)adSuccess:(id) _awSplash
{
    if (isSuccess == isFail && isSuccess == NO) {
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

@end
