//
//  NSObject+LJKVO.h
//  Runtime
//
//  Created by apple on 2019/9/24.
//  Copyright © 2019 denglj. All rights reserved.
//

#import <Foundation/Foundation.h>

// 自定义实现KVO

@interface NSObject (LJKVO)

- (void)LJ_addObserver:(NSObject *_Nullable)observer forKeyPath:(NSString *_Nullable)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context;


@end

