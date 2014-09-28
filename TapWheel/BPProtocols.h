//
//  BPClickWheelResponder.h
//  TapWheel
//
//  Created by Bruno Philipe on 9/27/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BPClickWheelView.h"

@protocol BPNavigateable <NSObject>

- (void)gotoNextLevel;
- (void)gotoPreviousLevel;

@end

@protocol BPScrollable <NSObject>

- (BOOL)scrollNext;
- (BOOL)scrollPrevious;

@end

@protocol BPPlayerNotificationsReceiver <NSObject>

- (void)playerStateChangedNotification:(NSNotification*)notification;

@end
