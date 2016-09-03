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
#import "MarqueeLabel.h"

#import <MediaPlayer/MediaPlayer.h>

short signum(double x);

@interface BPPlayingViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *albumArtworkView;
@property (strong, nonatomic) IBOutlet UILabel *label_trackNumber;
@property (strong, nonatomic) IBOutlet MarqueeLabel *label_trackTitle;
@property (strong, nonatomic) IBOutlet MarqueeLabel *label_artistName;
@property (strong, nonatomic) IBOutlet MarqueeLabel *label_albumName;

@property (strong, nonatomic) IBOutlet UILabel *label_currentTime;
@property (strong, nonatomic) IBOutlet UILabel *label_songLength;
@property (strong, nonatomic) IBOutlet BPProgressView *progressView;

@property (strong, nonatomic) IBOutlet MPVolumeView *volumeView;

@property (strong) UISlider *volumeSlider;

@property (strong) NSTimer *playbackInfoUpdateTimer;
@property (strong) NSTimer *volumeControlDisplayTimer;

@end

@implementation BPPlayingViewController

+ (BPPlayingViewController *)sharedPlayingViewController
{
	@synchronized(self)
	{
		static dispatch_once_t once;
		static BPPlayingViewController *instance;
		dispatch_once(&once, ^ { instance = [[UIStoryboard storyboardWithName:@"Interface_Color" bundle:nil] instantiateViewControllerWithIdentifier:@"now_playing"]; });
		return instance;
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

	[[BPMediaPlayer sharedPlayer] addNotificationsReceipient:self];

	[_label_trackTitle setRate:18.0];
	[_label_trackTitle setAnimationCurve:UIViewAnimationOptionCurveEaseInOut];
	[_label_artistName setRate:18.0];
	[_label_artistName setAnimationCurve:UIViewAnimationOptionCurveEaseInOut];
	[_label_albumName setRate:18.0];
	[_label_albumName setAnimationCurve:UIViewAnimationOptionCurveEaseInOut];

	[_volumeView setShowsRouteButton:NO];
	[_volumeView setVolumeThumbImage:[UIImage imageNamed:@"volume_thumb"] forState:UIControlStateNormal];
	[_volumeView setMaximumVolumeSliderImage:[UIImage imageNamed:@"progressBackground"] forState:UIControlStateNormal];
	[_volumeView setMinimumVolumeSliderImage:[UIImage imageNamed:@"progressBar"] forState:UIControlStateNormal];
	[_volumeView setOpaque:NO];
	[_volumeView setBackgroundColor:[UIColor clearColor]];

	[self setVolumeSlider:[self sliderUnderView:_volumeView]];
}

- (UISlider*)sliderUnderView:(UIView*)view
{
	UISlider *slider;
	NSArray *subviews;

	subviews = view.subviews;
	for (UIView *subview in subviews) {
		if ([subview isKindOfClass:[UISlider class]]) {
			slider = (UISlider*)subview;
		}
	}

	return slider;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	[self updateUI];

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
	NSInteger hours = labs((NSInteger)interval)/3600;
	NSInteger minutes = labs((NSInteger)interval)/60;
	NSInteger seconds = (labs((NSInteger)interval) - (minutes*60));

	if (hours > 0) {
		return [NSString stringWithFormat:@"%c%01ld:%02ld:%02ld", signum(interval) >= 0 ? '\0' : '-',  (long)hours, (long)minutes, (long)seconds];
	} else {
		return [NSString stringWithFormat:@"%c%01ld:%02ld", signum(interval) >= 0 ? '\0' : '-',  (long)minutes, (long)seconds];
	}
}

- (void)updateCurrentItemInformation
{
	MPMediaItem *item = [[BPMediaPlayer sharedPlayer] nowPlayingItem];

	if (item)
	{
		[self.label_trackTitle setText:[item valueForProperty:MPMediaItemPropertyTitle]];
		[self.label_artistName setText:[item valueForProperty:MPMediaItemPropertyArtist]];
		[self.label_albumName setText:[item valueForProperty:MPMediaItemPropertyAlbumTitle]];

		[self.label_trackNumber setText:[[BPMediaPlayer sharedPlayer] playingQueueDescription]];

		__weak typeof(self) weakself = self;

		dispatch_async(dispatch_get_main_queue(), ^{
			MPMediaItemArtwork *artwork = (MPMediaItemArtwork*)[item valueForProperty:MPMediaItemPropertyArtwork];

			if (artwork != nil && weakself != nil)
			{
				[weakself.albumArtworkView setImage:[artwork imageWithSize:weakself.albumArtworkView.bounds.size]];
			}
		});
	}
	else
	{
		[self.label_trackTitle setText:@"Nothing is Playing"];
		[self.label_artistName setText:@""];
		[self.label_albumName setText:@""];
		[self.label_trackNumber setText:@""];

		[self.albumArtworkView setImage:nil];
	}
}

- (void)updateCurrentPlaybackInformation
{
	MPMediaItem *item = [[BPMediaPlayer sharedPlayer] nowPlayingItem];

	if (item) {
		NSTimeInterval itemLength = (NSInteger)[(NSNumber*)[item valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue];
		NSTimeInterval playbackTime = (NSInteger)[[BPMediaPlayer sharedPlayer] currentPlaybackTime];

		[self.label_songLength setText:[self formattedTimeFromTimeInterval:(int)playbackTime - (int)itemLength]];
		[self.label_currentTime setText:[self formattedTimeFromTimeInterval:(int)playbackTime]];
		[self.progressView setProgress:playbackTime/itemLength];
	} else {
		[self.label_songLength setText:@"0:00"];
		[self.label_currentTime setText:@"0:00"];
		[self.progressView setProgress:0.0];
	}
}

- (void)showVolumeControl
{
	[self.volumeView setHidden:NO];

	if (self.volumeControlDisplayTimer)
		[self.volumeControlDisplayTimer setFireDate:[[NSDate date] dateByAddingTimeInterval:2.5]];
	else
		[self setVolumeControlDisplayTimer:[NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(hideVolumeControl) userInfo:nil repeats:NO]];
}

- (void)hideVolumeControl
{
	[self setVolumeControlDisplayTimer:nil];
	[self.volumeView setHidden:YES];
}

- (void)updateUI
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[self updateCurrentItemInformation];
	});

	dispatch_async(dispatch_get_main_queue(), ^{
		[self updateCurrentPlaybackInformation];
	});
}

#pragma Mark - Player State Changes Notifications

- (void)playerStateChangedNotification:(NSNotification *)notification
{
	[self updateUI];
}

#pragma mark - BPScrollable

- (BOOL)scrollNext
{
	[self showVolumeControl];
	[self.volumeSlider setValue:self.volumeSlider.value+0.025];
	return YES;
}

- (BOOL)scrollPrevious
{
	[self showVolumeControl];
	[self.volumeSlider setValue:self.volumeSlider.value-0.025];
	return YES;
}

#pragma mark - BPNavigateable

- (void)gotoNextLevel
{
	//There's no next level.
	//TODO: Toggle skip control.
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
