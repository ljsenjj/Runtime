//
//  NSObject+LJKVO.m
//  Runtime
//
//  Created by apple on 2019/9/24.
//  Copyright © 2019 denglj. All rights reserved.
//
// KVO底层实现

#import "NSObject+LJKVO.h"
#import <objc/message.h>

@implementation NSObject (LJKVO)


- (void)LJ_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context {
    
    NSString *oldName = NSStringFromClass(self.class);
    NSString *newName = [@"LJKVO_" stringByAppendingString:oldName];
    
    /*
     动态创建一个类(创建PersonKVO的子类)
     1、继承谁(调用者，就是self.class)
     2、叫什么名字(C类型的字符串)
     */
    Class newClass = objc_allocateClassPair(self.class, newName.UTF8String, 0);
    // 注册该类
    objc_registerClassPair(newClass);
    // 修改PersonKVO实例对象的isa指针
    object_setClass(self, newClass);
    
    /*
     子类继承父类，子类里是没有setName方法的
     但是能调用，是因为isa指针的存在，当子类找不到setName方法，就从父类中找
     所以上面新建并注册了Person的子类，还要动态添加setName方法
     */
    class_addMethod(newClass, @selector(setName:), (IMP)setNameLJ, "v@:@");
    
}

/*
 iOS用什么方式实现对一个对象的KVO？（KVO的本质是什么？）
 当一个对象使用了KVO监听，iOS系统会修改这个对象的isa指针，
 改为指向一个全新的通过Runtime动态创建的子类，子类拥有自己的set方法实现，
 set方法实现内部会顺序调用willChangeValueForKey方法、原来的setter方法实现、didChangeValueForKey方法，
 而didChangeValueForKey方法内部又会调用监听器(observer)的
 observeValueForKeyPath:ofObject:change:context:监听方法。
 */
void setNameLJ(id self, SEL _cmd, NSString *newName){
    NSLog(@"我们拿到了: %@", newName);
    // KVO手动触发
    [self willChangeValueForKey:@"name"];
//    [super setName:newName];
    objc_msgSend(self, @selector(setName:), newName);
    [self didChangeValueForKey:@"name"];
}

@end
