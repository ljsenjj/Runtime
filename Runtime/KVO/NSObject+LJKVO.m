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
#import "KVOObserverItem.h"

static NSString *const LJKVOPrefix = @"LJ_NSKVONotifying_";
static NSString *const LJKVOAssociatedObserver = @"LJKVO_AssociatedObserver";
static NSString *const LJKVOAssociatedOldValue = @"LJKVO_AssociatedOldValue";

static void *const LJKVOObserverAssociatedKey = (void *)&LJKVOObserverAssociatedKey;

@implementation NSObject (LJKVO)

- (void)LJ_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context {
    
    [self classForMethods:self.class];
    
    // 是否有setter方法
    SEL originalSel = NSSelectorFromString(setterForKey(keyPath));
    Method originalMethod = class_getInstanceMethod(self.class, originalSel);
    if (!originalMethod) {
        
        NSString *exceptionReason = [NSString stringWithFormat:@"%@ Class %@ setter SEL not found.",
                                     NSStringFromClass([self class]),
                                     NSStringFromSelector(originalSel)];
        NSException *exception = [NSException exceptionWithName:@"NotExistKeyExceptionName"
                                                         reason:exceptionReason
                                                       userInfo:nil];
        [exception raise];
    }
    // 动态创建子类  NSKVONotifying_xxx
    Class childClass = [self registerChildClassWithSuperClass:self.class];
    
//    Method class_method = class_getInstanceMethod(self.class, @selector(class));
//    class_addMethod(childClass, @selector(class), (IMP)kvo_class, method_getTypeEncoding(class_method));
    
    // 给子类动态的添加 didChangeValueForKey 方法
    SEL changeValueSel = NSSelectorFromString(@"didChangeValueForKey:");
    Method changeValueMethod = class_getInstanceMethod(self.class, changeValueSel);
    const char *changeValueType = method_getTypeEncoding(changeValueMethod);
    class_addMethod(childClass, changeValueSel, (IMP)kvo_didChangeValue, changeValueType);
    
    /*
     动态的给子类添加 setter 方法
     
     子类继承父类，子类里是没有setName方法的
     但是能调用，是因为isa指针的存在，当子类找不到setName方法，就从父类中找
     所以上面新建并注册了Person的子类，还要动态添加setName方法的实现
     */
    class_addMethod(childClass, originalSel, (IMP)kvo_setter, method_getTypeEncoding(originalMethod));
    
    // 这里还要根据监听值的类型，来生成kvo_setter方法，否则当监听的是int类型时，id参数会挂
    
    // 将观察者对象跟当前实例 self 关联起来
    objc_setAssociatedObject(self, (__bridge const void * _Nonnull)(LJKVOAssociatedObserver), observer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self classForMethods:childClass];
}

#pragma mark ----KVO Block----
/**
 1. 通过Method判断是否有这个key对应的selector，如果没有则Crash。
 2. 判断当前类是否是KVO子类，如果不是则创建，并设置其isa指针。
 3. 如果没有实现，则添加Key对应的setter方法。
 4. 将调用对象添加到数组中。
*/
- (void)LJ_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath callback:(LJ_KVOObserverBlock)callback {
    
    // 1.
    SEL originalSel = NSSelectorFromString(setterForKey(keyPath));
    Method originalMethod = class_getInstanceMethod(self.class, originalSel);
    if (!originalMethod) {
        
        NSString *exceptionReason = [NSString stringWithFormat:@"%@ Class %@ setter SEL not found.",
                                     NSStringFromClass([self class]),
                                     NSStringFromSelector(originalSel)];
        NSException *exception = [NSException exceptionWithName:@"NotExistKeyExceptionName"
                                                         reason:exceptionReason
                                                       userInfo:nil];
        [exception raise];
    }
    
    // 2.
    Class childClass = self.class;
    NSString *kvoClassString = NSStringFromClass(self.class);
    if (![kvoClassString hasPrefix:LJKVOPrefix]) {
        childClass = [self registerChildClassWithSuperClass:self.class];
    }
    
    // 3.
    if (![self hasSeletorWithSel:originalSel]) {
        class_addMethod(childClass, originalSel, (IMP)block_kvoSetter, method_getTypeEncoding(originalMethod));
    }
    
    // 4.
    KVOObserverItem *observerItem = [[KVOObserverItem alloc] initWithObserver:observer
                                                                          key:keyPath
                                                                        block:callback];
    
    NSMutableArray<KVOObserverItem *> *observers = objc_getAssociatedObject(self, LJKVOObserverAssociatedKey);
    if (observers == nil) {
        observers = [NSMutableArray array];
    }
    [observers addObject:observerItem];
    objc_setAssociatedObject(self, LJKVOObserverAssociatedKey, observers, OBJC_ASSOCIATION_RETAIN);
    
}

- (void)LJ_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath {
    
    NSMutableArray <KVOObserverItem *> *observers = objc_getAssociatedObject(self, LJKVOObserverAssociatedKey);
    [observers enumerateObjectsUsingBlock:^(KVOObserverItem * _Nonnull mapTable, NSUInteger idx, BOOL * _Nonnull stop) {
        if (mapTable.observer == observer && [mapTable.key isEqualToString:keyPath]) {
            [observers removeObject:mapTable];
        }
    }];
    
}

/**
 1. 获取旧值。
 2. 创建super的结构体，并向super发送属性的消息。
 3. 遍历调用block。
 */
static void block_kvoSetter(id self, SEL _cmd, id newValue) {
    // 1.
    id (*getterMsgSend) (id, SEL) = (void *)objc_msgSend;
    NSString *key = keyForSetter(NSStringFromSelector(_cmd));
    SEL getterSelector = NSSelectorFromString(key);
    id oldValue = getterMsgSend(self, getterSelector);
    
    // 2.
    id (*msgSendSuper) (void *, SEL, id) = (void *)objc_msgSendSuper;
    struct objc_super objcSuper = {
        .receiver = self,
        .super_class = class_getSuperclass(object_getClass(self))
    };
    msgSendSuper(&objcSuper, _cmd, newValue);
    
    // 3.
    NSMutableArray <KVOObserverItem *>* observers = objc_getAssociatedObject(self, LJKVOObserverAssociatedKey);
    [observers enumerateObjectsUsingBlock:^(KVOObserverItem * _Nonnull mapTable, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([mapTable.key isEqualToString:key] && mapTable.block) {
            mapTable.block(self, NSStringFromSelector(_cmd), oldValue, newValue);
        }
    }];
}

#pragma mark - 函数区域
/**
 运行时动态的创建子类
 
 @param superCls 父类
 @return 返回子类
 */
- (Class)registerChildClassWithSuperClass:(Class)superCls  {
    
    // 判断是否存在子类，如果存在则返回。
    NSString *childClsName = [NSString stringWithFormat:@"%@%@", LJKVOPrefix, superCls];
    Class childCls = objc_getClass(childClsName.UTF8String);
    if (childCls) {
        return childCls;
    }
    
    /*
     动态创建一个类(创建PersonKVO的子类)
     1、继承谁(调用者，就是self.class)
     2、叫什么名字(C类型的字符串)
     3、分配内存大小
     */
    childCls = objc_allocateClassPair(superCls, childClsName.UTF8String, 16);
    // 注册一个子类
    objc_registerClassPair(childCls);
    
    // 给子类动态的添加 class 实现
    SEL classSel = NSSelectorFromString(@"class");
    Method classMethod = class_getInstanceMethod(self.class, classSel);
    const char *classType = method_getTypeEncoding(classMethod);
    class_addMethod(childCls, classSel, (IMP)kvo_class, classType);
    
    /*
     将一个对象设置为别的类类型
     将父类 isa 指针指向 子类
     */
    object_setClass(self, childCls);
    
    return childCls;
}

/**
 自实现 class 方法
 
 @param self 当前类实现
 @param _cmd  class
 @return  返回父类 Class 外界不会知道 NSKVONotifying_子类存在
 */
static Class kvo_class(id self, SEL _cmd) {
    return class_getSuperclass(object_getClass(self));
}


/**
 自实现 setter 方法
 
 iOS用什么方式实现对一个对象的KVO？（KVO的本质是什么？）
 当一个对象使用了KVO监听，iOS系统会修改这个对象的isa指针，
 改为指向一个全新的通过Runtime动态创建的子类，子类拥有自己的set方法实现，
 set方法实现内部会顺序调用willChangeValueForKey方法、原来的setter方法实现、didChangeValueForKey方法，
 而didChangeValueForKey方法内部又会调用监听器(observer)的
 observeValueForKeyPath:ofObject:change:context:监听方法。
 
 @param self 当前类实现
 @param _cmd  setter
 @param newValue 赋值
 */
static void kvo_setter(id self, SEL _cmd, id newValue) {
    NSLog(@"我们拿到了:%@", newValue);
    
    NSString *setterName = NSStringFromSelector(_cmd);
    NSString *key = keyForSetter(setterName);
    
    // 将要改变属性的值
    [self willChangeValueForKey:key];
    
    // 调用 super setter 方法
    struct objc_super suer_cls = {
        .receiver = self,
        .super_class = class_getSuperclass(object_getClass(self))
    };
    
    NSString *oldValue = [self valueForKey:key];
    // 存储旧值
    objc_setAssociatedObject(self,(__bridge const void * _Nonnull)(LJKVOAssociatedOldValue),oldValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    // 调用父类 setter 方法 设置新值
    //    objc_msgSendSuper(&suer_cls, _cmd, newValue);
    ((void (*)(void *, SEL, id))objc_msgSendSuper)(&suer_cls, _cmd, newValue);
    
    // 改变监听属性值后 调用 didChangeValueForKey 并在内部调用
    [self didChangeValueForKey:key];
    
};

/**
 didChangeValueForkey 实现方法 , 当根据 SEL (didChangeValueForkey:) 会找到方法 IMP 实现
 
 @param self 方法调用者
 @param _cmd 方法编号
 @param key 属性名
 */
static void kvo_didChangeValue(id self, SEL _cmd, NSString *key) {
    
    id newValue = [self valueForKey:key];
    id observer = objc_getAssociatedObject(self,(__bridge const void * _Nonnull)(LJKVOAssociatedObserver));
    id oldValue = objc_getAssociatedObject(self,(__bridge const void * _Nonnull)(LJKVOAssociatedOldValue));
    
    NSMutableDictionary *change = [NSMutableDictionary dictionary];
    if (oldValue) {
        change[@"oldValue"] = oldValue;
    } else {
        change[@"oldValue"] = [NSNull null];
    }
    if (newValue) {
        change[@"newValue"] = newValue;
    } else {
        change[@"newValue"] = newValue;
    }
    
    [observer observeValueForKeyPath:key ofObject:self change:change context:NULL];
    
}


/**
 从key获取set方法的名称 name ===>>> setName:

 @param key 属性名
 @return setter set方法的名称
 */
static NSString  * setterForKey(NSString *key){
    
    if (key.length <= 0) { return nil; }
    
    NSString *setter = [NSString stringWithFormat:@"set%@:", [key capitalizedString]];
    return setter;
}


/**
 从set方法获取key setName:===> name

 @param setter set方法的名称
 @return key 属性名
 */
static NSString * keyForSetter(NSString *setter){
    
    if (setter.length <= 0 || ![setter hasPrefix:@"set"] || ![setter hasSuffix:@":"]) { return nil;}
    
    NSRange range = NSMakeRange(3, setter.length-4);
    NSString *key = [setter substringWithRange:range];
    NSString *firstString = [[key substringToIndex:1] lowercaseString];
    key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:firstString];
    
    return key;
}


/**
 打印类里的所有方法名字

 @param class 类
 */
- (void)classForMethods:(Class)class {
    
    unsigned int count ;
    Method *methods = class_copyMethodList(class, &count);
    NSMutableString *methodNames = [NSMutableString string];
    [methodNames appendFormat:@"%@ 方法: ", class];
    
    for (int i = 0 ; i < count; i++) {
        Method method = methods[i];
        NSString *methodName  = NSStringFromSelector(method_getName(method));
        [methodNames appendString: methodName];
        [methodNames appendString:@" , "];
    }
    NSLog(@"%@",methodNames);
    
}

/**
 判断是否存在该方法

 @param selector 方法编号
 @return YES or NO
 */
- (BOOL)hasSeletorWithSel:(SEL)selector {
    unsigned int methodCount = 0;
    //得到一堆方法的名字列表  //class_copyIvarList 实例变量  //class_copyPropertyList 得到所有属性名字
    Method *methodList = class_copyMethodList(object_getClass(self), &methodCount);
    
    for (int i = 0; i<methodCount; i++) {
        SEL sel = method_getName(methodList[i]);
        if (selector == sel) {
            free(methodList);
            return YES;
        }
    }
    free(methodList);
    return NO;
}

@end
