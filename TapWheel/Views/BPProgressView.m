//
//  BPProgressView.m
//  TapWheel
//
//  Created by Bruno Philipe on 9/27/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import "BPProgressView.h"

@implementation BPProgressView

- (void)setProgress:(CGFloat)progress
{
	_progress = progress;
	[self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
	//// General Declarations
	static float dx = 0;
	CGContextRef context = UIGraphicsGetCurrentContext();

	//// Color Declarations
	UIColor* glowColor = [UIColor colorWithRed: 0.157 green: 0.518 blue: 0.686 alpha: 1];

	//// Shadow Declarations
	UIColor* shadow = [[UIColor blackColor] colorWithAlphaComponent: 0.53];
	CGSize shadowOffset = CGSizeMake(0.1, 1.1);
	CGFloat shadowBlurRadius = 3.5;
	UIColor* glow = [glowColor colorWithAlphaComponent: 0.84];
	CGSize glowOffset = CGSizeMake(0.1, 1.1);
	CGFloat glowBlurRadius = 1.5;

	//// Image Declarations
	UIImage* background = [UIImage imageNamed: @"progressBackground"];
	UIColor* backgroundPattern = [UIColor colorWithPatternImage: background];
	UIImage* progress = [UIImage imageNamed: @"progressBar"];
	UIColor* progressPattern = [UIColor colorWithPatternImage: progress];

	//// Rectangle Drawing
	CGRect rectangleRect = self.bounds;
	rectangleRect.origin = CGPointMake(3, 2);
	rectangleRect.size = CGSizeMake(rectangleRect.size.width - 6.0, rectangleRect.size.height - 7.0);
	UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect:rectangleRect];
	CGContextSaveGState(context);
	CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow.CGColor);
	CGContextSaveGState(context);
	CGContextSetPatternPhase(context, CGSizeMake(0, 0));
	[backgroundPattern setFill];
	[rectanglePath fill];
	CGContextRestoreGState(context);
	CGContextRestoreGState(context);

	//// Rectangle 2 Drawing
	CGRect progressRect = rectangleRect;
	progressRect.size.width *= self.progress;
	UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRect:progressRect];
	CGContextSaveGState(context);
	CGContextSetShadowWithColor(context, glowOffset, glowBlurRadius, glow.CGColor);
	CGContextSaveGState(context);
	CGContextSetPatternPhase(context, CGSizeMake(dx-=0.3, 0));
	[progressPattern setFill];
	[rectangle2Path fill];
	CGContextRestoreGState(context);
	CGContextRestoreGState(context);

	if (dx<=-8)
		dx = 0;
}

@end
