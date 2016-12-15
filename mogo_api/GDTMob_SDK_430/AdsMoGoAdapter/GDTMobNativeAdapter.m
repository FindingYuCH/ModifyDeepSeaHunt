//
//  GDTMobNativeAdapter.m
//  mogoNativeDemo
//
//  Created by Castiel Chen on 15/1/7.
//  Copyright (c) 2015年 ___ADSMOGO___. All rights reserved.
//

#import "GDTMobNativeAdapter.h"
#import "AdsMogoNativeAdInfo.h"
#import "AdMoGoNativeUserKey.h"

@implementation GDTMobNativeAdapter

+ (AdMoGoNativeAdNetworkType)networkType
{
    return AdMoGoNativeAdNetworkTypeGDTMob;
}

+ (void)load
{
    [[AdMoGoNativeRegistry sharedRegistry] registerClass:self];
}

- (void)loadAd:(int)adcount
{
    nativeAd =[[GDTNativeAd alloc]initWithAppkey:[self.appKeys objectForKey:@"appid"] placementId:[self.appKeys objectForKey:@"pid"]];
    nativeAd.controller = [self getAdMogoViewController];
    nativeAd.delegate = self;
    //拉去数据
    [nativeAd loadAd:adcount];
}

//展示广告
-(void)attachAdView:(UIView*)view nativeData:(AdsMogoNativeAdInfo*)info
{
    [super attachAdView:view nativeData:info];
    [nativeAd attachAd:(GDTNativeAdData *) [info valueForKey:AdsMoGoNativeMoGoPdata]   toView:view];
}

//点击广告
-(void)clickAd:(AdsMogoNativeAdInfo*)info
{
    [super clickAd:info];
    [nativeAd clickAd:(GDTNativeAdData *)[info valueForKey:AdsMoGoNativeMoGoPdata] ];
}

//停止请求广告
- (void)stopAd { }

//请求广告超时
- (void)loadAdTimeOut:(NSTimer*)theTimer
{
    [super loadAdTimeOut:theTimer];
    [self adMogoNativeFailAd:-1];
}

#pragma mark --GDTNativeAdDelegate
/**
 *  原生广告加载广告数据成功回调，返回为GDTNativeAdData对象的数组
 */
-(void)nativeAdSuccessToLoad:(NSArray *)nativeAdDataArray
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (GDTNativeAdData *gdtData in nativeAdDataArray) {
        NSDictionary *gdt_dic = gdtData.properties;
        AdsMogoNativeAdInfo *adsMogoNativeInfo =[[[AdsMogoNativeAdInfo alloc] init] autorelease];
        [adsMogoNativeInfo setValue:[gdt_dic objectForKey:GDTNativeAdDataKeyTitle] forKey:AdsMoGoNativeMoGoTitle];
        [adsMogoNativeInfo setValue:[gdt_dic objectForKey:GDTNativeAdDataKeyIconUrl] forKey:AdsMoGoNativeMoGoIconUrl];
        [adsMogoNativeInfo setValue:[gdt_dic objectForKey:GDTNativeAdDataKeyDesc] forKey:AdsMoGoNativeMoGoDesc];
        [adsMogoNativeInfo setValue:[gdt_dic objectForKey:GDTNativeAdDataKeyImgUrl] forKey:AdsMoGoNativeMoGoImageUrl];
        [adsMogoNativeInfo setValue:gdtData forKey:AdsMoGoNativeMoGoPdata];
        [adsMogoNativeInfo setValue:[self getMogoJsonByDic:adsMogoNativeInfo] forKey:AdsMoGoNativeMoGoJsonStr];
        [array addObject:adsMogoNativeInfo];
    }
    
    //TODO::统一成芒果的格式
    [self adMogoNativeSuccessAd:array];
}

/**
 *  原生广告加载广告数据失败回调
 */
-(void)nativeAdFailToLoad:(NSError *)error
{
    [self adMogoNativeFailAd:0];
}


-(void)dealloc
{
    if (nativeAd) {
        [nativeAd release],nativeAd =nil;
    }
    [super dealloc];
}


@end
