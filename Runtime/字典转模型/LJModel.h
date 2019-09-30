//
//  LJModel.h
//  Runtime
//
//  Created by apple on 2019/9/30.
//  Copyright © 2019 denglj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LJModel : NSObject

@property (assign, nonatomic) int ID;
@property (assign, nonatomic) int age;
@property (assign, nonatomic) int weight;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *address;

// 也可以在NSObject分类中写
+ (instancetype)cs_objectWithDict:(NSDictionary *)json;

@end

