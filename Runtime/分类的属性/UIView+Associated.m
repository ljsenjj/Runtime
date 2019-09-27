//
//  UIView+Associated.m
//  Runtime
//
//  Created by apple on 2019/9/27.
//  Copyright © 2019 denglj. All rights reserved.
//

#import "UIView+Associated.h"
#import <objc/message.h>

static NSString *nameKey = @"nameKey";

@implementation UIView (Associated)

@dynamic assName;

// 给分类增加属性
- (void)setAssName:(NSString *)assName {
    /*
     关联对象
     1.源对象(self)-被关联的对象
     2.关联时的用来标记是哪一个属性的key（因为你可能要添加很多属性,要求唯一）
     3.关联的对象（assName）
     4.内存管理策略（OBJC_ASSOCIATION_COPY）。
     */
    objc_setAssociatedObject(self, &nameKey, assName, OBJC_ASSOCIATION_COPY);
}

// 获取分类的属性
- (id)assName {
    return objc_getAssociatedObject(self, &nameKey);
}

@end
