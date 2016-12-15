//
//  InMobiNativeAdapter.m
//  mogoNativeDemo
//
//  Created by Castiel Chen on 15/1/7.
//  Copyright (c) 2015年 ___ADSMOGO___. All rights reserved.
//

#import "InMobiNativeAdapter.h"
#import "AdsMogoNativeAdInfo.h"

@implementation InMobiNativeAdapter

+ (AdMoGoNativeAdNetworkType)networkType
{
    return AdMoGoNativeAdNetworkTypeInMobi;
}

+ (void)load
{
    [[AdMoGoNativeRegistry sharedRegistry] registerClass:self];
}

- (void)loadAd:(int)adcount
{
    NSString *accountId = [self.appKeys objectForKey:@"ACCOUNT_ID"];
    long long placementId = [[self.appKeys objectForKey:@"PLACEMENT_ID"] longLongValue];
    
    [IMSdk setLogLevel:kIMSDKLogLevelNone];
    [IMSdk initWithAccountID:accountId];
    self.native = [[IMNative alloc] initWithPlacementId:placementId delegate:self];
    [self.native load];
}

//展示广告
-(void)attachAdView:(UIView*)view nativeData:(AdsMogoNativeAdInfo*)info
{
    [super attachAdView:view nativeData:info];
    [IMNative bindNative:self.native toView:view];
}

//点击广告
-(void)clickAd:(AdsMogoNativeAdInfo *)info
{
    [super clickAd:info];
    NSDictionary *dict = [info valueForKey:AdsMoGoNativeMoGoPdata];
    NSDictionary *keydict = [self inmobiinbis];
    NSString *url = [dict valueForKey:[keydict objectForKey:@"url"]];
    NSURL* URL = [NSURL URLWithString:url];
    [[UIApplication sharedApplication] openURL:URL];
    [self.native reportAdClick:nil];
}

//停止请求广告
- (void)stopAd { }

//请求广告超时
- (void)loadAdTimeOut:(NSTimer*)theTimer
{
    [super loadAdTimeOut:theTimer];
    [self adMogoNativeFailAd:-1];
}

- (void)dealloc
{
    self.native.delegate = nil;
    self.native = nil;

    [super dealloc];
}

#pragma mark - IMNative Delegate
- (void)nativeDidFinishLoading:(IMNative *)native
{
    NSError *error;
    NSData *data = [native.adContent dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *imobiDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    NSMutableArray *mutableArray = [NSMutableArray array];
    NSDictionary *keydict = [self inmobiinbis];
    AdsMogoNativeAdInfo *adsMogoNativeInfo =[[AdsMogoNativeAdInfo alloc]init];
    [adsMogoNativeInfo setValue:[imobiDict objectForKey:[keydict objectForKey:@"title"]] forKey:AdsMoGoNativeMoGoTitle];
    [adsMogoNativeInfo setValue:[[imobiDict objectForKey:[keydict objectForKey:@"icon"]] objectForKey:@"url"] forKey:AdsMoGoNativeMoGoIconUrl];
    [adsMogoNativeInfo setValue:[[imobiDict objectForKey:[keydict objectForKey:@"icon"]] objectForKey:@"width"] forKey:AdsMoGoNativeMoGoIconWidth];
    [adsMogoNativeInfo setValue:[[imobiDict objectForKey:[keydict objectForKey:@"icon"]] objectForKey:@"height"] forKey:AdsMoGoNativeMoGoIconHeight];
    [adsMogoNativeInfo setValue:[imobiDict objectForKey:[keydict objectForKey:@"description"]] forKey:AdsMoGoNativeMoGoDesc];
    [adsMogoNativeInfo setValue:[[imobiDict objectForKey:[keydict objectForKey:@"screenshots"]] objectForKey:@"url"] forKey:AdsMoGoNativeMoGoImageUrl];
    [adsMogoNativeInfo setValue:[[imobiDict objectForKey:[keydict objectForKey:@"screenshots"]] objectForKey:@"width"] forKey:AdsMoGoNativeMoGoImageWidth];
    [adsMogoNativeInfo setValue:[[imobiDict objectForKey:[keydict objectForKey:@"screenshots"]] objectForKey:@"height"] forKey:AdsMoGoNativeMoGoImageHeight];
    
    [adsMogoNativeInfo setValue:[imobiDict objectForKey:[keydict objectForKey:@"rating"]] forKey:AdsMoGoNativeMoGoRating];
    
    [adsMogoNativeInfo setValue:imobiDict forKey:AdsMoGoNativeMoGoPdata];
    [adsMogoNativeInfo setValue:[self getMogoJsonByDic:adsMogoNativeInfo] forKey:AdsMoGoNativeMoGoJsonStr];
    [mutableArray addObject:adsMogoNativeInfo];
    [adsMogoNativeInfo release];
    [self adMogoNativeSuccessAd:mutableArray];
}

- (void)native:(IMNative *)native didFailToLoadWithError:(IMRequestStatus *)error
{
    [self adMogoNativeFailAd:-1];
}

- (void)nativeWillPresentScreen:(IMNative*)native { }

- (void)nativeDidPresentScreen:(IMNative*)native { }

- (void)nativeWillDismissScreen:(IMNative*)native { }

- (void)nativeDidDismissScreen:(IMNative*)native { }

- (void)userWillLeaveApplicationFromNative:(IMNative*)native { }

@end
