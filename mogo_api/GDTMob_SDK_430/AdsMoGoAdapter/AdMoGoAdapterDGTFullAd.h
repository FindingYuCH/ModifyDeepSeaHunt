//
//  AdMoGoAdapterDGTFullAd.h
//  wanghaotest
//
//  Created by  Darren 2014-8-26
//
//
#import <Foundation/Foundation.h>
#import "AdMoGoAdNetworkInterstitialAdapter.h"
#import "GDTMobInterstitial.h"

@interface AdMoGoAdapterDGTFullAd : AdMoGoAdNetworkInterstitialAdapter<GDTMobInterstitialDelegate>{
    NSTimer *timer;
    BOOL isStop;
    GDTMobInterstitial *_interstitialObj;
    BOOL isReady;
    BOOL canRemove;
}

@end
