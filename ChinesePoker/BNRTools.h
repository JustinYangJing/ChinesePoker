//
//  BNRTools.h
//  ChinesePoker
//
//  Created by IT_yangjing on 1/10/15.
//  Copyright (c) 2015 IT_yangjing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface BNRTools : NSObject
+ (void) popTipMessage:(NSString *)msg withRect:(CGRect)rect inView:(UIView *)view;
+ (void) popTipMessage:(NSString *)tipStr atView:(UIView *)view;
+ (NSArray *)getQuestionFromFile;
@end
