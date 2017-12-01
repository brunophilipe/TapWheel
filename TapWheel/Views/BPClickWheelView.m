//
//  BPClickWheelView.m
//  TapWheel
//
//  Created by Bruno Philipe on 9/24/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import "BPClickWheelView.h"

#define BPDegreesToRadians(x) (x * (M_PI/180.0))
#define kBPDialSegmentSize 20.0
#define kBPLongPressRoamingLimit 10.0

BOOL BPEllipsisWithRectContainsPoint(CGRect rect, CGPoint point);

@interface BPClickWheelView () <UIGestureRecognizerDelegate>

@property (strong) UITapGestureRecognizer *tapRecognizer;
@property (strong) NSTimer *longPressTimer;

@property CGPoint longPressInitialPosition;
@property BOOL didTriggerLongPress;

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

	[self setLongPressInitialPosition:CGPointMake(-1.0, -1.0)];
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

	return angle;
}

- (BPClickWheelAction)actionForTouchWithRadian:(CGFloat)radian
{
	BPClickWheelAction action;

	if (radian > BPDegreesToRadians(45) && radian <= BPDegreesToRadians(135)) { //North, menu button
		action = kBPClickWheelActionMenu;
	} else if (radian > BPDegreesToRadians(135) && radian <= BPDegreesToRadians(225)) { //East, skip previous button
		action = kBPClickWheelActionSkipPrevious;
	} else if (radian > BPDegreesToRadians(225) && radian <= BPDegreesToRadians(315)) { //South, play/pause button
		action = kBPClickWheelActionPlayPause;
	} else { //East, skip next button
		action = kBPClickWheelActionSkipNext;
	}

	return action;
}

//- (void)drawRect:(CGRect)rect
//{
//	CGRect centerButtonArea = CGRectMake(58, 58, 64, 64);
//	[[[UIColor grayColor] colorWithAlphaComponent:0.8] setFill];
//
//	UIRectFill(centerButtonArea);
//}

- (void)longPressTimerFired
{
	if (self.longPressInitialPosition.x >= 0 && self.longPressInitialPosition.y >= 0) {
		[self.delegate clickWheel:self didBeginHoldAction:[self actionForTouchWithRadian:[self radianFromCenterForTapAtLocation:self.longPressInitialPosition]]];
		[self setLongPressTimer:nil];
		[self setDidTriggerLongPress:YES];
	}
}

#pragma mark - Touch Events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
	[self setLongPressInitialPosition:[[touches anyObject] locationInView:self]];
	[self setDidTriggerLongPress:NO];

	if (self.longPressTimer)
		[self.longPressTimer invalidate];

	[self setLongPressTimer:[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(longPressTimerFired) userInfo:nil repeats:NO]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesMoved:touches withEvent:event];

	static short previousSector = -1;

	CGPoint tapLocation = [[touches anyObject] locationInView:self];

	// Test if long press action should cancel
	if (self.didTriggerLongPress && self.longPressInitialPosition.x >= 0 && self.longPressInitialPosition.y >= 0)
	{
		CGVector roaming = CGVectorMake(ABS(tapLocation.x - _longPressInitialPosition.x),
										ABS(tapLocation.y - _longPressInitialPosition.y));

		CGFloat linearRoaming = sqrt(pow(roaming.dx, 2) + pow(roaming.dy, 2));

		if (linearRoaming >= kBPLongPressRoamingLimit)
		{
			[self setLongPressInitialPosition:CGPointMake(-1.0, -1.0)];
			[self.delegate clickWheelDidCancelHoldActions:self];
			[self setDidTriggerLongPress:NO];
		}
	}
	else
	{
		[self.longPressTimer invalidate];
		[self setLongPressTimer:nil];
	}

	CGFloat thirdSize = [self frame].size.width / 3.0;

	if (tapLocation.x >= thirdSize && tapLocation.x <= thirdSize * 2 && tapLocation.y >= thirdSize && tapLocation.y <= thirdSize * 2)
	{
		// User tapped the middle. Do nothing.
		return;
	}

	CGFloat currentRadian = [self radianFromCenterForTapAtLocation:tapLocation];
	short currentSector = MIN(currentRadian / BPDegreesToRadians(kBPDialSegmentSize), 17);

	if (previousSector == 0 && currentSector == floor(359/kBPDialSegmentSize))
	{ // Down
		[self.delegate clickWheel:self didScrollInDirection:kBPScrollDirectionDown];
	}
	else if (previousSector == floor(359/kBPDialSegmentSize) && currentSector == 0)
	{ // Up
		[self.delegate clickWheel:self didScrollInDirection:kBPScrollDirectionUp];
	}
	else if (previousSector >= 0 && previousSector != currentSector)
	{ // General, calculate direction
		[self.delegate clickWheel:self didScrollInDirection:(previousSector > currentSector ? kBPScrollDirectionDown : kBPScrollDirectionUp)];
	}

	previousSector = currentSector;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event];

	if (self.didTriggerLongPress && self.longPressInitialPosition.x >= 0 && self.longPressInitialPosition.y >= 0) {
		[self setLongPressInitialPosition:CGPointMake(-1.0, -1.0)];
		[self.delegate clickWheel:self didFinishHoldAction:[self actionForTouchWithRadian:[self radianFromCenterForTapAtLocation:self.longPressInitialPosition]]];
		[self setDidTriggerLongPress:NO];
	}
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesCancelled:touches withEvent:event];
	[self setLongPressInitialPosition:CGPointMake(-1.0, -1.0)];
	if (self.longPressTimer)
	{
		[self.longPressTimer invalidate];
		[self setLongPressTimer:nil];
	}
}

#pragma mark - Gesture Recognizers

- (void)didTap
{
	CGRect centerButtonArea = CGRectMake(58, 58, 64, 64);
	CGPoint tapCoordinates = [self.tapRecognizer locationInView:self];

	if (BPEllipsisWithRectContainsPoint(centerButtonArea, tapCoordinates)) {
		[self.delegate clickWheel:self didPerformClickAction:kBPClickWheelActionSelect];
	} else {
		CGFloat radian = [self radianFromCenterForTapAtLocation:tapCoordinates];
		[self.delegate clickWheel:self didPerformClickAction:[self actionForTouchWithRadian:radian]];
	}
}

- (void)didPress:(UILongPressGestureRecognizer*)pressRecognizer
{
	NSLog(@"Here");
}

@end

BOOL BPEllipsisWithRectContainsPoint(CGRect rect, CGPoint point)
{
	CGPoint ellipseCenter = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
	CGVector ellispeRadii = CGVectorMake(rect.size.width/2.0, rect.size.height/2.0);
	CGFloat containment = (pow(point.x - ellipseCenter.x, 2)/pow(ellispeRadii.dx, 2)) + (pow(point.y - ellipseCenter.y, 2)/pow(ellispeRadii.dy, 2));
	return containment <= 1.0;
}
