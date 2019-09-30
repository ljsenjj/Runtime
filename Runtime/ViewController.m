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

 */

#import "ViewController.h"
#import "RuntimeManage.h"

@interface ViewController ()
@property (nonatomic, strong) RuntimeManage *runtimeManage;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _runtimeManage = [RuntimeManage sharedInstance];

}

// 消息发送
- (IBAction)messageSendClick:(id)sender {
    [_runtimeManage messageSend];
}

// 方法交换
- (IBAction)methodExchangeImpClick:(id)sender {
    [_runtimeManage methodExchangeImp];
}

// 归档
- (IBAction)archivedClick:(id)sender {
    [_runtimeManage archived];
}

// 解档
- (IBAction)unarchivedClick:(id)sender {
    [_runtimeManage unarchived];
}

// 分类属性
- (IBAction)categoryPropertyClick:(id)sender {
    [_runtimeManage categoryProperty];
    
}

// 字典转模型
- (IBAction)dictToModelClick:(id)sender {
    [_runtimeManage dictionaryToModel];
    
}

// KVO
- (IBAction)kvoClick:(id)sender {
    [_runtimeManage diyKVO];
    
}

// kvoBlock
- (IBAction)kvoBlockClick:(id)sender {
    
}

// 改值
- (IBAction)changeValueClick:(id)sender {
    [_runtimeManage changeValue];
    
}


@end
