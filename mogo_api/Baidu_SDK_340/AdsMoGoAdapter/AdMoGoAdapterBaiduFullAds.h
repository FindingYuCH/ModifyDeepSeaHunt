//
//  AdMoGoAdapterBaiduFullAds.h
//  TestV1.3.1
//
//  Created by wang hao on 13-9-17.
//
//

#import <UIKit/UIKit.h>
#import "BaiduMobAdInterstitial.h"
#import "AdMoGoAdNetworkInterstitialAdapter.h"

@interface AdMoGoAdapterBaiduFullAds : AdMoGoAdNetworkInterstitialAdapter<BaiduMobAdInterstitialDelegate>
{
    BaiduMobAdInterstitial *baiduInterstitial;
    NSTimer *timer;
    BOOL isStop;
}

+ (AdMoGoAdNetworkType)networkType;
@end
