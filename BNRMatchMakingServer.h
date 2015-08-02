//
//  BNRMatchMakingServer.h
//  ChinesePoker
//
//  Created by IT_yangjing on 1/10/15.
//  Copyright (c) 2015 IT_yangjing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "common.h"
typedef NS_ENUM(NSInteger,ServerState){
    ServerStateIdle,
    ServerStateAcceptingConnections,
    ServerStateIgnoringNewConnections
};

@class BNRMatchMakingServer;

@protocol BNRMatchMakingServerDelegate <NSObject>

- (void)matchmakingServer:(BNRMatchMakingServer *)server clientDidConnect:(MCPeerID *)peerID;
- (void)matchmakingServer:(BNRMatchMakingServer *)server clientDidDisconnect:(MCPeerID *)peerID;
- (void)matchmakingServerSessionDidEnd:(BNRMatchMakingServer *)server;
- (void)matchmakingServerNoNetwork:(BNRMatchMakingServer *)server;
@optional
- (Player *)getPlayerFromHost;

@end


@interface BNRMatchMakingServer : NSObject<MCSessionDelegate,MCNearbyServiceAdvertiserDelegate>
@property (nonatomic,strong,readonly)NSArray *connectedClients;
@property (nonatomic,assign)ServerState state;
@property (nonatomic,strong,readonly) MCSession *session;
@property (nonatomic,weak)id <BNRMatchMakingServerDelegate> delegate;
@property (nonatomic,strong) NSMutableArray *arrayPlayers;
@property (nonatomic,strong)MCPeerID *localPeerID;

/* create advertiser and advertise it .
   info:A dictionary of key-value pairs that are made available to browsers.
    Each key and value must be an NSString object.*/
- (void)startAcceptingConnectionsWith:(NSDictionary *)info;
- (void)endSession;
- (NSUInteger)connectedClientCount;
- (NSString *)peerIDForConnectedClientAtIndex:(NSInteger)index;
- (void)stopAcceptingConnections;
- (void)advertisePlayersInfo;
@end
