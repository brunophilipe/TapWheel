//
//  BPGradientView.h
//  TapWheel
//
//  Created by Bruno Philipe on 9/25/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BPGradientView : UIView

- (id)initWithFrame:(CGRect)frame topColor:(UIColor*)topColor andBottomColor:(UIColor*)bottomColor;

- (void)setGradientTopColor:(UIColor*)topColor;
- (void)setGradientBottomColor:(UIColor*)bottomColor;

@end
