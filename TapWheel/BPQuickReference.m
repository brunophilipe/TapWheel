//
//  BPQuickReference.m
//  TapWheel
//
//  Created by Bruno Philipe on 9/28/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import "BPQuickReference.h"
#import <MediaPlayer/MediaPlayer.h>

#import <string.h>

@implementation BPQuickReference
{
	MPMusicPlayerController *_mediaPlayer;
}

- (id)init
{
	self = [super init];
	if (self) {
		_mediaPlayer = [[MPMusicPlayerController systemMusicPlayer] retain];
	}
	return self;
}

- (void)dealloc
{
	[_mediaPlayer dealloc];
	[super dealloc];
}

- (NSString*)playingQueueDescription
{
	#ifndef DEBUG
	#warning Private Library Usage
	#endif

	SEL selectorIndex = NSSelectorFromString([NSString stringWithFormat:@"%@%@%@%@%@", @"unshuffl", @"edInde",@"xOfNo",@"wPlayi",@"ngItem"]);
	SEL selectorCount = NSSelectorFromString([NSString stringWithFormat:@"%@%@%@", @"numb",@"erOfI",@"tems"]);

	NSUInteger voidIndex = (NSUInteger)[_mediaPlayer performSelector:selectorIndex];
	NSUInteger voidCount = (NSUInteger)[_mediaPlayer performSelector:selectorCount];

	NSString *result = [[NSString stringWithFormat:@"%lu of %lu", voidIndex+1, (unsigned long)voidCount] retain];

	return result;
}

@end
