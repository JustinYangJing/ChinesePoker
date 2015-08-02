//
//  SpyGame.h
//  ChinesePoker
//
//  Created by IT_yangjing on 1/11/15.
//  Copyright (c) 2015 IT_yangjing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "common.h"
#import "Player.h"

typedef NS_ENUM(NSInteger, GameMode) {
    GameModeClient,
    GameModeServer
};
typedef NS_ENUM(NSInteger, PacketType){
    UpdateProfile = 0x64,
    AdvertisePlayers,
    DispatchCard,
    DispatchMsg,
    DispatchVoiceMsg,
    StartVote,
    AdvertiseVote,
    AdveristeRestart,
};
typedef NS_ENUM(NSInteger, GameState){
    GameStateUpdateProfileAvailable, //client default game state
    GameStateReady,        
    GameStateStart,
    GameStateVote,
    GameStateVoteCount,
    GameStateOver,
};
typedef NS_ENUM(NSInteger, SpyGameVotedResult) {
    SpyGameVotedResultSpyWin,
    SpyGameVotedResultSpyLost,
    SpyGameVotedResultContinue,
    SpyGameVotedResultReVote,
};
@protocol SpyGameDelegate;
@interface SpyGame : NSObject <MCSessionDelegate>
@property (nonatomic,strong)MCSession *session;
@property (nonatomic,strong)NSMutableArray *playersArray;
@property (nonatomic,strong)Player *localPlayer;
@property (nonatomic,assign)GameMode gameMode;
@property (nonatomic,assign)GameState gameState;
@property (nonatomic,weak)id <SpyGameDelegate> delegate;

- (instancetype)initWithSession:(MCSession *)session withMode:(GameMode)gameMode;
- (NSInteger)countVoted;
- (BOOL)availableVoteWithVotePlayer:(Player *)votePlayer andVotedPlayer:(Player *)votedPlayer;
- (void)analysisResult;

- (void)updateProfileName:(NSString *)name withImage:(UIImage *)img;
- (void)dispatchCard;
- (void)sendText:(NSString *)msg;
- (void)sendVoiceMsg:(NSString *)path;
-(void)tellAllStartVote;
- (void)advertiseVoteWithVotePlayer:(Player *)votePlayer andVotedPlayer:(Player *)votedPlayer;
- (void)advertiseRestart;
@end

@protocol SpyGameDelegate <NSObject>

- (void)drawPlayersAtGameVCWithLocalPalyer:(Player *)localPalyer andPlayers:(NSArray *)arrayPlayers;
- (void)promptConnectionStatus:(NSString *)tip;
- (void)upDateCard;
- (void)newMsgPromptForPlayer:(NSInteger)index;
- (void)upDateVotedLabelWithCounted:(NSInteger)count;
- (void)notifactionWithVotedResult:(SpyGameVotedResult)spyGameVotedResult;
- (void)removeDeathPlayerViewFromSuperView:(Player *)player;
- (void)notifactionResetUIAndData;
@end