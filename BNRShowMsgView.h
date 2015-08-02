//
//  BNRShowMsgView.h
//  ChinesePoker
//
//  Created by IT_yangjing on 15/1/27.
//  Copyright (c) 2015年 IT_yangjing. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "XHAudioPlayerHelper.h"
#import "common.h"
@interface BNRShowMsgView : UIView <XHAudioPlayerHelperDelegate>
- (void)setAvtorImg:(UIImage *)avtor aduioFileName:(NSString *)aName textMsg:(NSString *)msg;
@end
