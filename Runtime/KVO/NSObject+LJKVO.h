//
//  NSObject+LJKVO.h
//  Runtime
//
//  Created by apple on 2019/9/24.
//  Copyright © 2019 denglj. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^LJ_KVOObserverBlock) (id observedObject, NSString *observedKey, id oldValue, id newValue);

@interface NSObject (LJKVO)

- (void)LJ_addObserver:(NSObject *_Nullable)observer forKeyPath:(NSString *_Nullable)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context;

// KVO Block
- (void)LJ_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath callback:(LJ_KVOObserverBlock)callback;

- (void)LJ_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;

@end

