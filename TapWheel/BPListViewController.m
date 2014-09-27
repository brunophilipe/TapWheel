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

@interface BPListViewController ()

@property (strong) NSArray *elements;
@property NSUInteger selectedRow;

@property (strong) NSDictionary *menuStructure;
@property (strong) NSString *displayProperty;

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
	} else if ([self.contentID isEqualToString:@"artists"]) {
		self.elements = [[BPMediaLibrary sharedLibrary] listArtists];
		self.displayProperty = MPMediaItemPropertyArtist;
	} else if ([self.contentID isEqualToString:@"songs"]) {
		self.elements = [[BPMediaLibrary sharedLibrary] listSongs];
		self.displayProperty = MPMediaItemPropertyTitle;
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[self selectRow:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)selectRow:(NSUInteger)row
{
	NSUInteger newRow = MIN(MAX(row, 1), self.elements.count);
	if (_selectedRow != newRow) {
		_selectedRow = newRow;
		[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:_selectedRow inSection:0] animated:NO scrollPosition:UITableViewScrollPositionBottom];
		return YES;
	}

	return NO;
}

- (BOOL)selectNextRow
{
	return [self selectRow:_selectedRow+1];
}

- (BOOL)selectPreviousRow
{
	return [self selectRow:_selectedRow-1];
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
		self.elements = [[BPMediaLibrary sharedLibrary] listArtists];
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

@end
