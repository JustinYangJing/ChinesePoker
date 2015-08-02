//
//  BNRGobangView.h
//  AuoLayout
//
//  Created by IT_yangjing on 15/1/26.
//  Copyright (c) 2015年 IT_yangjing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "common.h"
@protocol BNRGobangViewDelegate;

@interface BNRGobangView : UIView 
@property (weak,nonatomic)id <BNRGobangViewDelegate>delegate;
@property (nonatomic,assign) BOOL isBaiZiFirst;
@property (nonatomic,assign) NSInteger role; //role=0  local player is baizi, role = 1  heizi

- (void)undoPreviousStep;
- (void)restart;
- (void)enableBoard:(BOOL)enable;
- (void)moveWithX:(int)x withY:(int)y;
@end

@protocol BNRGobangViewDelegate <NSObject>
- (void)notificateWin:(NSString *)whoWin;
@optional
-(void)gobangView:(BNRGobangView *)view tapAtIndexPath:(NSIndexPath *)path;
@end
