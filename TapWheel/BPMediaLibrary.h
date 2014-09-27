//
//  BPMediaLibraryManager.h
//  TapWheel
//
//  Created by Bruno Philipe on 9/25/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface BPMediaLibrary : NSObject

+ (BPMediaLibrary *)sharedLibrary;

- (NSArray*)listArtists;
- (NSArray*)listSongs;
- (NSArray*)listSongsByArtist:(NSString*)artist;

@end
