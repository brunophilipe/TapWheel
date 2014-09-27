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

#include <AudioToolbox/AudioToolbox.h>

#define BPTock() (AudioServicesPlaySystemSound(1105))

@interface BPMainViewController () <BPClickWheelViewDelegate>

@property (strong, nonatomic) IBOutlet BPClickWheelView *clickWheel;
@property (strong, nonatomic) IBOutlet UIView *containerView;

@property (strong) UIViewController *screenViewController;

@end

@implementation BPMainViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

	[self.clickWheel setDelegate:self];

	[self setScreenViewController:[[UIStoryboard storyboardWithName:@"MenuStructure" bundle:nil] instantiateInitialViewController]];

	[self.screenViewController willMoveToParentViewController:self];
	[self.containerView addSubview:self.screenViewController.view];
	[self addChildViewController:self.screenViewController];
	[self didMoveToParentViewController:self];

	[self.screenViewController.view setFrame:self.containerView.bounds];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskPortrait;
}

- (BPListViewController*)topScreenTableViewController
{
	UIViewController *controller = [(UINavigationController*)self.screenViewController topViewController];
	if ([controller isKindOfClass:[BPListViewController class]]) {
		return (BPListViewController*)controller;
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

#pragma mark - Click Wheel Delegate

- (void)clickWheel:(BPClickWheelView*)clickWheel didScrollInDirection:(BPScrollDirection)direction
{
	BOOL didMove = NO;

	switch (direction) {
		case kBPScrollDirectionDown:
			didMove = [[self topScreenTableViewController] selectNextRow];
			break;

		case kBPScrollDirectionUp:
			didMove = [[self topScreenTableViewController] selectPreviousRow];
			break;
	}

	if (didMove) {
		BPTock();
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
