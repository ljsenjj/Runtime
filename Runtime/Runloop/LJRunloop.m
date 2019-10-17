//
//  LJRunloop.m
//  Runtime
//
//  Created by apple on 2019/10/16.
//  Copyright © 2019 denglj. All rights reserved.
//

#import "LJRunloop.h"

@interface LJRunloop()

@end

@implementation LJRunloop

/*
 Runloop - 运行循环(死循环)
 
 目的：
 1.保证程序不退出；
 2.负责监听事件；（时钟、网络、触摸等）
 */
- (void)runloopDemo1 {
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:1.0
                                             target:self
                                           selector:@selector(timerMethod)
                                           userInfo:nil
                                            repeats:YES];
    
    /*
     将timer加入到Runloop中才能有用
     NSRunLoop是系统级别的，[[NSRunLoop alloc] init]创建出来的对象是没啥用的
     
     NSRunLoop的每一次循环就在问自己，我的每一种模式下是不是有事件，有就处理，没有事件就等待
     
     关于NSRunLoop模式：一共有5种
     1、NSDefaultRunLoopMode 默认模式：
     该模式下NSRunLoop不能同时处理NSTimer回调和UI的触摸事件
     
     2、UITrackingRunLoopMode UI模式：
     该模式优先级最高，UI的滑动在该模式下的Source处理。
     因为该模式优先级最高，所以苹果设计该模式不能随便使用，该模式只能通过触摸事件所唤醒
     
     所以当timer加入到默认模式中，界面又滚动UITextView时，timer的回调将不来，RunLoop到UI模式下处理UI了
     把timer加入到UI模式中，UI停止滑动，timer回调也停止了，因为该模式下RunLoop只认可UI事件
     可以把timer同时加入到默认模式和UI模式中，timer和UI就可以一起处理了
     
     3、NSRunLoopCommonModes 占位模式：
     是上面两种模式的集合
     [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
     [[NSRunLoop currentRunLoop] addTimer:timer forMode:UITrackingRunLoopMode];
     上面两句等于下面一句
     [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
     
     其他两种日常开发中用不到
     4、系统初始化模式
     只在系统初始化的那一刻存在，之后就没了，所以用不到
     5、内核模式
     没有开放给程序员
     
     每一种模式下处理3种事件
     Source: 事件源，分 Source0 和 Source1 两种
     Timer
     Observer: 观察Runloop本身的
     
     NSRunLoop处理只会在一种模式下处理
     */
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
}

/*
 Runloop多线程
 
 主线程和子线程的区别就是，UI放在主线程上操作，其他没区别，所以主线程也叫UI线程
 UIKIt框架是线程不安全的，为了效率
 */
- (void)runloopDemo2 {
    
    /*
     放入子线程，线程被释放了，timerMethod不会进入
     那么线程强应用，是线程对象被强引用，实际的线程还是没了
     
     一条线程能够存活的唯一的原因就是：有任务！
     线程是CPU调度的，这条线程上没任务，就会被释放！
     */
    NSThread *thread = [[NSThread alloc] initWithBlock:^{
        
        NSTimer *timer = [NSTimer timerWithTimeInterval:1.0
                                                 target:self
                                               selector:@selector(timerMethod)
                                               userInfo:nil
                                                repeats:YES];
        
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        
        /*
         // 写个死循环就有执行不玩的任务咯
         while (true) {
         // 这里面做，从事件列表中取出事件，并处理事件，这样才能回调timerMethod
         }
         */
        
        /*
         每条线程都有RunLoop，但是默认是没有跑起来的，需要手动run
         这句就相当于上面的while (true)
         */
        [[NSRunLoop currentRunLoop] run];
        
        NSLog(@"来了");    // 这句不能打印
        
    }];
    // 线程不会被释放，那么OC对象thread也不会被释放
    [thread start];
    
}

static BOOL _finished;
- (void)runloopDemo3 {
    
    _finished = NO;
    NSThread *thread = [[NSThread alloc] initWithBlock:^{
        
        NSTimer *timer = [NSTimer timerWithTimeInterval:1.0
                                                 target:self
                                               selector:@selector(timerMethod)
                                               userInfo:nil
                                                repeats:YES];
        
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        
        while (!_finished) {
            // 这样NSRunLoop就可以根据_finished的值可控
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.00001]];
        }
        
        NSLog(@"来了");       // 这句能打印了
        
    }];
    // 线程不会被释放，那么OC对象thread也不会被释放
    [thread start];
}

/*
 GCD 定时器
 自己就不用写runloop代码，底层必然是用了runloop的
 */
- (void)runloopDemo4 {
    
    // 要强引用
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    
    /*
     设置定时器
     从什么时候开始
     间隔时间，GCD中单位是纳秒
     1.0*NSEC_PER_SEC 才是1秒
     */
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1.0*NSEC_PER_SEC, 0);
    // 设置事件回调
    dispatch_source_set_event_handler(timer, ^{
        NSLog(@"%@----", [NSThread currentThread]);
    });
    
    // 启动
    dispatch_resume(timer);
}

- (void)timerMethod {
    
    NSLog(@"timerMethod");
    
    // 模拟耗时操作
    [NSThread sleepForTimeInterval:1.0];
    
    static int a = 0;
    NSLog(@"%@-----%d", [NSThread currentThread], a++);
}


@end
