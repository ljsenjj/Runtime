//
//  UIView+Associated.h
//  Runtime
//
//  Created by apple on 2019/9/27.
//  Copyright © 2019 denglj. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface UIView (Associated) {
// 在分类文件中无法添加全局变量
//    NSString *address;       ❌
}

// 属性
@property (nonatomic, copy) NSString *assName;

@end

NS_ASSUME_NONNULL_END
