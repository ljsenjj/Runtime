//
//  RuntimeManage.h
//  Runtime
//
//  Created by apple on 2019/9/28.
//  Copyright © 2019 denglj. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RuntimeManage : NSObject

+ (RuntimeManage *)sharedInstance;

- (void)archived;
- (void)unarchived;
- (void)messageSend;
- (void)methodExchangeImp;
- (void)diyKVO;
- (void)changeValue;
- (void)categoryProperty;
- (void)dictionaryToModel;
    
    
    
@end

