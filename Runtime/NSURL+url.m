//
//  NSURL+url.m
//  Runtime
//
//  Created by apple on 2019/9/23.
//  Copyright © 2019 denglj. All rights reserved.
//

#import "NSURL+url.h"
#import <objc/runtime.h>

@implementation NSURL (url)

/**
 在load方法里做，交换方法的调用操作，
 全工程调用原来的方法都将改变，且用的地方不用改一句代码
 */
+(void)load {
    
    // 系统方法             获取类方法
    Method urlWithStr = class_getClassMethod(self, @selector(URLWithString:));
    // 下面自定义的方法
    Method LJ_urlWithStr = class_getClassMethod(self, @selector(LJ_URLWithString:));
    
    // 获取实例方法
    // class_getInstanceMethod(类名, 方法名)
    
    /*
     SEL(URLWithString:)      -->     IMP(URLWithString:)
     SEL(LJ_URLWithString:)   -->     IMP(LJ_URLWithString:)
     */
    // 交换方法实现
    method_exchangeImplementations(urlWithStr, LJ_urlWithStr);
    
    /*
     SEL(URLWithString:)      -->     IMP(LJ_URLWithString:)
     SEL(LJ_URLWithString:)   -->     IMP(URLWithString:)
     */
}


+(instancetype)LJ_URLWithString:(NSString *)URLString {
    NSLog(@"交换成功");
    // 由于方法已经交换，这样写会递归，自己调用自己
    // NSURL *url = [NSURL URLWithString:URLString];
    
    // 交换后这才是系统原来的方法!
    NSURL *url = [NSURL LJ_URLWithString:URLString];
    
    if (url == nil) {
        NSLog(@"url is nil");
    }
    return url;
}




@end
