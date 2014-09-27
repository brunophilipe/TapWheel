//
//  BPPlayingViewController.m
//  TapWheel
//
//  Created by Bruno Philipe on 9/27/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import "BPPlayingViewController.h"
#import "BPMediaPlayer.h"
#import "BPProgressView.h"

#import <MediaPlayer/MediaPlayer.h>

short signum(double x);

@interface BPPlayingViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *albumArtworkView;
@property (strong, nonatomic) IBOutlet UILabel *label_trackNumber;
@property (strong, nonatomic) IBOutlet UILabel *label_trackTitle;
@property (strong, nonatomic) IBOutlet UILabel *label_artistName;
@property (strong, nonatomic) IBOutlet UILabel *label_albumName;

@property (strong, nonatomic) IBOutlet UILabel *label_currentTime;
@property (strong, nonatomic) IBOutlet UILabel *label_songLength;
@property (strong, nonatomic) IBOutlet BPProgressView *progressView;

@property (strong) NSTimer *playbackInfoUpdateTimer;

@end

@implementation BPPlayingViewController

+ (BPPlayingViewController *)sharedPlayingViewController
{
	@synchronized(self)
	{
		static dispatch_once_t once;
		static BPPlayingViewController *instance;
		dispatch_once(&once, ^ { instance = [[UIStoryboard storyboardWithName:@"MenuStructure" bundle:nil] instantiateViewControllerWithIdentifier:@"now_playing"]; });
		return instance;
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

	[[BPMediaPlayer sharedPlayer] setNotificationsReceipient:self];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self updateCurrentItemInformation];
	[self updateCurrentPlaybackInformation];

	[self setPlaybackInfoUpdateTimer:[NSTimer scheduledTimerWithTimeInterval:0.33 target:self selector:@selector(updateCurrentPlaybackInformation) userInfo:nil repeats:YES]];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

	[self.playbackInfoUpdateTimer invalidate];
	[self setPlaybackInfoUpdateTimer:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString*)formattedTimeFromTimeInterval:(NSTimeInterval)interval
{
	NSInteger hours = abs((NSInteger)interval)/3600;
	NSInteger minutes = abs((NSInteger)interval)/60;
	NSInteger seconds = (abs((NSInteger)interval) - (minutes*60));

	if (hours > 0) {
		return [NSString stringWithFormat:@"%c%01d:%02d:%02d", signum(interval) >= 0 ? '\0' : '-',  hours, minutes, seconds];
	} else {
		return [NSString stringWithFormat:@"%c%01d:%02d", signum(interval) >= 0 ? '\0' : '-',  minutes, seconds];
	}
}

- (void)updateCurrentItemInformation
{
	MPMediaItem *item = [[BPMediaPlayer sharedPlayer] nowPlayingItem];

	if (item)
	{
		NSUInteger trackNumber = [[item valueForProperty:MPMediaItemPropertyAlbumTrackNumber] unsignedIntegerValue];
		NSUInteger trackCount = [[item valueForProperty:MPMediaItemPropertyAlbumTrackCount] unsignedIntegerValue];

		[self.label_trackTitle setText:[item valueForProperty:MPMediaItemPropertyTitle]];
		[self.label_artistName setText:[item valueForProperty:MPMediaItemPropertyArtist]];
		[self.label_albumName setText:[item valueForProperty:MPMediaItemPropertyAlbumTitle]];

		if (trackNumber > 0 && trackCount > 0) {
			[self.label_trackNumber setText:[NSString stringWithFormat:@"%u of %u", trackNumber, trackCount]];
		} else if (trackNumber > 0) {
			[self.label_trackNumber setText:[NSString stringWithFormat:@"%u", trackNumber]];
		} else {
			[self.label_trackNumber setText:@""];
		}

		[self.albumArtworkView setImage:[(MPMediaItemArtwork*)[item valueForProperty:MPMediaItemPropertyArtwork] imageWithSize:self.albumArtworkView.bounds.size]];
	} else {
		[self.label_trackTitle setText:@"Nothing is Playing"];
		[self.label_artistName setText:@""];
		[self.label_albumName setText:@""];

		[self.albumArtworkView setImage:nil];
	}
}

- (void)updateCurrentPlaybackInformation
{
	MPMediaItem *item = [[BPMediaPlayer sharedPlayer] nowPlayingItem];

	if (item) {
		NSInteger itemLength = (NSInteger)[(NSNumber*)[item valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue];
		NSInteger playbackTime = (NSInteger)[[BPMediaPlayer sharedPlayer] currentPlaybackTime];

		[self.label_songLength setText:[self formattedTimeFromTimeInterval:playbackTime - itemLength]];
		[self.label_currentTime setText:[self formattedTimeFromTimeInterval:playbackTime]];
		[self.progressView setProgress:playbackTime/(double)itemLength];
	} else {
		[self.label_songLength setText:@"0:00"];
		[self.label_currentTime setText:@"0:00"];
		[self.progressView setProgress:0.0];
	}
}

#pragma Mark - Player State Changes Notifications

- (void)playerStateChangedNotification:(NSNotification *)notification
{
	[self updateCurrentItemInformation];
	[self updateCurrentPlaybackInformation];
}

#pragma mark - BPNavigateable

- (void)gotoNextLevel
{
	//There's no next level.
	//TODO: Toggle volume control.
	return;
}

- (void)gotoPreviousLevel
{
	[self.navigationController popViewControllerAnimated:YES];
}

@end

short signum(double x)
{
	return x == 0 ? 0 : (x > 0 ? 1 : -1);
}
