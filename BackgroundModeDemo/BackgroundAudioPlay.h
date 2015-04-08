//
//  BackgroundAudioPlay.h
//  winmin 3.0
//
//  Created by sdzg on 15-1-13.
//  Copyright (c) 2015年 itouchco.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BackgroundAudioPlay : NSObject
+ (instancetype)sharedInstance;
- (void)playSound;
@end
