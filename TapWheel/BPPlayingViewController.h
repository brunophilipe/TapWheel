//
//  BPPlayingViewController.h
//  TapWheel
//
//  Created by Bruno Philipe on 9/27/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BPProtocols.h"

@interface BPPlayingViewController : UIViewController <BPNavigateable, BPScrollable, BPPlayerNotificationsReceiver>

+ (BPPlayingViewController *)sharedPlayingViewController;

@end
