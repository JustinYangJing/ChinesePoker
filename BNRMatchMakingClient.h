//
//  BNRMatchMakingClient.h
//  ChinesePoker
//
//  Created by IT_yangjing on 1/10/15.
//  Copyright (c) 2015 IT_yangjing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
@class BNRMatchMakingClient;
@protocol BNRMatchMakingClientDelegate <NSObject>
//tell delegate ,find new server or server disappear
//peerID:server peerID
- (void)matchMakingClient:(BNRMatchMakingClient *)client serverDidChange:(MCPeerID *)peerID;
- (void)promptConnectionStatus:(MCSessionState)state;
- (void)pushToGameVCWithSession:(MCSession *)session;
@end

@interface BNRMatchMakingClient : NSObject <MCNearbyServiceBrowserDelegate,MCSessionDelegate>
@property(strong,nonatomic)MCSession *session;
@property(strong,nonatomic,readonly)NSArray *availableServers;
@property(weak,nonatomic)id<BNRMatchMakingClientDelegate>delegate;

- (void)startSearchingForServers;
- (void)connectavailableServersAtIndex:(NSInteger)index;
@end

