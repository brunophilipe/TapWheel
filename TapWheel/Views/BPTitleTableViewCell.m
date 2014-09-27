//
//  BPTitleTableViewCell.m
//  TapWheel
//
//  Created by Bruno Philipe on 9/24/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import "BPTitleTableViewCell.h"
#import "BPGradientView.h"

@implementation BPTitleTableViewCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		self.backgroundView = [[BPGradientView alloc] initWithFrame:self.bounds
														   topColor:[UIColor colorWithRed: 0.978 green: 0.978 blue: 0.978 alpha: 1]
													 andBottomColor:[UIColor colorWithRed: 0.718 green: 0.710 blue: 0.714 alpha: 1]];
	}
	return self;
}


@end
