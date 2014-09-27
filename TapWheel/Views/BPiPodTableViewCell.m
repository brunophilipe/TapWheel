//
//  BPiPodTableViewCell.m
//  TapWheel
//
//  Created by Bruno Philipe on 9/24/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import "BPiPodTableViewCell.h"
#import "BPGradientView.h"

@implementation BPiPodTableViewCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		self.selectedBackgroundView = [[BPGradientView alloc] initWithFrame:self.bounds
																   topColor:[UIColor colorWithRed: 0.329 green: 0.667 blue: 0.796 alpha: 1]
															 andBottomColor:[UIColor colorWithRed: 0.125 green: 0.525 blue: 0.82 alpha: 1]];
	}
	return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	[super setSelected:selected animated:animated];

	[self.titleLabel setTextColor:selected ? [UIColor whiteColor] : [UIColor blackColor]];
}

@end
