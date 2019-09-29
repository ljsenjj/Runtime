//
//  KVOObserverItem.m
//  Runtime
//
//  Created by apple on 2019/9/28.
//  Copyright © 2019 denglj. All rights reserved.
//

#import "KVOObserverItem.h"

@implementation KVOObserverItem

- (instancetype)initWithObserver:(NSObject *)observer key:(NSString *)key block:(LJ_KVOObserverBlock)block {
    self = [super init];
    if (self) {
        self.observer = observer;
        self.key = key;
        self.block = block;
    }
    return self;
}


@end
