//
//  BPInterfaceLoader.m
//  TapWheel
//
//  Created by Bruno Philipe on 2/11/16.
//  Copyright © 2016 Bruno Philipe. All rights reserved.
//

#import "BPInterfaceLoader.h"

@implementation BPInterfaceLoader

+ (BPInterfaceStyle)getCurrentStyle
{
	return Color;
}

+ (UIStoryboard*)loadStoryboardForStyle:(BPInterfaceStyle)style
{
	NSString *storyboardName = nil;

	switch (style)
	{
		case Color:
			storyboardName = @"Interface_Color";
			break;

		case BlueAndGrey:
			storyboardName = @"Interface_BlueAndGrey";
			break;

		default:
			break;
	}

	return nil;
}

+ (BPTitleView*)loadTitleViewForStyle:(BPInterfaceStyle)style
{
	NSString *nibName = nil;

	switch (style)
	{
		case Color:
			nibName = @"BPTitleView_Color";
			break;

		case BlueAndGrey:
			nibName = @"BPTitleView_BlueAndGrey";
			break;

		default:
			break;
	}

	if (!nibName)
	{
		return nil;
	}

	NSArray *views = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];

	for (id view in views)
	{
		if ([view isKindOfClass:[BPTitleView class]])
		{
			return view;
		}
	}

	return nil;
}

@end
