//
//  ShakeWindow.m
//  winmin 3.0
//
//  Created by sdzg on 15-1-4.
//  Copyright (c) 2015年 itouchco.com. All rights reserved.
//

#import "ShakeWindow.h"
#import <CoreMotion/CoreMotion.h>
#import "BackgroundAudioPlay.h"

typedef void (^shakeResponseMsg)(NSMutableArray *);
typedef void (^shakeNoResponseMsg)(NSMutableArray *);
@interface ShakeWindow ()
@property (nonatomic, strong) CMMotionManager *manager;
@property (nonatomic, strong) NSOperationQueue *motionQueue;
//用于全局摇一摇
@end

@implementation ShakeWindow

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    CMMotionManager *manager = [[CMMotionManager alloc] init];
    if (!manager.accelerometerAvailable) {
      NSLog(@"Accelerometer not available");
    } else {
      self.motionQueue = [[NSOperationQueue alloc] init];
      manager.deviceMotionUpdateInterval = .5f;
    }
    self.manager = manager;
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(applicationWillEnterForegroundNotification:)
               name:UIApplicationWillEnterForegroundNotification
             object:nil];
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(applicationDidEnterBackgroundNotification:)
               name:UIApplicationDidEnterBackgroundNotification
             object:nil];
    [self registerforDeviceLockNotif];
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  CFNotificationCenterRemoveEveryObserver(
      CFNotificationCenterGetDarwinNotifyCenter(), NULL);
}
//#pragma mark - UdpRequestDelegate
//- (void)udpRequest:(UdpRequest *)request
//     didReceiveMsg:(CC3xMessage *)message
//           address:(NSData *)address {
//  switch (message.msgId) { //开关控制
//    case 0x12:
//    case 0x14:
//      [self responseMsg12Or14:message request:request];
//      break;
//  }
//}
//
//- (void)responseMsg12Or14:(CC3xMessage *)message request:(UdpRequest *)request
//{
//  DDLogDebug(@"%s socketGroupId is %d", __func__, message.socketGroupId);
//  if (message.state == kUdpResponseSuccessCode) {
//    SDZGSocket *socket =
//        [self.aSwitch.sockets objectAtIndex:message.socketGroupId - 1];
//    socket.socketStatus = !socket.socketStatus;
//    [self.aSwitch.sockets replaceObjectAtIndex:message.socketGroupId - 1
//                                    withObject:socket];
//  }
//}
#define accelerationThreshold 1.0
- (void)motionMethod:(CMDeviceMotion *)deviceMotion {
  CMAcceleration userAcceleration = deviceMotion.userAcceleration;
  //  NSLog(@"user data is %@", [deviceMotion description]);
  //  if (fabs(userAcceleration.x) > accelerationThreshold ||
  //      fabs(userAcceleration.y) > accelerationThreshold ||
  //      fabs(userAcceleration.z) > accelerationThreshold) {
  //    NSLog(@"motion shake");
  //    [[BackgroundAudioPlay sharedInstance] playSound];
  //  }
  //  NSLog(@"[UIScreen mainScreen].Brightness is %f",
  //        [UIScreen mainScreen].brightness);
  //综合3个方向的加速度
  double accelerameter =
      sqrt(pow(userAcceleration.x, 2) + pow(userAcceleration.y, 2) +
           pow(userAcceleration.z, 2));
  //当综合加速度大于2.3时，就激活效果（此数值根据需求可以调整，数据越小，用户摇动的动作就越小，越容易激活，反之加大难度，但不容易误触发）
  if (accelerameter > 1.0f) {
    //立即停止更新加速仪（很重要！）
    NSLog(@"motion shake");
    [[BackgroundAudioPlay sharedInstance] playSound];
  }
}

//默认是NO，所以得重写此方法，设成YES
- (BOOL)canBecomeFirstResponder {
  return NO;
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
  NSLog(@"shake");
  //  if (self.aSwitch && self.groupId) {
  //    [self.request sendMsg11Or13:self.aSwitch
  //                  socketGroupId:self.groupId
  //                       sendMode:ActiveMode];
  //  }
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event {
}

#pragma mark - 通知
- (void)applicationWillEnterForegroundNotification:(NSNotification *)notif {
  if (self.manager) {
    [self.manager stopDeviceMotionUpdates];
  }
}

- (void)applicationDidEnterBackgroundNotification:(NSNotification *)notif {
  [self.manager startDeviceMotionUpdatesToQueue:self.motionQueue
                                    withHandler:^(CMDeviceMotion *motion,
                                                  NSError *error) {
                                        [self motionMethod:motion];
                                    }];
}

#pragma mark - Screen Lock Event
// call back
static void displayStatusChanged(CFNotificationCenterRef center, void *observer,
                                 CFStringRef name, const void *object,
                                 CFDictionaryRef userInfo) {
  // the "com.apple.springboard.lockcomplete" notification will always come
  // after the "com.apple.springboard.lockstate" notification

  NSString *lockState = (NSString *)CFBridgingRelease(name);
  NSLog(@"Darwin notification NAME = %@", name);

  if ([lockState isEqualToString:@"com.apple.springboard.lockcomplete"]) {
    NSLog(@"DEVICE LOCKED");
  } else if ([lockState isEqualToString:@"com.apple.iokit.hid.displayStatus"]) {
    if (userInfo != nil) {
      CFShow(userInfo);
    }
  } else if ([lockState
                 isEqualToString:@"com.apple.springboard.hasBlankedScreen"]) {
    if (userInfo != nil) {
      CFShow(userInfo);
    }
  } else {
    NSLog(@"LOCK STATUS CHANGED");
  }
}

- (void)registerforDeviceLockNotif {
  // Screen lock notifications
  CFNotificationCenterAddObserver(
      CFNotificationCenterGetDarwinNotifyCenter(), // center
      NULL,                                        // observer
      displayStatusChanged,                        // callback
      CFSTR("com.apple.springboard.lockcomplete"), // event name
      NULL,                                        // object
      CFNotificationSuspensionBehaviorDeliverImmediately);

  CFNotificationCenterAddObserver(
      CFNotificationCenterGetDarwinNotifyCenter(), // center
      NULL,                                        // observer
      displayStatusChanged,                        // callback
      CFSTR("com.apple.springboard.lockstate"),    // event name
      NULL,                                        // object
      CFNotificationSuspensionBehaviorDeliverImmediately);
  CFNotificationCenterAddObserver(
      CFNotificationCenterGetDarwinNotifyCenter(), // center
      NULL,                                        // observer
      displayStatusChanged,                        // callback
      CFSTR("com.apple.iokit.hid.displayStatus"),  // event name
      NULL,                                        // object
      CFNotificationSuspensionBehaviorDeliverImmediately);
  CFNotificationCenterAddObserver(
      CFNotificationCenterGetDarwinNotifyCenter(),     // center
      NULL,                                            // observer
      displayStatusChanged,                            // callback
      CFSTR("com.apple.springboard.hasBlankedScreen"), // event name
      NULL,                                            // object
      CFNotificationSuspensionBehaviorDeliverImmediately);
}
@end
