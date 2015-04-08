//
//  AppDelegate.m
//  BackgroundModeDemo
//
//  Created by sdzg on 15-1-13.
//  Copyright (c) 2015年 itouchco.com. All rights reserved.
//

#import "AppDelegate.h"
#import "DetailViewController.h"
#import "BackgroundAudioPlay.h"
#import "ShakeWindow.h"

@interface AppDelegate ()
@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundUpdateTask;
@property (nonatomic, strong) NSTimer *backgroundTimer;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Override point for customization after application launch.
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state.
  // This can occur for certain types of temporary interruptions (such as an
  // incoming phone call or SMS message) or when the user quits the application
  // and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down
  // OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate
  // timers, and store enough application state information to restore your
  // application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called
  // instead of applicationWillTerminate: when the user quits.

  self.backgroundUpdateTask = [[UIApplication sharedApplication]
      beginBackgroundTaskWithExpirationHandler:nil];
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),
                 dispatch_get_main_queue(), ^{ [self startBackgroundTimer]; });
}

- (void)startBackgroundTimer {
  self.backgroundTimer = [NSTimer timerWithTimeInterval:60
                                                 target:self
                                               selector:@selector(tik)
                                               userInfo:nil
                                                repeats:YES];
  [self.backgroundTimer fire];
  [[NSRunLoop mainRunLoop] addTimer:self.backgroundTimer
                            forMode:NSRunLoopCommonModes];
}

- (void)endBackgroundTimer {
  if (self.backgroundTimer) {
    [self.backgroundTimer invalidate];
    self.backgroundTimer = nil;
  }
}

- (void)tik {
  NSTimeInterval leftSeconds =
      [[UIApplication sharedApplication] backgroundTimeRemaining];
  NSLog(@"applicationDidEnterBackground left seconds is %f", leftSeconds);
  if ([[UIApplication sharedApplication] backgroundTimeRemaining] < 61.0) {
    [[BackgroundAudioPlay sharedInstance] playSound];
    self.backgroundUpdateTask = [[UIApplication sharedApplication]
        beginBackgroundTaskWithExpirationHandler:nil];
  }
}

- (void)endBackgroundUpdateTask {
  [[UIApplication sharedApplication]
      endBackgroundTask:self.backgroundUpdateTask];
  self.backgroundUpdateTask = UIBackgroundTaskInvalid;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the inactive state;
  // here you can undo many of the changes made on entering the background.
  [self endBackgroundTimer];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Restart any tasks that were paused (or not yet started) while the
  // application was inactive. If the application was previously in the
  // background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if
  // appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - shake
- (ShakeWindow *)window {
  static ShakeWindow *shakeWindow = nil;
  if (!shakeWindow)
    shakeWindow =
        [[ShakeWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  return shakeWindow;
}
@end
