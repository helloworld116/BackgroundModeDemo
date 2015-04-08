//
//  BackgroundAudioPlay.m
//  winmin 3.0
//
//  Created by sdzg on 15-1-13.
//  Copyright (c) 2015年 itouchco.com. All rights reserved.
//

#import "BackgroundAudioPlay.h"
#import <AVFoundation/AVFoundation.h>

@interface BackgroundAudioPlay ()
@property (nonatomic, strong) NSURL *musicUrl;
@property (nonatomic, strong) AVAudioPlayer *player;
@end

@implementation BackgroundAudioPlay

+ (instancetype)sharedInstance {
  static BackgroundAudioPlay *instance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken,
                ^{ instance = [[BackgroundAudioPlay alloc] init]; });
  return instance;
}

- (id)init {
  self = [super init];
  if (self) {
    NSString *musicPath =
        [[NSBundle mainBundle] pathForResource:@"glass" ofType:@"wav"];
    self.musicUrl = [[NSURL alloc] initFileURLWithPath:musicPath];
    self.player =
        [[AVAudioPlayer alloc] initWithContentsOfURL:self.musicUrl error:nil];
    [[AVAudioSession sharedInstance]
        setCategory:AVAudioSessionCategoryPlayback
        withOptions:AVAudioSessionCategoryOptionMixWithOthers
              error:nil];
  }
  return self;
}

- (void)playSound {
  [self.player prepareToPlay];
  self.player.volume = 0.1;
  self.player.numberOfLoops = 0;
  [self.player play];
}
@end
