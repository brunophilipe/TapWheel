//
//  BPTitleTableViewCell.m
//  TapWheel
//
//  Created by Bruno Philipe on 9/24/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import "BPTitleTableViewCell.h"
#import "BPGradientView.h"
#import "BPProtocols.h"
#import "BPMediaPlayer.h"

@interface BPTitleTableViewCell () <BPPlayerNotificationsReceiver>

@property (strong, nonatomic) IBOutlet UIImageView *playIcon;

@end

@implementation BPTitleTableViewCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		self.backgroundView = [[BPGradientView alloc] initWithFrame:self.bounds
														   topColor:[UIColor colorWithRed: 0.978 green: 0.978 blue: 0.978 alpha: 1]
													 andBottomColor:[UIColor colorWithRed: 0.718 green: 0.710 blue: 0.714 alpha: 1]];

		[[BPMediaPlayer sharedPlayer] addNotificationsReceipient:self];
	}
	return self;
}

- (void)dealloc
{
	[[BPMediaPlayer sharedPlayer] removeNotificationsReceipient:self];
}

- (void)playerStateChangedNotification:(NSNotification *)notification
{
	[self.playIcon setHidden:[[BPMediaPlayer sharedPlayer] playerState] != MPMusicPlaybackStatePlaying];
}

@end
