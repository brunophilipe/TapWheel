//
//  BPNavigationTableViewController.m
//  TapWheel
//
//  Created by Bruno Philipe on 9/24/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import "BPListViewController.h"
#import "BPiPodTableViewCell.h"
#import "BPMediaLibrary.h"
#import "BPMediaPlayer.h"
#import "BPPlayingViewController.h"
#import "BPTitleTableHeaderView.h"

#include <AudioToolbox/AudioToolbox.h>

#define BPTock() (AudioServicesPlaySystemSound(1105))

@interface BPListViewController ()

@property (strong) NSArray *elements;
@property (strong) NSDictionary *menuStructure;
@property (strong) NSString *displayProperty;

@property NSUInteger selectedRow;

@property (strong) NSString *title;

@end

@implementation BPListViewController

@dynamic title;

- (void)viewDidLoad
{
    [super viewDidLoad];

	[self.tableView registerClass:[BPTitleTableHeaderView class] forHeaderFooterViewReuseIdentifier:@"status_header"];

	if ([self.contentID isEqualToString:@"root"])
	{
		self.elements = @[@"Music", @"Videos", @"Photos", @"Podcasts", @"Extras", @"Settings", @"Shuffle Songs", @"Now Playing"];
	}
	else if ([self.contentID isEqualToString:@"music"])
	{
		self.elements = @[@"Playlists", @"Artists", @"Albums", @"Songs", @"Podcasts", @"Genres", @"Composers", @"Audiobooks"];
	}
	else if ([self.contentID isEqualToString:@"artists"])
	{
		//Artists have no higher level grouping
		self.elements = [[BPMediaLibrary sharedLibrary] listArtists];
		self.displayProperty = MPMediaItemPropertyArtist;
	}
	else if ([self.contentID isEqualToString:@"songs"])
	{
		//Songs have three kinds of groupings for now: all songs, all songs by artist or songs from a certain album
		if (self.contentPredicateValue)
		{
			if ([self.contentPredicateKey isEqualToString:MPMediaItemPropertyAlbumPersistentID])
			{
				//Show songs from an album
				self.elements = [[BPMediaLibrary sharedLibrary] listSongsByAlbum:self.contentPredicateValue];
			}
			else if ([self.contentPredicateKey isEqualToString:MPMediaItemPropertyAlbumArtistPersistentID])
			{
				// Show all songs by an artist
				self.elements = [[BPMediaLibrary sharedLibrary] listSongsByArtist:self.contentPredicateValue];
			}
			else if ([self.contentPredicateKey isEqualToString:MPMediaPlaylistPropertyPersistentID])
			{
				// Show all songs in a playlist
				self.elements = [[BPMediaLibrary sharedLibrary] listSongsInPlaylist:self.contentPredicateValue];
			}
			self.displayProperty = MPMediaItemPropertyTitle;
		}
		else
		{
			//Show ALL songs
			self.elements = [[BPMediaLibrary sharedLibrary] listSongs];
			self.displayProperty = MPMediaItemPropertyTitle;
			self.title = @"Songs";
		}
	}
	else if ([self.contentID isEqualToString:@"albums"])
	{
		// Albums have two kinds of groupings: all albums and albums by an artist
		if (self.contentPredicateValue)
		{
			self.elements = [[BPMediaLibrary sharedLibrary] listAlbumsByArtist:self.contentPredicateValue];
		}
		else
		{
			self.elements = [[BPMediaLibrary sharedLibrary] listAlbums];
		}
		self.displayProperty = MPMediaItemPropertyAlbumTitle;
	}
	else if ([self.contentID isEqualToString:@"playlists"])
	{
		//Playlists have no higher level grouping
		self.elements = [[BPMediaLibrary sharedLibrary] listPlaylists];
		self.displayProperty = MPMediaPlaylistPropertyName;
	}

	_selectedRow = 0;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	NSUInteger previousRow = _selectedRow;
	_selectedRow = 0;

	[self selectRow:previousRow];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)selectRow:(NSUInteger)row
{
	if (self.elements.count == 0)
	{
		return NO;
	}

	NSUInteger newRow = MIN(MAX(row, 0), self.elements.count-1);

	static short scrollCounter = 0;
	UITableViewScrollPosition scrollPosition = UITableViewScrollPositionNone;

	if (row > _selectedRow)
	{
		// Scroll down
		if (scrollCounter == 8)
			scrollPosition = UITableViewScrollPositionBottom;
		else
			scrollCounter++;

	}
	else if (row < _selectedRow)
	{
		// Scroll Up
		if (scrollCounter == 0)
			scrollPosition = UITableViewScrollPositionTop;
		else
			scrollCounter--;
	}

//	[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:newRow inSection:0] atScrollPosition:(newRow > _selectedRow ? UITableViewScrollPositionBottom : UITableViewScrollPositionTop) animated:NO];
	[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:newRow inSection:0] animated:NO scrollPosition:scrollPosition];//(newRow > _selectedRow ? UITableViewScrollPositionBottom : UITableViewScrollPositionTop)];

	_selectedRow = newRow;

	return YES;
}

- (BOOL)clearsSelectionOnViewWillAppear
{
	return NO;
}

- (BOOL)scrollNext
{
	BOOL returnVal = [self selectRow:_selectedRow+1];
	if (returnVal) BPTock();
	return returnVal;
}

- (BOOL)scrollPrevious
{
	if (_selectedRow == 0) return NO;
	BOOL returnVal = [self selectRow:_selectedRow-1];
	if (returnVal) BPTock();
	return returnVal;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.elements.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *identifier = @"cell_row";
    BPiPodTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];

    // Configure the cell...
	id element = [self.elements objectAtIndex:indexPath.row];
	
	if ([element isKindOfClass:[NSString class]])
	{
		[cell.titleLabel setText:element];
	}
	else if ([element isKindOfClass:[MPContentItem class]])
	{
		[cell.titleLabel setText:[element title]];
	}
	else if ([element isKindOfClass:[MPMediaItem class]])
	{
		[cell.titleLabel setText:[element valueForProperty:self.displayProperty]];
	}
	else if ([element isKindOfClass:[MPMediaPlaylist class]])
	{
		MPMediaPlaylist *playlist = element;
		[cell.titleLabel setText:[playlist valueForProperty:self.displayProperty]];
	}
	else if ([element isKindOfClass:[MPMediaItemCollection class]])
	{
		[cell.titleLabel setText:[[element representativeItem] valueForProperty:self.displayProperty]];
	}

    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	BPTitleTableHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"status_header"];
	[headerView updateIconsStatus];
	[headerView setTitleString:self.title];
	return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [self tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 20.0;
}

#pragma mark - BPNavigateable

- (void)gotoNextLevel
{
	id selectedItem = [self.elements objectAtIndex:_selectedRow];

	if ([self.contentID isEqualToString:@"artists"])
	{
		[self performSegueWithIdentifier:@"show_albums" sender:self];
	}
	else if ([self.contentID isEqualToString:@"albums"])
	{
		[self performSegueWithIdentifier:@"show_songs" sender:self];
	}
	else if ([self.contentID isEqualToString:@"playlists"])
	{
		[self performSegueWithIdentifier:@"show_songs" sender:self];
	}
	else if ([selectedItem isKindOfClass:[MPMediaItem class]])
	{
		[[BPMediaPlayer sharedPlayer] playCollection:[MPMediaItemCollection collectionWithItems:self.elements]
								withCurrentItemIndex:_selectedRow];

		[self.navigationController pushViewController:[BPPlayingViewController sharedPlayingViewController]
											 animated:YES];
	}
	else if ([selectedItem isEqual:@"Now Playing"])
	{
		[self.navigationController pushViewController:[BPPlayingViewController sharedPlayingViewController]
											 animated:YES];
	}
	else if ([selectedItem isKindOfClass:[NSString class]])
	{
		NSString *name = [NSString stringWithFormat:@"show_%@", [selectedItem lowercaseString]];

		@try
		{
			[self performSegueWithIdentifier:name sender:self];
		}
		@catch (NSException *exception)
		{
			// Oops
			NSLog(@"Oops! Tried performing non-existing segue with name: %@", name);
		}
	}
}

- (void)gotoPreviousLevel
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([self.contentID isEqualToString:@"artists"])
	{
		// Going to show albums
		MPMediaItemCollection *selectedItem = [self.elements objectAtIndex:_selectedRow];
		[(BPListViewController*)segue.destinationViewController setTitle:[[selectedItem representativeItem] valueForProperty:MPMediaItemPropertyAlbumArtist]];
		[(BPListViewController*)segue.destinationViewController setContentPredicateKey:MPMediaItemPropertyAlbumArtistPersistentID];
		[(BPListViewController*)segue.destinationViewController setContentPredicateValue:@([[selectedItem representativeItem] albumArtistPersistentID])];
	}
	else if ([self.contentID isEqualToString:@"albums"])
	{
		// Going to show songs
		MPMediaItemCollection *selectedItem = [self.elements objectAtIndex:_selectedRow];
		[(BPListViewController*)segue.destinationViewController setTitle:[[selectedItem representativeItem] valueForProperty:MPMediaItemPropertyAlbumTitle]];
		[(BPListViewController*)segue.destinationViewController setContentPredicateKey:MPMediaItemPropertyAlbumPersistentID];
		[(BPListViewController*)segue.destinationViewController setContentPredicateValue:@([[selectedItem representativeItem] albumPersistentID])];
	}
	else if ([self.contentID isEqualToString:@"playlists"])
	{
		// Going to show playlists
		MPMediaPlaylist *selectedItem = [self.elements objectAtIndex:_selectedRow];
		[(BPListViewController*)segue.destinationViewController setTitle:[selectedItem valueForProperty:MPMediaPlaylistPropertyName]];
		[(BPListViewController*)segue.destinationViewController setContentPredicateKey:MPMediaPlaylistPropertyPersistentID];
		[(BPListViewController*)segue.destinationViewController setContentPredicateValue:@([selectedItem persistentID])];
	}
}

@end
