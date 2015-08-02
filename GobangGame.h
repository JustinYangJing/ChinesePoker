//
//  GobangGame.h
//  ChinesePoker
//
//  Created by IT_yangjing on 15/1/29.
//  Copyright (c) 2015年 IT_yangjing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GobangPlayer.h"

typedef NS_ENUM(NSUInteger, GobangGameState)
{
    GobangGameStateReady,
    GobangGameStateStart,
    GobangGameStateOver,
};

typedef NS_ENUM(NSUInteger, GoBangCommand)
{
    GobangUpDateProfile,
    GoBangCommandPostStart,
    GoBangCommandMoveCard,
    GoBangCommandGoBack,
};

@protocol GobangDelegate;

@interface GobangGame : NSObject <MCSessionDelegate>
@property (nonatomic,strong)GobangPlayer *localPlayer;
@property (nonatomic,strong)GobangPlayer *vsPlayer;
@property (nonatomic,strong)MCSession *session;
@property (nonatomic,assign)GobangGameState gameState;
@property (nonatomic,weak) id <GobangDelegate> delegate;
@property (nonatomic,assign)GameMode gameMode;

- (instancetype)initWithSession:(MCSession *)session withGameMode:(GameMode)gameMode;
- (void)updateProfile;
- (void)postStartWithWhoIsFirst:(NSInteger)indexOfNumber;
- (void)sendMoveCardAtIndexPath:(NSIndexPath *)path;
- (void)postPreviousStep;
@end

@protocol GobangDelegate <NSObject>

- (void)promptConnectionStatus:(NSString *)tip;
- (void)refreshVsPlayer;
- (void)notificationStartWithWhoFirst:(NSInteger )index;
- (void)notificationMoveCardAtIndexPath:(NSIndexPath *)path;
- (void)notificationGoToPreviousStep;
@end