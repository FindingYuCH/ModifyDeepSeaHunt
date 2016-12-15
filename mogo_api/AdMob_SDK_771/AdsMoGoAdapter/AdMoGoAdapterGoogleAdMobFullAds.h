//
//  AdMoGoAdapterGoogleAdMobFullAds.h
//  TestMOGOSDKAPP
//
//  Created by 孟令之 on 12-12-3.
//
//

#import "AdMoGoAdNetworkInterstitialAdapter.h"
#import <GoogleMobileAds/GADInterstitial.h>
#import <GoogleMobileAds/GADInterstitialDelegate.h>
#import "AdMoGoAdNetworkAdapter.h"

@interface AdMoGoAdapterGoogleAdMobFullAds : AdMoGoAdNetworkInterstitialAdapter<GADInterstitialDelegate>{
    GADInterstitial *gadinterstitial;
    BOOL isStop;
    NSTimer *timer;
    BOOL isReady;
}

+ (AdMoGoAdNetworkType)networkType;
@end
