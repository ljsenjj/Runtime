//
//  LJModel.m
//  Runtime
//
//  Created by apple on 2019/9/30.
//  Copyright © 2019 denglj. All rights reserved.
//

#import "LJModel.h"
#import <objc/runtime.h>

@implementation LJModel

+ (instancetype)cs_objectWithDict:(NSDictionary *)json {
    id obj = [[self alloc] init];
    
    unsigned int count;
    Ivar *ivars = class_copyIvarList(self, &count);
    for (int i = 0; i < count; i++) {
        // 取出位置的成员变量
        Ivar ivar = ivars[i];
        NSMutableString *name = [NSMutableString stringWithUTF8String:ivar_getName(ivar)];
        [name deleteCharactersInRange:NSMakeRange(0, 1)];
        
        // 设值
        id value = json[name];
        if ([name isEqualToString:@"ID"]) {
            value = json[@"id"];
        }
        [obj setValue:value forKey:name];
    }
    free(ivars);
    return obj;
}

@end
