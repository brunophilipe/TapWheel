//
//  BPNavigationTableViewController.h
//  TapWheel
//
//  Created by Bruno Philipe on 9/24/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BPProtocols.h"

@interface BPListViewController : UITableViewController <BPNavigateable, BPScrollable>

@property (strong) NSString *contentID;

@property (strong) id contentPredicateValue;
@property (strong) NSString *contentPredicateKey;

- (BOOL)selectRow:(NSUInteger)row;

@end
