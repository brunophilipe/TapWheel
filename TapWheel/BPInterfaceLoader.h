//
//  BPInterfaceLoader.h
//  TapWheel
//
//  Created by Bruno Philipe on 2/11/16.
//  Copyright © 2016 Bruno Philipe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BPTitleView.h"

typedef NS_ENUM(NSUInteger, BPInterfaceStyle)
{
	BlueAndGrey,
	Color
};

@interface BPInterfaceLoader : NSObject

+ (UIStoryboard*)loadStoryboardForStyle:(BPInterfaceStyle)style;
+ (BPTitleView*)loadTitleViewForStyle:(BPInterfaceStyle)style;

+ (BPInterfaceStyle)getCurrentStyle;

@end
