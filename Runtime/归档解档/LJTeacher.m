//
//  LJTeacher.m
//  Runtime
//
//  Created by apple on 2019/9/26.
//  Copyright © 2019 denglj. All rights reserved.
//

#import "LJTeacher.h"
#import <objc/message.h>

@implementation LJTeacher
// 在归档对象的.m方法中实现NSCoding的协议方法

/*
 常规的归档解档，有多少属性就要写多少行
 */
- (void)encodeWithCoder1:(NSCoder *)coder {
    // 归档
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeInteger:self.age forKey:@"age"];
    
}

// 解档
- (instancetype)initWithCoder1:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.name = [coder decodeObjectForKey:@"name"];
        self.age = [coder decodeIntegerForKey:@"age"];
        
    }
    return self;
}

/*
 runtime实现归档解档
 
 使用runtime的好处不言而喻，无论对象有多少属性都可以通过这个for循环搞定
 */
- (void)encodeWithCoder:(NSCoder *)coder {
    // 对象的属性个数
    unsigned int count = 0;
    /*
     Ivar: 在runtime里代表属性(成员变量)
     */
    Ivar *ivars = class_copyIvarList([LJTeacher class], &count);
    for (int i = 0; i<count; i++) {
        // 拿到Ivar
        Ivar ivar = ivars[i];
        // 获取到属性的C字符串名称
        const char *name = ivar_getName(ivar);
        // 转成对应的OC名称
        NSString *key = [NSString stringWithUTF8String:name];
        // 利用KVC获取值
        id obj = [self valueForKey:key];
        // 归档(序列化)
        [coder encodeObject:obj forKey:key];
    }
    // 在OC中使用了Copy、Creat、New类型的函数，需要释放指针！！（注：ARC管不了C函数）
    free(ivars);
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    // 解档
    self = [super init];
    if (self) {
        
        unsigned int count = 0;
        Ivar *ivars = class_copyIvarList([LJTeacher class], &count);
        for (int i = 0; i<count; i++) {
            // 拿到Ivar
            Ivar ivar = ivars[i];
            const char *name = ivar_getName(ivar);
            NSString *key = [NSString stringWithUTF8String:name];
            // 解档
            id value = [coder decodeObjectForKey:key];
            // 利用KVC赋值到成员变量身上
            [self setValue:value forKey:key];
        }
        free(ivars);
    }
    return self;
}

@end
