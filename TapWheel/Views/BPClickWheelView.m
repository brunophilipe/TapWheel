//
//  BPClickWheelView.m
//  TapWheel
//
//  Created by Bruno Philipe on 9/24/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import "BPClickWheelView.h"

#define BPDegreesToRadians(x) (x * (M_PI/180.0))

BOOL BPEllipsisWithRectContainsPoint(CGRect rect, CGPoint point);
short signum(double x);

@interface BPClickWheelView ()

@property (strong) UITapGestureRecognizer *tapRecognizer;

@end

@implementation BPClickWheelView

- (id)init
{
	self = [super init];
	if (self) {
		[self configure];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self configure];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		[self configure];
	}
	return self;
}

- (void)configure
{
	// Create tap gesture recognizer
	self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap)];
	[self.tapRecognizer setNumberOfTapsRequired:1];
	[self.tapRecognizer setNumberOfTouchesRequired:1];
	[self addGestureRecognizer:self.tapRecognizer];
}

- (CGFloat)radianFromCenterForTapAtLocation:(CGPoint)location
{
	CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
	CGPoint difference = CGPointMake(location.x-center.x, location.y-center.y);
	CGFloat angle = 0.0;

	if (difference.x >= 0 && difference.y < 0) {
		angle = atan((difference.y)/(difference.x)) * -1;
	} else if (difference.x < 0 && difference.y < 0) {
		angle = M_PI - atan((difference.y)/(difference.x));
	} else if (difference.x < 0 && difference.y >= 0) {
		angle = M_PI + atan((difference.y)/(difference.x)) * -1;
	} else if (difference.x >= 0 && difference.y >= 0) {
		angle = M_PI*2 - atan((difference.y)/(difference.x));
	}

	return angle + M_PI*2;
}

//- (void)drawRect:(CGRect)rect
//{
//	CGRect centerButtonArea = CGRectMake(58, 58, 64, 64);
//	[[[UIColor grayColor] colorWithAlphaComponent:0.8] setFill];
//
//	UIRectFill(centerButtonArea);
//}

#pragma mark - Touch Events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesMoved:touches withEvent:event];

	static BOOL _processingTapSpin = NO;
	static CGFloat _rotationAccumulator = 0.0;
	static CGFloat _lastRadian = 0.0;

	CGPoint tapLocation = [[touches anyObject] locationInView:self];
	CGFloat currentRadian = [self radianFromCenterForTapAtLocation:tapLocation];

	if (!_processingTapSpin || signum(currentRadian) != signum(_lastRadian)) {
		_processingTapSpin = YES;
		_lastRadian = currentRadian;
	} else {
		_rotationAccumulator += currentRadian - _lastRadian;
		_lastRadian = currentRadian;
	}

	NSLog(@"%f", currentRadian);

	if (ABS(_rotationAccumulator) > BPDegreesToRadians(10)) { //Accumulated 10 degrees of rotation, call delegate
		[self.delegate clickWheel:self didScrollInDirection:signum(_rotationAccumulator) > 0 ? kBPScrollDirectionUp : kBPScrollDirectionDown];
		_rotationAccumulator = 0.0;
		_lastRadian = 0.0;
		_processingTapSpin = NO;
	}
}

#pragma mark - Gesture Recognizers

- (void)didTap
{
	CGRect centerButtonArea = CGRectMake(58, 58, 64, 64);
	CGPoint tapCoordinates = [self.tapRecognizer locationInView:self];

	if (BPEllipsisWithRectContainsPoint(centerButtonArea, tapCoordinates)) {
		[self.delegate clickWheel:self didPerformClickAction:kBPClickWheelActionMain];
	} else {
		CGFloat radian = [self radianFromCenterForTapAtLocation:tapCoordinates];
		if (radian > BPDegreesToRadians(45) && radian <= BPDegreesToRadians(135)) { //North, menu button
			[self.delegate clickWheel:self didPerformClickAction:kBPClickWheelActionMenu];
		} else if (radian > BPDegreesToRadians(135) && radian <= BPDegreesToRadians(225)) { //East, skip previous button
			[self.delegate clickWheel:self didPerformClickAction:kBPClickWheelActionSkipPrevious];
		} else if (radian > BPDegreesToRadians(225) && radian <= BPDegreesToRadians(315)) { //South, play/pause button
			[self.delegate clickWheel:self didPerformClickAction:kBPClickWheelActionPlayPause];
		} else { //East, skip next button
			[self.delegate clickWheel:self didPerformClickAction:kBPClickWheelActionSkipNext];
		}
	}
}

@end

BOOL BPEllipsisWithRectContainsPoint(CGRect rect, CGPoint point)
{
	CGPoint ellipseCenter = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
	CGVector ellispeRadii = CGVectorMake(rect.size.width/2.0, rect.size.height/2.0);
	CGFloat containment = (pow(point.x - ellipseCenter.x, 2)/pow(ellispeRadii.dx, 2)) + (pow(point.y - ellipseCenter.y, 2)/pow(ellispeRadii.dy, 2));
	return containment <= 1.0;
}

short signum(double x)
{
	return x == 0 ? 0 : (x > 0 ? 1 : -1);
}
