//
//  BPMediaLibraryManager.m
//  TapWheel
//
//  Created by Bruno Philipe on 9/25/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import "BPMediaLibrary.h"

@interface BPMediaLibrary ()

@end

@implementation BPMediaLibrary

+ (BPMediaLibrary *)sharedLibrary
{
	@synchronized(self)
	{
		static dispatch_once_t once;
		static BPMediaLibrary *instance;
		dispatch_once(&once, ^ { instance = [[BPMediaLibrary alloc] init]; });
		return instance;
	}
}

- (id)init
{
	self = [super init];
	if (self) {
	}
	return self;
}

- (NSArray*)listArtists
{
	MPMediaQuery *query = [MPMediaQuery artistsQuery];
	[query setGroupingType:MPMediaGroupingAlbumArtist];
	return [query collections];
}

- (NSArray*)listSongs
{
	return [self listSongsByArtist:nil];
}

- (NSArray*)listSongsByArtist:(NSString *)artist
{
	MPMediaQuery *query = [MPMediaQuery songsQuery];
	if (artist) [query addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:artist forProperty:MPMediaItemPropertyAlbumArtistPersistentID]];
	return [query items];
}

@end
