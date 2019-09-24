//
//  Person.m
//  Runtime
//
//  Created by apple on 2019/9/23.
//  Copyright © 2019 denglj. All rights reserved.
//

/**
 app安装的过程
 二进制(可执行文件) --> 装载 --> 到内存
 CPU会优先去读，load加载的那一块内存的指令
 */

#import "Person.h"
#import <objc/runtime.h>

@implementation Person

// 预加载，把代码从硬盘加载到内存中，在main方法之前调用
+(void)load {
    NSLog(@"Person load方法");
}

// 当这个类被调用了一个没有实现的类方法时进入该方法
+(BOOL)resolveClassMethod:(SEL)sel {
    return YES;
}

// 当这个类被调用了一个没有实现的实例方法时进入该方法
+ (BOOL)resolveInstanceMethod:(SEL)sel {
    
    NSLog(@"SEL = %@", NSStringFromSelector(sel));
    
    /*
     给类动态添加方法 -- KVO底层实现，就是动态添加类，动态添加方法
     1 往哪个类里添加方法
     2 表示 selector 的方法名称
     3 IMP——>表示由编译器生成的、指向实现方法的指针。也就是说，这个指针指向的方法就是我们要添加的方法
     4 表示我们要添加的方法的返回值和参数
     */
    class_addMethod(self, sel, (IMP)haha, "");
    
    return [super resolveInstanceMethod:sel];
}


/*
 任何OC方法都有两个 默认(隐式)参数，只是被隐藏了
 id self: 方法的调用者
 SEL _cmd: 方法编号
 
 不加这两个参数，就接受不到外面传进来的参数
 因为会把objc当做是id self
 void haha(NSString *objc)
 
 OC方法调用底层就是消息发送，传的参数就是方法实现时接受的参数，一一对应
 OC方法里的self就是方法的调用者，消息的接收者
 objc_msgSend(p, @selector(say), @"who are u");
 */
// 这是一个函数
void haha(id suibian, SEL quname, NSString *objc) {
    // suibian = p, quname = @selector(say), objc = @"who are u"
    NSLog(@"哈哈了 %@", objc);
}


- (void)eat {
    NSLog(@"吃了");
}












@end
