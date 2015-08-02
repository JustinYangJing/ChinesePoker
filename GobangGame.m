//
//  GobangGame.m
//  ChinesePoker
//
//  Created by IT_yangjing on 15/1/29.
//  Copyright (c) 2015年 IT_yangjing. All rights reserved.
//

#import "GobangGame.h"
@interface GobangGame ()

@end

@implementation GobangGame
#pragma mark - init GobangGame and property
- (instancetype)initWithSession:(MCSession *)session withGameMode:(GameMode)gameMode{
    self = [super init];
    if (self) {
        _session = session;
        _session.delegate = self;
        _gameMode = gameMode;
        _gameState = GobangGameStateReady;
    }
    return self;
}

- (GobangPlayer *)localPlayer{
    if (!_localPlayer) {
        _localPlayer = [[GobangPlayer alloc] init];
    }
    return _localPlayer;
}
- (GobangPlayer *)vsPlayer{
    if (!_vsPlayer) {
        _vsPlayer = [[GobangPlayer alloc] init];
    }
    return _vsPlayer;
}

#pragma  mark - MCSession delegate
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{
    switch (state) {
        case MCSessionStateNotConnected:
        {
            if ([self.vsPlayer.peerID.displayName isEqualToString:peerID.displayName])
            {
                    [self.delegate promptConnectionStatus:@"丢失连接"];
            }
        }
            break;
            
        default:
            break;
    }
}

// Received data from remote peer
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSDictionary *dic = [unarchiver decodeObjectForKey:@"dictionary"];
    NSNumber *packetType = [dic objectForKey:@"packetType"];
    switch (packetType.intValue) {
        case GobangUpDateProfile:
        {
            self.vsPlayer.avtor = [dic objectForKey:@"avtor"];
            self.vsPlayer.name = [dic objectForKey:@"name"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate refreshVsPlayer];
            });
        }
            break;
         case GoBangCommandPostStart:
            if (self.gameMode == GameModeClient) {
                self.gameState = GameStateStart;
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSNumber *number = [dic objectForKey:@"indexOfNumber"];
                [self.delegate notificationStartWithWhoFirst:number.intValue];
                });

            }
            break;
        case GoBangCommandMoveCard:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate notificationMoveCardAtIndexPath:(NSIndexPath *)[dic objectForKey:@"indexPath"]];
            });
        }
            break;
        case GoBangCommandGoBack:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate notificationGoToPreviousStep];
                 });

        }
            break;
        default:
            break;
    }
}

// Received a byte stream from remote peer
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID{}

// Start receiving a resource from remote peer
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress{}

// Finished receiving a resource from remote peer and saved the content in a temporary location - the app is responsible for moving the file to a permanent location within its sandbox
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error{}

#pragma mark pulic interface 
- (void)updateProfile{
    NSDictionary *dic = @{@"ID":self.localPlayer.ID,@"name":self.localPlayer.name,@"packetType":[NSNumber numberWithInteger:GobangUpDateProfile],@"avtor":self.localPlayer.avtor};
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:dic forKey:@"dictionary"];
    [archiver finishEncoding];
    [self.session sendData:data toPeers:self.session.connectedPeers withMode:MCSessionSendDataReliable error:nil];
}
- (void)postStartWithWhoIsFirst:(NSInteger)indexOfNumber{
    NSDictionary *dic = @{@"ID":self.localPlayer.ID,@"isStart":[NSNumber numberWithBool:YES],@"packetType":[NSNumber numberWithInteger:GoBangCommandPostStart],@"indexOfNumber":[NSNumber numberWithInteger:indexOfNumber]};
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:dic forKey:@"dictionary"];
    [archiver finishEncoding];
    [self.session sendData:data toPeers:self.session.connectedPeers withMode:MCSessionSendDataReliable error:nil];

}

- (void)sendMoveCardAtIndexPath:(NSIndexPath *)path{
    NSDictionary *dic = @{@"ID":self.localPlayer.ID,@"packetType":[NSNumber numberWithInteger:GoBangCommandMoveCard],@"indexPath":path};
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:dic forKey:@"dictionary"];
    [archiver finishEncoding];
    [self.session sendData:data toPeers:self.session.connectedPeers withMode:MCSessionSendDataReliable error:nil];
}
- (void)postPreviousStep{
    NSDictionary *dic = @{@"ID":self.localPlayer.ID,@"packetType":[NSNumber numberWithInteger:GoBangCommandGoBack]};
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:dic forKey:@"dictionary"];
    [archiver finishEncoding];
    [self.session sendData:data toPeers:self.session.connectedPeers withMode:MCSessionSendDataReliable error:nil];
}
@end
