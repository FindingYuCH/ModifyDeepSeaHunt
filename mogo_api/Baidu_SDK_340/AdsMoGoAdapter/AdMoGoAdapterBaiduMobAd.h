//
//  File: AdMoGoAdapterBaiduMobAd.h
//  Project: AdsMOGO iOS SDK
//  Version: 1.1.9
//
//  Copyright 2011 AdsMogo.com. All rights reserved.
//Baidu v2.0

#import "AdMoGoAdNetworkAdapter.h"
#import "BaiduMobAdView.h"

@interface AdMoGoAdapterBaiduMobAd : AdMoGoAdNetworkAdapter {
    NSTimer *timer;
    BOOL isStop;
    BOOL isLoad;
    BOOL isShow;
}
- (void)loadAdTimeOut:(NSTimer*)theTimer;
+ (AdMoGoAdNetworkType)networkType;

@end
