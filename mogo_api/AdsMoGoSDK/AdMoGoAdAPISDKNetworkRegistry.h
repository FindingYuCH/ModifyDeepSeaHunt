//
//  AdMoGoAdAPISDKNetworkRegistry.h
//  wanghaotest
//
//  Created by mogo on 13-11-28.
//
//

#import <Foundation/Foundation.h>


@class AdMoGoAdNetworkAdapter;

@interface AdMoGoAdAPISDKNetworkRegistry : NSObject{
    NSMutableDictionary *adapterDict;
}
- (NSMutableDictionary *)getAdapterDict;
- (void)setAdapterDict:(NSMutableDictionary *)adapterDict;
- (void)registerClass:(Class)adapterClass;

- (id)adapterClassFor:(NSInteger)adNetworkType;
@end
