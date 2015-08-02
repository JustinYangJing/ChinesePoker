//
//  GobangPlayer.h
//  ChinesePoker
//
//  Created by IT_yangjing on 15/1/29.
//  Copyright (c) 2015年 IT_yangjing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "common.h"
@interface GobangPlayer : NSObject
@property (nonatomic,copy) NSString *name;
@property (nonatomic,strong)UIImage *avtor;
@property (nonatomic,assign) int numberOfWin;
@property (nonatomic,assign) int numberOfLose;
@property (nonatomic,strong) MCPeerID *peerID;
@property (nonatomic,copy) NSString *ID;
@end
