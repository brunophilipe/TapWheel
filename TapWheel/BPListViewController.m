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

#include <AudioToolbox/AudioToolbox.h>

#define BPTock() (AudioServicesPlaySystemSound(1105))

@interface BPListViewController ()

@property (strong) NSArray *elements;
@property (strong) NSDictionary *menuStructure;
@property (strong) NSString *displayProperty;

@property NSUInteger selectedRow;

@property BOOL didAppear;

@end

@implementation BPListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

	if ([self.contentID isEqualToString:@"root"]) {
		self.elements = @[@"Music", @"Videos", @"Photos", @"Podcasts", @"Extras", @"Settings", @"Shuffle Songs", @"Now Playing"];
	} else if ([self.contentID isEqualToString:@"music"]) {
		self.elements = @[@"Playlists", @"Artists", @"Albums", @"Songs", @"Podcasts", @"Genres", @"Composers", @"Audiobooks"];
	} else if ([self.contentID isEqualToString:@"artists"]) { //Artists have no higher level grouping
		self.elements = [[BPMediaLibrary sharedLibrary] listArtists];
		self.displayProperty = MPMediaItemPropertyArtist;
	}
	else if ([self.contentID isEqualToString:@"songs"]) //Songs have three kinds of groupings for now: all songs, all songs by artist or songs from a certain album
	{
		if (self.contentPredicateValue) {
			if ([self.contentPredicateKey isEqualToString:MPMediaItemPropertyAlbumPersistentID]) { //Show songs from an album
				self.elements = [[BPMediaLibrary sharedLibrary] listSongsByAlbum:self.contentPredicateValue];
			} else if ([self.contentPredicateKey isEqualToString:MPMediaItemPropertyAlbumArtistPersistentID]) { // Show all songs by an artist
				self.elements = [[BPMediaLibrary sharedLibrary] listSongsByArtist:self.contentPredicateValue];
			}
			self.displayProperty = MPMediaItemPropertyTitle;
		} else { //Show ALL songs
			self.elements = [[BPMediaLibrary sharedLibrary] listSongs];
			self.displayProperty = MPMediaItemPropertyTitle;
		}
	}
	else if ([self.contentID isEqualToString:@"albums"]) // Albums two kinds of groupings: all albums and albums by an artist
	{
		if (self.contentPredicateValue) {
			self.elements = [[BPMediaLibrary sharedLibrary] listAlbumsByArtist:self.contentPredicateValue];
		} else {
			self.elements = [[BPMediaLibrary sharedLibrary] listAlbums];
		}
		self.displayProperty = MPMediaItemPropertyAlbumTitle;
	}

	_selectedRow = 1;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	NSUInteger previousRow = _selectedRow;
	_selectedRow = 0;
	[self selectRow:previousRow];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)selectRow:(NSUInteger)row
{
	NSUInteger newRow = MIN(MAX(row, 1), self.elements.count);
//	if (_selectedRow != newRow) {
		_selectedRow = newRow;
		[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:_selectedRow inSection:0] animated:NO scrollPosition:UITableViewScrollPositionBottom];
		return YES;
//	}

	return NO;
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
	BOOL returnVal = [self selectRow:_selectedRow-1];
	if (returnVal) BPTock();
	return returnVal;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.elements.count + 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *identifier_title = @"cell_title";
	static NSString *identifier_row = @"cell_row";

	NSString *identifier;

	if (indexPath.row == 0) {
		identifier = identifier_title;
	} else {
		identifier = identifier_row;
	}

    BPiPodTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];

    // Configure the cell...
	if (indexPath.row > 0) {
		id element = [self.elements objectAtIndex:indexPath.row - 1];
		
		if ([element isKindOfClass:[NSString class]]) {
			[cell.titleLabel setText:element];
		} else if ([element isKindOfClass:[MPContentItem class]]) {
			[cell.titleLabel setText:[element title]];
		} else if ([element isKindOfClass:[MPMediaItem class]]) {
			[cell.titleLabel setText:[element valueForProperty:self.displayProperty]];
		} else if ([element isKindOfClass:[MPMediaItemCollection class]]) {
			[cell.titleLabel setText:[[element representativeItem] valueForProperty:self.displayProperty]];
		}
	}

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [self tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row == 0) {
		return 18.0;
	} else {
		return 20.0;
	}
}

#pragma mark - BPNavigateable

- (void)gotoNextLevel
{
	NSString *selectedItem = [self.elements objectAtIndex:_selectedRow-1];

	if ([self.contentID isEqualToString:@"artists"]) {
		[self performSegueWithIdentifier:@"show_albums" sender:self];
	} else if ([self.contentID isEqualToString:@"albums"]) {
		[self performSegueWithIdentifier:@"show_songs" sender:self];
	} else if ([selectedItem isKindOfClass:[MPMediaItem class]]) {
		[[BPMediaPlayer sharedPlayer] playCollection:[MPMediaItemCollection collectionWithItems:self.elements] withCurrentItemIndex:_selectedRow-1];
		[self.navigationController pushViewController:[BPPlayingViewController sharedPlayingViewController] animated:YES];
	} else if ([selectedItem isEqual:@"Now Playing"]) {
		[self.navigationController pushViewController:[BPPlayingViewController sharedPlayingViewController] animated:YES];
	} else {
		[self performSegueWithIdentifier:[NSString stringWithFormat:@"show_%@", [selectedItem lowercaseString]] sender:self];
	}
}

- (void)gotoPreviousLevel
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([self.contentID isEqualToString:@"artists"]) {
		// Going to show albums
		MPMediaItemCollection *selectedItem = [self.elements objectAtIndex:_selectedRow-1];
		[(BPListViewController*)segue.destinationViewController setContentPredicateKey:MPMediaItemPropertyAlbumArtistPersistentID];
		[(BPListViewController*)segue.destinationViewController setContentPredicateValue:@([[selectedItem representativeItem] albumArtistPersistentID])];
	} else if ([self.contentID isEqualToString:@"albums"]) {
		// Going to show songs
		MPMediaItemCollection *selectedItem = [self.elements objectAtIndex:_selectedRow-1];
		[(BPListViewController*)segue.destinationViewController setContentPredicateKey:MPMediaItemPropertyAlbumPersistentID];
		[(BPListViewController*)segue.destinationViewController setContentPredicateValue:@([[selectedItem representativeItem] albumPersistentID])];
	}
}

@end
