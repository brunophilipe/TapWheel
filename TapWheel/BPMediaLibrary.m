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

#pragma mark - List Artists

- (NSArray*)listArtists
{
	MPMediaQuery *query = [MPMediaQuery artistsQuery];
	[query setGroupingType:MPMediaGroupingAlbumArtist];
	return [query collections];
}

#pragma mark - List Songs

- (NSArray*)listSongs
{
	return [self listSongsByArtist:nil];
}

- (NSArray*)listSongsByAlbum:(NSNumber*)albumPersistentID
{
	MPMediaQuery *query = [MPMediaQuery songsQuery];
	[query addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:albumPersistentID forProperty:MPMediaItemPropertyAlbumPersistentID]];
	return [query items];
}

- (NSArray*)listSongsByArtist:(NSNumber*)artistPersistentID
{
	MPMediaQuery *query = [MPMediaQuery songsQuery];
	if (artistPersistentID) {
		[query addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:artistPersistentID forProperty:MPMediaItemPropertyAlbumArtistPersistentID]];
		[query setGroupingType:MPMediaGroupingAlbum];
		return [query collections];
	} else {
		return [query items];
	}
}

- (NSArray*)listSongsInPlaylist:(NSNumber*)playlistPersistentID
{
	MPMediaQuery *query = [MPMediaQuery songsQuery];
	[query addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:playlistPersistentID forProperty:MPMediaPlaylistPropertyPersistentID]];
	NSArray *items = [query items];
	return items;
}

#pragma mark - List Albums

- (NSArray*)listAlbums
{
	return [self listAlbumsByArtist:nil];
}

- (NSArray*)listAlbumsByArtist:(NSNumber*)artistPersistentID
{
	MPMediaQuery *query = [MPMediaQuery albumsQuery];
	if (artistPersistentID) {
		[query addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:artistPersistentID forProperty:MPMediaItemPropertyAlbumArtistPersistentID]];
	}
	[query setGroupingType:MPMediaGroupingAlbum];
	return [query collections];
}

#pragma mark - List Playlists

- (NSArray*)listPlaylists
{
	MPMediaQuery *query = [MPMediaQuery playlistsQuery];
	return [query collections];
}

@end
