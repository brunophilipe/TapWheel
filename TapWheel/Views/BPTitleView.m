//
//  BPTitleView.m
//  TapWheel
//
//  Created by Bruno Philipe on 9/27/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import "BPTitleView.h"
#import "BPGradientView.h"
#import "BPProtocols.h"
#import "BPMediaPlayer.h"

@interface BPTitleView () <BPPlayerNotificationsReceiver>

@property (strong, nonatomic) IBOutlet UIImageView *playIcon;
@property (strong, nonatomic) IBOutlet UIImageView *batteryIcon;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation BPTitleView

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self)
	{
		[[BPMediaPlayer sharedPlayer] addNotificationsReceipient:self];
	}
	return self;
}

- (void)dealloc
{
	[[BPMediaPlayer sharedPlayer] removeNotificationsReceipient:self];
}

- (void)updateIconsStatus
{
	[self playerStateChangedNotification:nil];
}

- (void)setTitleString:(NSString *)title
{
	[self.titleLabel setText:title];
}

- (void)playerStateChangedNotification:(NSNotification *)notification
{
	[self.playIcon setHidden:[[BPMediaPlayer sharedPlayer] playerState] != MPMusicPlaybackStatePlaying];
}

@end
