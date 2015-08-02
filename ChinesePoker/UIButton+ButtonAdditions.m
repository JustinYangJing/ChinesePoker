//
//  UIButton+ButtonAdditions.m
//  ChinesePoker
//
//  Created by IT_yangjing on 1/6/15.
//  Copyright (c) 2015 IT_yangjing. All rights reserved.
//

#import "UIButton+ButtonAdditions.h"
#import "UIFont+NewFont.h"
@implementation UIButton (ButtonAdditions)
- (void)buttonNewType{
    self.titleLabel.font = [UIFont STXiheiFontWithSize:20];
    UIEdgeInsets edgeInsets = {15,15,15,15};
    UIImage *buttonImg = [[UIImage imageNamed:@"Button"] resizableImageWithCapInsets:edgeInsets];
    [self setBackgroundImage:buttonImg forState:UIControlStateNormal];
    UIImage *pressedImg = [[UIImage imageNamed:@"ButtonPressed"] resizableImageWithCapInsets:edgeInsets];
    [self setBackgroundImage:pressedImg forState:UIControlStateHighlighted];
}
@end
