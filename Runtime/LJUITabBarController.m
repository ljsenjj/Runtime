//
//  LJUITabBarController.m
//  Runtime
//
//  Created by apple on 2019/10/16.
//  Copyright © 2019 denglj. All rights reserved.
//

#import "LJUITabBarController.h"
#import "ViewController1.h"
#import "ViewController2.h"
#import "ViewController3.h"
#import "ViewController4.h"

@interface LJUITabBarController ()

@end

@implementation LJUITabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINavigationController *navc1 = nil;
    UINavigationController *navc2 = nil;
    UINavigationController *navc3 = nil;
    UINavigationController *navc4 = nil;

    ViewController1 *vc1 = [ViewController1 new];
    ViewController2 *vc2 = [ViewController2 new];
    ViewController3 *vc3 = [ViewController3 new];
    ViewController4 *vc4 = [ViewController4 new];

    navc1 = [[UINavigationController alloc] initWithRootViewController: vc1];
    navc2 = [[UINavigationController alloc] initWithRootViewController: vc2];
    navc3 = [[UINavigationController alloc] initWithRootViewController: vc3];
    navc4 = [[UINavigationController alloc] initWithRootViewController: vc4];

    navc1.tabBarItem.image = [UIImage imageNamed:@"item1"];
    navc2.tabBarItem.image = [UIImage imageNamed:@"item2"];
    navc3.tabBarItem.image = [UIImage imageNamed:@"item3"];
    navc4.tabBarItem.image = [UIImage imageNamed:@"item4"];
    
    navc1.tabBarItem.title = @"蝌蚪";
    navc2.tabBarItem.title = @"森林";
    navc3.tabBarItem.title = @"脑子";
    navc4.tabBarItem.title = @"牙牙";

    [self addChildViewController:navc1];
    [self addChildViewController:navc2];
    [self addChildViewController:navc3];
    [self addChildViewController:navc4];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
