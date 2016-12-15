//
//  AdMoGoAdapterCustom.h
//  AdsMogo
//
//  Created by Daxiong on 12-11-22.
//
//

#import "AdMoGoAdNetworkAdapter.h"

@interface AdMoGoSplashAdapterCustomEvent : AdMoGoAdNetworkAdapter
{
    BOOL isStop;
    NSDictionary *key;
    BOOL isTestModel;
}

+ (void)registerClass:(id)clazz;

+ (AdMoGoAdNetworkType)networkType;

- (void)getAd;

- (AdViewType)customAdapterWillgetAdAndGetAdViewType;

- (NSString*)getAPPID_F;

- (NSString*)getAPPID_S;

- (UIWindow*)getWindow;

// 开始请求
- (void)adMoGoCustomDidStartRequest:(AdMoGoAdNetworkAdapter*)adapter;

// 成功
- (void)adMoGoCustomSplashSuccess:(AdMoGoAdNetworkAdapter*)adapter withSplash:(id)adView;

// 失败
- (void)adMoGoCustomSplashFail:(AdMoGoAdNetworkAdapter*)adapter withError:(NSError*)error;

// 将要展示
- (void)adMogoCustomWillPresent:(AdMoGoAdNetworkAdapter*)adapter withSplash:(id)adView;

// 已经展示
- (void)adMogoCustomDidPresent:(AdMoGoAdNetworkAdapter*)adapter withSplash:(id)adView;

// 将要关闭
- (void)adMogoCustomWillDismiss:(AdMoGoAdNetworkAdapter*)adapter withSplash:(id)adView;

// 已经关闭
- (void)adMogoCustomDidDismiss:(AdMoGoAdNetworkAdapter*)adapter withSplash:(id)adView;

// 点击
- (void)adMogoCustomDidClick:(AdMoGoAdNetworkAdapter*)adapter;

@end
