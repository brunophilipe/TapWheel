//
//  BPMediaPlayer.h
//  TapWheel
//
//  Created by Bruno Philipe on 9/27/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import "BPProtocols.h"

@interface BPMediaPlayer : NSObject

@property (nonatomic) MPMusicRepeatMode repeatMode;
@property (nonatomic) MPMusicShuffleMode shuffleMode;

+ (BPMediaPlayer *)sharedPlayer;

- (void)addNotificationsReceipient:(id<BPPlayerNotificationsReceiver>)receiver;
- (void)removeNotificationsReceipient:(id<BPPlayerNotificationsReceiver>)receiver;

- (void)playMediaItem:(MPMediaItem*)item;
- (void)playCollection:(MPMediaItemCollection*)collection withCurrentItemIndex:(NSUInteger)index;
- (void)playCollection:(MPMediaItemCollection*)collection;

- (void)skipToNextItem;
- (void)skipToPreviousItem;
- (void)playPause;

- (NSString*)playingQueueDescription;
- (MPMusicPlaybackState)playerState;

- (MPMediaItem*)nowPlayingItem;
- (NSTimeInterval)currentPlaybackTime;

@end
