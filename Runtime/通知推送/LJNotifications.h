//
//  LJNotifications.h
//  Runtime
//
//  Created by apple on 2019/10/12.
//  Copyright © 2019 denglj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface LJNotifications : NSObject<UNUserNotificationCenterDelegate>

+ (LJNotifications *)sharedInstance;

- (void)replyPushNotificationAuthorization:(UIApplication *)application;

/**
 定时推送
 */
- (void)createLocalizedUserNotification;

/**
 清除角标

 @param application UIApplication
 @param clearCenter YES:都清除，NO:通知中心不清除
 */
-(void)clearBadgeWithApplication:(UIApplication *)application AndClearCenter:(BOOL)clearCenter;

@end

NS_ASSUME_NONNULL_END
