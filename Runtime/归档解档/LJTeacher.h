//
//  LJTeacher.h
//  Runtime
//
//  Created by apple on 2019/9/26.
//  Copyright © 2019 denglj. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 归档解档也叫 OC 的序列化和反序列化
 序列化：把OC对象变成二进制文件(网络请求中，是把OC对象转成Json也叫序列号)
 
 一般用作归档自定义对象，模型
 */

// 归档解档要遵循NSCoding协议

NS_ASSUME_NONNULL_BEGIN

@interface LJTeacher : NSObject<NSCoding>

@property (nonatomic, copy) NSString *name;

@property (nonatomic, assign) int age;

@end

NS_ASSUME_NONNULL_END
