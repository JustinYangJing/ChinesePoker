//
//  BNRMatchMakingServer.m
//  ChinesePoker
//
//  Created by IT_yangjing on 1/10/15.
//  Copyright (c) 2015 IT_yangjing. All rights reserved.
//

#import "BNRMatchMakingServer.h"
@interface BNRMatchMakingServer()
@property (nonatomic,strong)MCNearbyServiceAdvertiser *advertiser;
@end

@implementation BNRMatchMakingServer
{
    NSMutableArray *_connectedClients;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.state = ServerStateIdle;
    }
    return self;
}
- (NSArray *)connectedClients{
    return _connectedClients;
}

- (void)startAcceptingConnectionsWith:(NSDictionary *)info{
    if (_state == ServerStateIdle) {
        _state = ServerStateAcceptingConnections;
        _connectedClients = [[NSMutableArray alloc] init];
        _localPeerID = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
        _advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:_localPeerID discoveryInfo:info serviceType:@"game-service"];
        _advertiser.delegate = self;
        [_advertiser startAdvertisingPeer];
    }
}
- (void)stopAcceptingConnections
{
    static dispatch_once_t t;
    dispatch_once(&t, ^{
        NSAssert(_state == ServerStateAcceptingConnections, @"Wrong state");
        _state = ServerStateIgnoringNewConnections;
        [_advertiser stopAdvertisingPeer];
        _advertiser.delegate = nil;
        _advertiser = nil;

    });
}
- (void)endSession{
    NSAssert(_state != ServerStateIdle, @"wrong state");
    if (_advertiser) {
        [self stopAcceptingConnections];
    }
    _state = ServerStateIdle;
    [_session disconnect];
    _session.delegate = nil;
    _session = nil;
    _localPeerID = nil;
    _connectedClients = nil;
    [self.delegate matchmakingServerSessionDidEnd:self];
}
- (NSUInteger)connectedClientCount{
    return _connectedClients==nil?0:[_connectedClients count];
}
- (MCPeerID *)peerIDForConnectedClientAtIndex:(NSInteger)index{
    return _connectedClients[index];
}

- (NSMutableArray *)arrayPlayers{
    if (_arrayPlayers == nil) {
        _arrayPlayers = [NSMutableArray array];
    }
    return _arrayPlayers;
}

- (void)advertisePlayersInfo{
    Player *hostPlayer = [self.delegate getPlayerFromHost];
    NSMutableArray *arrayPlayers = [NSMutableArray arrayWithObject:hostPlayer];
    [arrayPlayers addObjectsFromArray:self.arrayPlayers];
    NSDictionary *dic = @{@"arrayPlayers":arrayPlayers,@"packetType":[NSNumber numberWithInteger:AdvertisePlayers]};
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:dic forKey:@"dictionary"];
    [archiver finishEncoding];
    [self.session sendData:data toPeers:self.session.connectedPeers withMode:MCSessionSendDataReliable error:nil];
}
#pragma mark - MCNearbyServiceAdvertiser
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler
{
//    if ([self.connectedClients containsObject:peerID]) {
//        invitationHandler(NO,nil);
//        return;
//    }
    if (_session == nil) {
        _session = [[MCSession alloc] initWithPeer:_localPeerID securityIdentity:nil encryptionPreference:MCEncryptionNone];
        _session.delegate = self;
    }
    invitationHandler(YES,_session);
}

#pragma mark - MCSessionDelegate
// Remote peer changed state
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{
#ifdef DEBUG
    NSLog(@"session:%@,state = %d",peerID.displayName,(int)state);
     NSLog(@"server-----%lu",(unsigned long)session.connectedPeers.count);
#endif
    switch (state) {
        case MCSessionStateNotConnected:
            if ([_connectedClients containsObject:peerID]) {
                [self.arrayPlayers removeObjectAtIndex:[_connectedClients indexOfObject:peerID]];
                [_connectedClients removeObject:peerID];
                [self.delegate matchmakingServer:self clientDidConnect:peerID];
            }
            break;
        case MCSessionStateConnecting:
            break;
        case MCSessionStateConnected:
            [_connectedClients addObject:peerID];
            {
                Player *player = [[Player alloc] init];
                player.peerID = peerID;
                player.ID = [NSString stringWithFormat:@"%lu",(unsigned long)_connectedClients.count];
                player.name = peerID.displayName;
                [self.arrayPlayers addObject:player];
            }
            [self.delegate matchmakingServer:self clientDidConnect:peerID];
            break;
        default:
            break;
    }
}
// Received data from remote peer
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{
    //received name and image data from client
    if ([_connectedClients containsObject:peerID]) {
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        NSDictionary *dic = [unarchiver decodeObjectForKey:@"dictionary"];
        NSNumber *packetType = [dic objectForKey:@"packetType"];
        switch (packetType.intValue) {
            case UpdateProfile:
            {
                Player *player = [self.arrayPlayers objectAtIndex:[_connectedClients indexOfObject:peerID]];
                player.name = (NSString *)[dic objectForKey:@"name"];
                player.img = (UIImage *)[dic objectForKey:@"avtor"];
                
            }
                break;
                
            default:
                break;
        }
    }
}

// Received a byte stream from remote peer
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID{}

// Start receiving a resource from remote peer
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress{}

// Finished receiving a resource from remote peer and saved the content in a temporary location - the app is responsible for moving the file to a permanent location within its sandbox
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error{}
- (void)dealloc{
#ifdef DEBUG
    NSLog(@"%@",self);
#endif
}
@end
