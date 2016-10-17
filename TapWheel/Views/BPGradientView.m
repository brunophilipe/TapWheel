//
//  BPGradientView.m
//  TapWheel
//
//  Created by Bruno Philipe on 9/25/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import "BPGradientView.h"

@implementation BPGradientView

- (id)initWithFrame:(CGRect)frame topColor:(UIColor*)topColor andBottomColor:(UIColor*)bottomColor
{
	self = [super initWithFrame:frame];
	if (self) {
		[self setGradientTopColor:topColor];
		[self setGradientBottomColor:bottomColor];
	}
	return self;
}

- (void)setGradientTopColor:(UIColor*)topColor
{
	_topColor = topColor;
}

- (void)setGradientBottomColor:(UIColor*)bottomColor
{
	_bottomColor = bottomColor;
}

- (void)drawRect:(CGRect)rect
{
	// Drawing code
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = UIGraphicsGetCurrentContext();

	//// Color Declarations
	if (!_topColor || !_bottomColor) {
		_topColor = [UIColor colorWithRed: 0.978 green: 0.978 blue: 0.978 alpha: 1];
		_bottomColor = [UIColor colorWithRed: 0.718 green: 0.71 blue: 0.714 alpha: 1];
	}

	//// Gradient Declarations
	NSArray *gradientColors = [NSArray arrayWithObjects:(id)_topColor.CGColor, (id)_bottomColor.CGColor, nil];
	CGFloat gradientLocations[] = {0, 1};
	CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, gradientLocations);

	//// Rectangle Drawing
	UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect:rect];
	CGContextSaveGState(context);
	[rectanglePath addClip];
	CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 0), CGPointMake(0, rect.size.height), 0);
	CGContextRestoreGState(context);
}

@end
