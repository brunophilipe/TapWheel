//
//  BPClickWheelView.h
//  TapWheel
//
//  Created by Bruno Philipe on 9/24/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(short, BPScrollDirection)
{
	kBPScrollDirectionUp = 1,
	kBPScrollDirectionDown
};

typedef NS_ENUM(short, BPClickWheelAction)
{
	kBPClickWheelActionSelect,
	kBPClickWheelActionMenu,
	kBPClickWheelActionSkipNext,
	kBPClickWheelActionSkipPrevious,
	kBPClickWheelActionPlayPause
};

@protocol BPClickWheelViewDelegate;

@interface BPClickWheelView : UIView

@property (weak) id<BPClickWheelViewDelegate> delegate;

@end

@protocol BPClickWheelViewDelegate <NSObject>

@required
- (void)clickWheel:(BPClickWheelView*)clickWheel didScrollInDirection:(BPScrollDirection)direction;
- (void)clickWheel:(BPClickWheelView*)clickWheel didPerformClickAction:(BPClickWheelAction)action;
- (void)clickWheel:(BPClickWheelView*)clickWheel didBeginHoldAction:(BPClickWheelAction)action;
- (void)clickWheel:(BPClickWheelView*)clickWheel didFinishHoldAction:(BPClickWheelAction)action;
- (void)clickWheelDidCancelHoldActions:(BPClickWheelView*)clickWheel;

@end
