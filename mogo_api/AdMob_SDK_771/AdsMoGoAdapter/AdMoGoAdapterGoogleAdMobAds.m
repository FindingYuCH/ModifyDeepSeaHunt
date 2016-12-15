//
//  File: AdMoGoAdapterGoogleAdMobAds.m
//  Project: AdsMOGO iOS SDK
//  Version: 1.1.9
//
//  Copyright 2011 AdsMogo.com. All rights reserved.
//

#import "AdMoGoAdapterGoogleAdMobAds.h"
#import "AdMoGoAdSDKBannerNetworkRegistry.h"
#import "AdMoGoConfigDataCenter.h"


@implementation AdMoGoAdapterGoogleAdMobAds

+ (AdMoGoAdNetworkType)networkType
{
    return AdMoGoAdNetworkTypeAdMob;
}

+ (void)load
{
    [[AdMoGoAdSDKBannerNetworkRegistry sharedRegistry] registerClass:self];
}


- (NSObject *)delegateValueForSelector:(SEL)selector
{
	return ([adMoGoDelegate respondsToSelector:selector]) ? [adMoGoDelegate performSelector:selector] : nil;
}

- (void)getAd
{
    isStop = NO;
    
    [adMoGoCore adDidStartRequestAd];
	GADRequest *request = [GADRequest request];
	NSObject *value;
    
    /*
     获取广告类型
     原来代码：AdViewType type = adMoGoView.adType;
     */
    AdMoGoConfigDataCenter *configDataCenter = [AdMoGoConfigDataCenter singleton];
    
    AdMoGoConfigData *configData = [configDataCenter.config_dict objectForKey:adMoGoCore.config_key];
    
	if ([configData islocationOn]) {
        CLLocation *location = (CLLocation *)[self delegateValueForSelector:@selector(locationInfo)];
        
        if (location == nil) {
            NSArray *location_ary = [configData.curLocation componentsSeparatedByString:@","];
            id latitude = [location_ary objectAtIndex:1];
            id longitude = [location_ary objectAtIndex:0];
            if (latitude && [latitude isKindOfClass:[NSString class]] && longitude && [longitude isKindOfClass:[NSString class]]) {
                if ([latitude intValue] == 0 && [longitude intValue] == 0) {
                    return;
                }
                
                location = [[[CLLocation alloc]
                             initWithLatitude:[latitude doubleValue]
                             longitude:[longitude doubleValue]] autorelease];
            }
        }
        
		[request setLocationWithLatitude:location.coordinate.latitude
							   longitude:location.coordinate.longitude
								accuracy:location.horizontalAccuracy];
	}
	
	NSString *string = (NSString *)[self delegateValueForSelector:@selector(gender)];
	
	if ([string isEqualToString:@"m"]) {
		request.gender = kGADGenderMale;
	} else if ([string isEqualToString:@"f"]) {
		request.gender = kGADGenderFemale;
	} else {
		request.gender = kGADGenderUnknown;
	}
	
	if ((value = [self delegateValueForSelector:@selector(dateOfBirth)])) {
		request.birthday = (NSDate *)value;
	}
	
	if ((value = [self delegateValueForSelector:@selector(keywords)])) {
		request.keywords = [NSMutableArray arrayWithArray:(NSArray *)value];
	}
    
    BOOL testMode = [[self.ration objectForKey:@"testmodel"] intValue];
    if (testMode) {
        request.testDevices = [NSArray arrayWithObjects:@"Simulator",nil];
    }
	
    AdViewType type = [configData.ad_type intValue];
    GADAdSize size = kGADAdSizeBanner;
    switch (type) {
        case AdViewTypeNormalBanner:
        case AdViewTypeiPadNormalBanner:
            size = kGADAdSizeBanner;
            break;
        case AdViewTypeRectangle:
        case AdViewTypeiPhoneRectangle:
            size = kGADAdSizeMediumRectangle;
            break;
        case AdViewTypeMediumBanner:
            size = kGADAdSizeFullBanner;
            break;
        case AdViewTypeLargeBanner:
            size = kGADAdSizeLeaderboard;
            break;
        default:
            [adMoGoCore adapter:self didGetAd:@"admob"];
            [adMoGoCore adapter:self didFailAd:nil];
            return;
            break;
    }

	GADBannerView *view = [[GADBannerView alloc] initWithAdSize:size];
	view.adUnitID = [self.ration objectForKey:@"key"];
	view.delegate = self;
	view.rootViewController = [adMoGoDelegate viewControllerForPresentingModalView];

    self.adNetworkView = view;
    [view release];
	[view loadRequest:request];
    
    id _timeInterval = [self.ration objectForKey:@"to"];
    if ([_timeInterval isKindOfClass:[NSNumber class]]) {
        timer = [[NSTimer scheduledTimerWithTimeInterval:[_timeInterval doubleValue] target:self selector:@selector(loadAdTimeOut:) userInfo:nil repeats:NO] retain];
    } else {
        timer = [[NSTimer scheduledTimerWithTimeInterval:AdapterTimeOut8 target:self selector:@selector(loadAdTimeOut:) userInfo:nil repeats:NO] retain];
    }
}

- (void)loadAdTimeOut:(NSTimer*)theTimer
{
    if (isStop) {
        return;
    }
    
    [super loadAdTimeOut:theTimer];
    
    [self stopTimer];
    [self stopBeingDelegate];
    [adMoGoCore adapter:self didFailAd:nil];
}

- (void)stopBeingDelegate
{
	GADBannerView *_adMobView = (GADBannerView *)self.adNetworkView;
    if (_adMobView != nil) {
        _adMobView.delegate = nil;
        _adMobView.rootViewController = nil;
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

- (void)stopAd
{
    isStop = YES;
    [self stopTimer];
}

- (void)dealloc
{
    [self stopTimer];
    [super dealloc];
}

#pragma mark Ad Request Lifecycle Notifications
- (void)adViewDidReceiveAd:(GADBannerView *)adView
{
    if (isStop) {
        return;
    }
    [self stopTimer];
    [adMoGoCore adapter:self didGetAd:@"admob"];
	[adMoGoCore adapter:self didReceiveAdView:adView];
}

- (void)adView:(GADBannerView *)adView didFailToReceiveAdWithError:(GADRequestError *)error
{
    MGLog(MGE,@"admob error-->%@",error);
    
    if (isStop) {
        return;
    }
    [self stopTimer];
    [adMoGoCore adapter:self didGetAd:@"admob"];
	[adMoGoCore adapter:self didFailAd:error];
}

#pragma mark Click-Time Lifecycle Notifications
- (void)adViewWillPresentScreen:(GADBannerView *)adView
{
    if (isStop) {
        return;
    }
    
    if ([adMoGoDelegate respondsToSelector:@selector(adMoGoWillPresentFullScreenModal)]) {
        [adMoGoDelegate adMoGoWillPresentFullScreenModal];
    }
}

- (void)adViewDidDismissScreen:(GADBannerView *)adView
{
    if (isStop) {
        return;
    }
    
    if ([adMoGoDelegate respondsToSelector:@selector(adMoGoDidDismissFullScreenModal)]) {
        [adMoGoDelegate adMoGoDidDismissFullScreenModal];
    }
}

@end