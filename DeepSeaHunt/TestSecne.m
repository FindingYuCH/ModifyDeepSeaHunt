//
//  TestSecne.m
//  DeepSeaHunt
//
//  Created by cihui yu on 2016/12/6.
//  Copyright © 2016年 akn. All rights reserved.
//

#import "TestSecne.h"

#import "cocos2d.h"

@implementation TestSecne

- (id) init{
    self = [super init];
    CCSprite * background = [CCSprite spriteWithFile:@"welcome_background"];
    background.position = ccp(self.boundingBox.size.width/2,self.boundingBox.size.height/2);
    [self addChild: background];
    return self;
}

@end
