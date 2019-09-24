//
//  main.m
//  Runtime
//
//  Created by apple on 2019/9/23.
//  Copyright © 2019 denglj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

/**
 
 clang -rewrite-objc main.m
 可以用以上命令行，查看main.m底层 C语言实现

 */

int main(int argc, char * argv[]) {
    NSLog(@"main方法");
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
