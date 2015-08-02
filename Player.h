//
//  Player.h
//  ChinesePoker
//
//  Created by IT_yangjing on 1/11/15.
//  Copyright (c) 2015 IT_yangjing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
@interface Player : NSObject<NSCoding>
@property (nonatomic,copy)NSString *name;
@property (nonatomic,strong)UIImage *img;
@property (nonatomic,strong)MCPeerID *peerID;
@property (nonatomic,copy)NSString *ID;
@property (nonatomic,copy)NSString *card;
@property (nonatomic,strong)NSMutableArray *voteID;
@property (nonatomic,copy)NSString *msg;
@property (nonatomic,strong)NSData *voiceMsg;
@property (nonatomic,copy) NSString *voicePath;
@property (nonatomic,weak)UIImageView* imgView;
@property (nonatomic,weak)UIImageView *msgViewTip;
@property (nonatomic,weak)UIAttachmentBehavior *attachment;
@property (nonatomic,assign)BOOL isSpy;
@property (nonatomic,assign)BOOL isAlive;
@end
