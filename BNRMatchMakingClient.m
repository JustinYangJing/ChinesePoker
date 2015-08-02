//
//  BNRMatchMakingClient.m
//  ChinesePoker
//
//  Created by IT_yangjing on 1/10/15.
//  Copyright (c) 2015 IT_yangjing. All rights reserved.
//

#import "BNRMatchMakingClient.h"
typedef NS_ENUM(NSInteger,ClientState){
    ClientStateIdle,
    ClientStateSearchingForServers,
    ClientStateConnecting,
    ClientStateConnected,
};

@interface BNRMatchMakingClient()
@property (nonatomic,strong)MCNearbyServiceBrowser *browser;
@property (nonatomic)ClientState state;
@property (nonatomic,strong)MCPeerID *localPeerID;
@end

@implementation BNRMatchMakingClient
{
    NSMutableArray *_availableServers;
}
- (instancetype)init{
    self = [super init];
    if (self) {
        _state = ClientStateIdle;
    }
    return self;
}
- (void)startSearchingForServers{
    if (_state == ClientStateIdle) {
        _state = ClientStateSearchingForServers;
        _availableServers = [NSMutableArray array];
        _localPeerID = [[MCPeerID alloc] initWithDisplayName:[UIDevice currentDevice].name];
        _browser = [[MCNearbyServiceBrowser alloc] initWithPeer:_localPeerID serviceType:@"game-service"];
        _browser.delegate = self;
        [_browser startBrowsingForPeers];
        
        _session = [[MCSession alloc] initWithPeer:_localPeerID securityIdentity:nil encryptionPreference:MCEncryptionNone];
        _session.delegate = self;
    }
}
- (NSArray *)availableServers{
    return _availableServers;
}

- (void)connectavailableServersAtIndex:(NSInteger)index{
    NSDictionary *selectedServer = _availableServers[index];
    MCPeerID *peerID = [selectedServer objectForKey:@"peerID"];
    [_browser invitePeer:peerID toSession:_session withContext:nil timeout:30];
}

#pragma mark - MCNearbyServiceBrowerDelegata
// Found a nearby advertising peer
- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
#ifdef DEBUG
   NSLog(@"find peerID:%@",peerID.displayName);
#endif
    NSAssert(_state == ClientStateSearchingForServers||
             _state == ClientStateConnecting, @"wrong stata");
    //if already find this server,the ignore
    for (NSDictionary *tmpDic in _availableServers) {
        MCPeerID *tmpPeerID = (MCPeerID *)[tmpDic objectForKey:@"peerID"];
        if ([peerID.displayName isEqualToString:tmpPeerID.displayName]) {
            [_availableServers removeObject:tmpDic];
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:info];
            [dic setObject:peerID forKey:@"peerID"];
            [_availableServers addObject:dic];
            [self.delegate matchMakingClient:self serverDidChange:peerID];
            return;
        }
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:info];
    [dic setObject:peerID forKey:@"peerID"];
    [_availableServers addObject:dic];
    [self.delegate matchMakingClient:self serverDidChange:peerID];
}

// A nearby peer has stopped advertising
- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
#ifdef DEBUG
    NSLog(@"disappear:%@",peerID.displayName);
#endif
    NSAssert(_state == ClientStateSearchingForServers||
             _state == ClientStateConnecting, @"wrong state");
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *dic in _availableServers) {
        [array addObject:[dic objectForKey:@"peerID"]];
    }
    if ([array containsObject:peerID]) {
        NSUInteger i = [array indexOfObject:peerID];
        [_availableServers removeObjectAtIndex:i];
        [self.delegate matchMakingClient:self serverDidChange:peerID];
    }
    
}


#pragma mark - MCSessionDelegate
// Remote peer changed state
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{
#ifdef DEBUG
    NSLog(@"session:%@,%d",peerID,(int)state);
#endif
    switch (state) {
        case MCSessionStateNotConnected:
            //lost connection with server ,should pop JoinGameVC,and alert user the connection lost
            {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate promptConnectionStatus:state];
            });
            }
            break;
        case MCSessionStateConnecting:
            if (_state == ClientStateSearchingForServers) {
                _state = ClientStateConnecting;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate promptConnectionStatus:state];
                });
            }
            break;
        case MCSessionStateConnected:
            if (_state == ClientStateConnecting) {
                _state = ClientStateConnected;
                [_browser stopBrowsingForPeers];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate pushToGameVCWithSession:_session];
                    [self.delegate promptConnectionStatus:state];
                });
            }
            break;
        default:
            break;
    }
}
// Received data from remote peer
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{}

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
