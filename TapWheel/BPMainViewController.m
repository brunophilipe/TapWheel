//
//  ViewController.m
//  TapWheel
//
//  Created by Bruno Philipe on 9/24/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import "BPMainViewController.h"
#import "BPClickWheelView.h"
#import "BPListViewController.h"
#import "BPProtocols.h"
#import "BPMediaPlayer.h"

@interface BPMainViewController () <BPClickWheelViewDelegate>

@property (strong, nonatomic) IBOutlet BPClickWheelView *clickWheel;
@property (strong, nonatomic) IBOutlet UIView *containerView;

@property (strong) UIViewController *screenViewController;

@end

@implementation BPMainViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self.clickWheel setDelegate:self];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskPortrait;
}

- (id<BPScrollable>)topScrollableController
{
	UIViewController *controller = [(UINavigationController*)self.screenViewController topViewController];
	if ([controller conformsToProtocol:@protocol(BPScrollable)]) {
		return (id)controller;
	}
	return nil;
}

- (id<BPNavigateable>)topNavigateableViewController
{
	UIViewController *controller = [(UINavigationController*)self.screenViewController topViewController];
	if ([controller conformsToProtocol:@protocol(BPNavigateable)]) {
		return (id)controller;
	}
	return nil;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	return UIStatusBarStyleLightContent;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"embed_ui_controller"])
	{
		[self setScreenViewController:[segue destinationViewController]];
	}
}

#pragma mark - Click Wheel Delegate

- (void)clickWheel:(BPClickWheelView*)clickWheel didScrollInDirection:(BPScrollDirection)direction
{
	id<BPScrollable> topScrollable = [self topScrollableController];

	switch (direction) {
		case kBPScrollDirectionDown:
			[topScrollable scrollNext];
			break;

		case kBPScrollDirectionUp:
			[topScrollable scrollPrevious];
			break;
	}
}

- (void)clickWheel:(BPClickWheelView*)clickWheel didPerformClickAction:(BPClickWheelAction)action
{
	id<BPNavigateable> topNavigateable = [self topNavigateableViewController];

	switch (action) {
		case kBPClickWheelActionSelect:
			if (topNavigateable) [topNavigateable gotoNextLevel];
			break;

		case kBPClickWheelActionMenu:
			if (topNavigateable) [topNavigateable gotoPreviousLevel];
			break;

		case kBPClickWheelActionSkipNext:
			[[BPMediaPlayer sharedPlayer] skipToNextItem];
			break;

		case kBPClickWheelActionSkipPrevious:
			[[BPMediaPlayer sharedPlayer] skipToPreviousItem];
			break;

		case kBPClickWheelActionPlayPause:
			[[BPMediaPlayer sharedPlayer] playPause];
			break;

		default:
			break;
	}
}

- (void)clickWheel:(BPClickWheelView*)clickWheel didBeginHoldAction:(BPClickWheelAction)action
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)clickWheel:(BPClickWheelView*)clickWheel didFinishHoldAction:(BPClickWheelAction)action
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)clickWheelDidCancelHoldActions:(BPClickWheelView *)clickWheel
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end
