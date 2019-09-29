//
//  KVOObserverItem.h
//  Runtime
//
//  Created by apple on 2019/9/28.
//  Copyright © 2019 denglj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+LJKVO.h"

@interface KVOObserverItem : NSObject

@property (nonatomic, weak) NSObject *observer;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) LJ_KVOObserverBlock block;

- (instancetype)initWithObserver:(NSObject *)observer key:(NSString *)key block:(LJ_KVOObserverBlock)block;

@end

