//
//  BPTitleTableViewCell.m
//  TapWheel
//
//  Created by Bruno Philipe on 9/24/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import "BPTitleTableHeaderView.h"
#import "BPTitleView.h"

@interface BPTitleTableHeaderView ()

@property BPTitleView *titleView;

@end

@implementation BPTitleTableHeaderView

- (id)init
{
	self = [super init];
	if (self) {
		[self loadContent];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self loadContent];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		[self loadContent];
	}
	return self;
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithReuseIdentifier:reuseIdentifier];
	if (self) {
		[self loadContent];
	}
	return self;
}

- (void)updateIconsStatus
{
	[self.titleView updateIconsStatus];
}

- (void)setTitleString:(NSString *)title
{
	[self.titleView setTitleString:title];
}

- (void)loadContent
{
	NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"BPTitleView" owner:self options:nil];

	for (id view in views) {
		if ([view isKindOfClass:[BPTitleView class]]) {
			[self setTitleView:view];
			[self.contentView setFrame:[view bounds]];
			[self.contentView addSubview:view];
		}
	}
}

@end
