//
//  RuntimeManage.m
//  Runtime
//
//  Created by apple on 2019/9/28.
//  Copyright © 2019 denglj. All rights reserved.
//

#import "RuntimeManage.h"
#import <objc/message.h>
#import "Person.h"
#import "PersonKVO.h"
#import "LJTeacher.h"
#import "NSObject+LJKVO.h"
#import "UIView+Associated.h"

@interface RuntimeManage ()
@property (nonatomic, strong) PersonKVO *pkvo;

@end

@implementation RuntimeManage

#pragma mark ----单例初始化----

static RuntimeManage *_instance = nil ;

+ (RuntimeManage *)sharedInstance {
    if (_instance == nil) {
        _instance = [[self alloc] init];
    }
    return _instance;
}

// 无论是alloc还是new，都会调用到 allocWithZone方法
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_instance == nil) {
            _instance = [super allocWithZone:zone];
            _instance.pkvo = [[PersonKVO alloc] init];
        }
    });
    return _instance;
}

// 通过拷贝对象，会调用以下方法
-(id)copyWithZone:(NSZone *)zone {
    return _instance;
}

-(id)mutableCopyWithZone:(NSZone *)zone {
    return _instance;
}


#pragma mark ----归档解档----
- (void)archived {
    
    LJTeacher *t = [[LJTeacher alloc] init];
    t.name = @"dlj";
    t.age = 20;
    
    // 沙盒路径
    NSString *temp = NSTemporaryDirectory();
    NSString *filePath = [temp stringByAppendingPathComponent:@"t.lj"];
    
    // 归档
    [NSKeyedArchiver archiveRootObject:t toFile:filePath];
    NSLog(@"归档完成");
}

- (void)unarchived {
    NSString *temp = NSTemporaryDirectory();
    NSString *filePath = [temp stringByAppendingPathComponent:@"t.lj"];
    // 解档
    LJTeacher *ut = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    
    NSLog(@"拿到了解档是名字：%@, 年龄：%d", ut.name, ut.age);
}
    
#pragma mark ----消息发送机制----
// oc方法调用实质是 消息发送！
- (void)messageSend {
    
    // 获取类
    NSClassFromString(@"");
    objc_getClass("");          // runtime 底层写法
    
    // 获取方法
    NSSelectorFromString(@"");
    sel_registerName("");       // runtime 底层写法
    
    // 用消息发送方法创建person实例
    // objc_msgSend(消息的接收者, 要调用的方法(方法编号SEL)，参数...)
    
    // Person *p = [Person alloc];
    Person *p = objc_msgSend(NSClassFromString(@"Person"), sel_registerName("alloc"));
    // p = [p init];
    p = objc_msgSend(p, @selector(init));
    
    // 消除警告
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    // 调用方法
    [p performSelector:@selector(say) withObject:@"who are u"];
    //    objc_msgSend(p, @selector(say), @"who are u");
    // 消息发送，底层就是这么实现的
    objc_msgSend(p, @selector(eat));
    objc_msgSend(p, @selector(run));
    
#pragma clang diagnostic pop
}

#pragma mark ----交换方法实现----
- (void)methodExchangeImp {
    NSURL *url = [NSURL URLWithString:@"http://www.baidu.con/中午"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSLog(@"%@", request);
}

#pragma mark ----自定义KVO----
- (void)diyKVO {
    
    _pkvo.name = @"oldName";
    
    NSLog(@"==========添加KVO监听之前==========");
    NSLog(@"p的类对象 : %@", object_getClass(_pkvo)); // p.isa
    NSLog(@"p的元类对象 : %@", object_getClass(object_getClass(_pkvo)));  // p.isa.isa
    NSLog(@"p的类对象的父类 : %@", [object_getClass(_pkvo) superclass]);   // 类对象的superclass
    // 打断点，lldb控制台输入  p (IMP) 0x10089dfec 可以将方法地址转成名称形式显示
    NSLog(@"set方法 : %p", [_pkvo methodForSelector:@selector(setName:)]);
    
    // 添加观察者,监听name值的变化
    
    /*▼▼
     p对象的name属性被self的控制器观察了
     
     OC对象的属性组成 _成员变量，getter, setter方法
     KVO观察的是属性的修改，其实是观察setter方法，不是观察成员变量的变化, 成员变量的变化，KVO观察者是观察不到的！
     
     内部实现:利用Runtime动态创建了一个继承Person的子类！手动实现KVO
     并且修改p实例对象的源指针类型！修改isa指针指向创建出来的子类！
     所以当name值变化的时候，能进入外面的observeValueForKeyPath方法
     ▲▲*/
    
    //    [_pkvo addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:nil];
    // 用自定义的观察者
    [_pkvo LJ_addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:nil];
    
    NSLog(@"==========添加KVO监听之后==========");
    NSLog(@"p的类对象 : %@", object_getClass(_pkvo));      // p.isa
    NSLog(@"p的元类对象 : %@", object_getClass(object_getClass(_pkvo)));  // p.isa.isa
    NSLog(@"p的类对象的父类 : %@", [object_getClass(_pkvo) superclass]);   // 类对象的superclass
    NSLog(@"set方法 : %p", [_pkvo methodForSelector:@selector(setName:)]);
}

// 值变化，进入该方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"change = %@", change);
}

// 改变_pkvo属性name的值
- (void)changeValue {
    static int a;
    NSLog(@"changeValue = %d", a);
    _pkvo.name = [NSString stringWithFormat:@"%d", a++];
}

#pragma mark ----分类的属性----
// 可以通过runtime给分类添加属性
- (void)categoryProperty {
    UIView *view = [[UIView alloc] init];
    view.assName = @"assName111";
    NSLog(@"我是分类的属性:%@", view.assName);
}

@end
