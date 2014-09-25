//
//  ViewController.m
//  TapWheel
//
//  Created by Bruno Philipe on 9/24/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import "BPMainViewController.h"
#import "BPClickWheelView.h"

@interface BPMainViewController () <BPClickWheelViewDelegate>

@property (strong, nonatomic) IBOutlet BPClickWheelView *clickWheel;

@end

@implementation BPMainViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

	[self.clickWheel setDelegate:self];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - Click Wheel Delegate

- (void)clickWheel:(BPClickWheelView*)clickWheel didScrollInDirection:(BPScrollDirection)direction
{
	NSLog(@"Scrolled %d", direction);
}

- (void)clickWheel:(BPClickWheelView*)clickWheel didPerformClickAction:(BPClickWheelAction)action
{
	NSLog(@"Action %d", action);
}

- (void)clickWheel:(BPClickWheelView*)clickWheel didBeginHoldAction:(BPClickWheelAction)action
{

}

- (void)clickWheel:(BPClickWheelView*)clickWheel didFinishHoldAction:(BPClickWheelAction)action
{

}

@end
