//
//  ViewController.m
//  Runtime
//
//  Created by apple on 2019/9/23.
//  Copyright © 2019 denglj. All rights reserved.
//

/**
 OC 方法的本质 通过 SEL找IMP
 SEL1  ->  IMP2
 SEL2  ->  IMP1
 
 
 iOS学院--Runtime aiqiyi
 */

#import "ViewController.h"
#import "Person.h"
#import "PersonKVO.h"
#import "NSObject+LJKVO.h"
#import <objc/runtime.h>
#import <objc/message.h>

@interface ViewController ()
@property (nonatomic, strong) PersonKVO *pkvo;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
//    [self test1];
//    [self test2];
    [self kvoTest];

}

// oc方法调用实质是 消息发送！
- (void)test1 {
    
    // 获取类
    NSClassFromString(@"");
    objc_getClass("");          // runtime 底层写法
    
    // 获取方法
    NSSelectorFromString(@"");
    sel_registerName("");       // runtime 底层写法
    
    
    // 用消息发送方法创建person实例
    // objc_msgSend(类对象, 要调用的方法，参数...)
    
    // Person *p = [Person alloc];
    Person *p = objc_msgSend(NSClassFromString(@"Person"), sel_registerName("alloc"));
    // p = [p init];
    p = objc_msgSend(p, @selector(init));

    // 调用方法
    [p performSelector:@selector(say) withObject:@"who are u"];
//    objc_msgSend(p, @selector(say), @"who are u");
    // 消息发送，底层就是这么实现的
    objc_msgSend(p, @selector(eat));
}


- (void)test2 {
    NSURL *url = [NSURL URLWithString:@"http://www.baidu.con/中午"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSLog(@"%@", request);
}


- (void)kvoTest {
    
    PersonKVO *p = [[PersonKVO alloc] init];
    
    NSLog(@"==========添加KVO监听之前==========");
    NSLog(@"p的类对象 : %@", object_getClass(p)); // p.isa
    NSLog(@"p的元类对象 : %@", object_getClass(object_getClass(p)));  // p.isa.isa
    NSLog(@"p对象的父类 : %@", [object_getClass(p) superclass]);   // 类对象的superclass
    // 打s断点，lldb控制台输入  p (IMP) 0x10089dfec 可以将方法地址转成名称形式显示
    NSLog(@"方法 : %p", [p methodForSelector:@selector(setName:)]);
    
    // 添加观察者,监听name值的变化
    
    /*▼▼
     p对象的name属性被self的控制器观察了
     
     OC对象的属性组成 _成员变量，getter, setter方法
     KVO观察的是属性的修改，其实是观察setter方法，不是观察成员变量的变化, 成员变量的变化，KVO观察者是观察不到的！
     
     内部实现:利用Runtime动态创建了一个继承Person的子类！手动实现KVO
     并且修改p实例对象的源指针类型！修改isa指针指向创建出来的子类！
     所以当name值变化的时候，能进入外面的observeValueForKeyPath方法
     ▲▲*/
    
//    [p addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:nil];
    // 用自定义的观察者
    [p LJ_addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:nil];
    
    NSLog(@"==========添加KVO监听之后==========");
    NSLog(@"p的类对象 : %@", object_getClass(p));      // p.isa
    NSLog(@"p的元类对象 : %@", object_getClass(object_getClass(p)));  // p.isa.isa
    NSLog(@"p对象的父类 : %@", [object_getClass(p) superclass]);   // 类对象的superclass
    NSLog(@"方法 : %p", [p methodForSelector:@selector(setName:)]);
    _pkvo = p;
}

// 值变化，进入该方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"change = %@", change);
}

// 改变_pkvo属性name的值
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    static int a;
    _pkvo.name = [NSString stringWithFormat:@"%d", a++];
}

@end
