//
//  BPMediaPlayer.m
//  TapWheel
//
//  Created by Bruno Philipe on 9/27/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import "BPMediaPlayer.h"

@interface BPMediaPlayer ()

@property (strong) MPMusicPlayerController *mediaPlayer;

@end

@implementation BPMediaPlayer

+ (BPMediaPlayer *)sharedPlayer
{
	@synchronized(self)
	{
		static dispatch_once_t once;
		static BPMediaPlayer *instance;
		dispatch_once(&once, ^ { instance = [[BPMediaPlayer alloc] init]; });
		return instance;
	}
}

- (id)init
{
	self = [super init];
	if (self) {
		[self setMediaPlayer:[MPMusicPlayerController systemMusicPlayer]];
	}
	return self;
}

- (void)setNotificationsReceipient:(id<BPPlayerNotificationsReceiver>)receiver
{
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

	[notificationCenter
	 addObserver: receiver
	 selector:    @selector(playerStateChangedNotification:)
	 name:        MPMusicPlayerControllerNowPlayingItemDidChangeNotification
	 object:      _mediaPlayer];

	[notificationCenter
	 addObserver: receiver
	 selector:    @selector(playerStateChangedNotification:)
	 name:        MPMusicPlayerControllerPlaybackStateDidChangeNotification
	 object:      _mediaPlayer];

	[_mediaPlayer beginGeneratingPlaybackNotifications];
}

- (void)playMediaItem:(MPMediaItem*)item
{
	[self playCollection:[MPMediaItemCollection collectionWithItems:@[item]]];
}

- (NSTimeInterval)currentPlaybackTime
{
	return self.mediaPlayer.currentPlaybackTime;
}

- (void)playCollection:(MPMediaItemCollection*)collection withCurrentItemIndex:(NSUInteger)index
{
	[self.mediaPlayer stop];
	[self.mediaPlayer setQueueWithItemCollection:collection];
	if (index > 0) {
		[self.mediaPlayer setNowPlayingItem:[[collection items] objectAtIndex:index]];
	}
	[self.mediaPlayer play];
}

- (void)playCollection:(MPMediaItemCollection*)collection
{
	[self playCollection:collection withCurrentItemIndex:0];
}

- (void)skipToNextItem
{
	[self.mediaPlayer skipToNextItem];
}

- (void)skipToPreviousItem
{
	if (self.mediaPlayer.currentPlaybackTime < 1.0)
		[self.mediaPlayer skipToBeginning];
	else
		[self.mediaPlayer skipToPreviousItem];
}

- (void)playPause
{
	if (self.mediaPlayer.playbackState == MPMusicPlaybackStatePlaying)
		[self.mediaPlayer pause];
	else
		[self.mediaPlayer play];
}

- (MPMediaItem*)nowPlayingItem
{
	return [self.mediaPlayer nowPlayingItem];
}

#pragma mark - Accessors

- (void)setRepeatMode:(MPMusicRepeatMode)repeatMode
{
	_repeatMode = repeatMode;
	[self.mediaPlayer setRepeatMode:repeatMode];
}

- (void)setShuffleMode:(MPMusicShuffleMode)shuffleMode
{
	_shuffleMode = shuffleMode;
	[self.mediaPlayer setShuffleMode:shuffleMode];
}

@end
