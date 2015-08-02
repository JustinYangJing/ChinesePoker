//
//  SpyGame.m
//  ChinesePoker
//
//  Created by IT_yangjing on 1/11/15.
//  Copyright (c) 2015 IT_yangjing. All rights reserved.
//

#import "SpyGame.h"

@interface SpyGame ()
@property (nonatomic,assign) BOOL isStart;
@end
@implementation SpyGame

- (instancetype)initWithSession:(MCSession *)session withMode:(GameMode)gameMode{
    self = [super init];
    if (self) {
        self.session = session;
        self.session.delegate = self;
        _gameMode = gameMode;
        _gameState = GameStateUpdateProfileAvailable;
  
        _isStart = NO;
    }
return self;
}
- (Player *)localPlayer{
    if (_localPlayer == nil) {
        _localPlayer = [[Player alloc] init];
    }
    return _localPlayer;
}
- (void)updateProfileName:(NSString *)name withImage:(UIImage *)img{
    NSDictionary *dic = @{@"name":name,@"avtor":img,@"packetType":[NSNumber numberWithInteger:UpdateProfile]};
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:dic forKey:@"dictionary"];
    [archiver finishEncoding];
    [self.session sendData:data toPeers:self.session.connectedPeers withMode:MCSessionSendDataReliable error:nil];
}
- (NSMutableArray *)playersArray{
    if (_playersArray == nil) {
        _playersArray = [NSMutableArray array];
    }
    return _playersArray;
}

#pragma mark - MCSessionDelegate
// Remote peer changed state
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{
#ifdef DEBUG
    NSLog(@"spyGmae:peer count,%d",(int)session.connectedPeers.count);
#endif
    switch (state) {
        case MCSessionStateNotConnected:
        {
            for (Player *playVar in self.playersArray) {
                if ([playVar.peerID.displayName isEqualToString:peerID.displayName])
                {
                    [self.delegate promptConnectionStatus:@"丢失连接"];
                }
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
        case AdvertisePlayers:
        {
            if (_gameMode == GameModeClient){
                _playersArray = [NSMutableArray arrayWithArray:(NSArray *)[dic objectForKey:@"arrayPlayers"]];
                for (Player *varPlayer in _playersArray) {
                    if ([self.session.myPeerID.displayName isEqualToString:varPlayer.peerID.displayName]) {
                        self.localPlayer = nil;
                        self.localPlayer = varPlayer;
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate drawPlayersAtGameVCWithLocalPalyer:self.localPlayer andPlayers:self.playersArray];
                });
            }
        }
            break;
        case DispatchCard:
            if (_gameMode == GameModeClient) {
               // NSString *ID = [dic objectForKey:@"ID"];
               /* NSString *card = [dic objectForKey:@"card"];
                NSNumber *number = [dic objectForKey:@"isSpy"];
                for (int i = 0; i < self.playersArray.count; i++) {
                    Player *pl = self.playersArray[i];
                    if ([ID isEqualToString:pl.ID]) {
                        pl.card = card;
                        pl.isSpy = number.boolValue;
                    }
                }
                if ([ID isEqualToString:self.localPlayer.ID]) {
                    self.gameState = GameStateStart;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate upDateCard];
                    });
                }*/
                NSArray *arrayCard = [dic objectForKey:@"arrayCard"];
                NSString *spyID = [dic objectForKey:@"spyID"];
               NSLog(@"receive spyID:%@",spyID);
                for (int i = 0; i < self.playersArray.count; i++) {
                    Player *pl = self.playersArray[i];
                    pl.card = arrayCard[i];
                    if ([spyID isEqualToString:pl.ID]) {
                        pl.isSpy = YES;
                        NSLog(@"%@,spyID:%d",pl.peerID.displayName,pl.isSpy);
                    }
                    else pl.isSpy = NO;
                }
                self.gameState = GameStateStart;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate upDateCard];
                });
            }
            break;
        case DispatchMsg:
        {
            NSString *ID = [dic objectForKey:@"ID"];
            int index;
            if (ID.intValue == 100) {
                index = 0;
            }
            else{
                index = ID.intValue;
            }
            Player *tmpPlayer =  (Player *)self.playersArray[index];
            tmpPlayer.msg= [dic objectForKey:@"msg"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate newMsgPromptForPlayer:index];
            });
        }
            break;
        case DispatchVoiceMsg:
        {
            NSString *ID = [dic objectForKey:@"ID"];
            int index;
            if (ID.intValue == 100) {
                index = 0;
            }
            else{
                index = ID.intValue;
            }
            Player *tmpPlayer =  (Player *)self.playersArray[index];
            tmpPlayer.voiceMsg = [dic objectForKey:@"voiceMsg"];
            NSString *path = [[NSString alloc] initWithFormat:@"%@/Documents/voice%d.caf", NSHomeDirectory(),ID.intValue];
            [tmpPlayer.voiceMsg writeToURL:[NSURL fileURLWithPath:path] atomically:YES];
            tmpPlayer.voicePath = path;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate newMsgPromptForPlayer:index];
            });
        }
            break;
        case StartVote:
        {
            NSString *ID = [dic objectForKey:@"ID"];
            if (ID.intValue == 100) {  //only server have permison to tell all start to vote
                self.gameState = GameStateVote;
            }
        }
            break;
        case AdvertiseVote:
        {
            Player * votePlayer = nil;
            Player * votedPlayer = nil;
            NSString *voteID = [dic objectForKey:@"voteID"];
            NSString *votedID = [dic objectForKey:@"votedID"];
            for (int i = 0; i < self.playersArray.count; i++) {
                Player *playerVar = self.playersArray[i];
                if ([voteID isEqualToString:playerVar.ID]) {
                    votePlayer = playerVar;
                }
                if ([votedID isEqualToString:playerVar.ID]) {
                    votedPlayer = playerVar;
                }
            }
            if (votedPlayer != nil && votePlayer != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([self availableVoteWithVotePlayer:votePlayer andVotedPlayer:votedPlayer]) {
                        [self analysisResult];
                    }
                });
            }
        }
            break;
        case AdveristeRestart:
            if (_gameMode == GameModeClient) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate notifactionResetUIAndData];
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
- (void)dealloc{
#ifdef DEBUG
    NSLog(@"%@",self);
#endif
}
#pragma spyGame function implement
- (NSInteger)countVoted{
    NSInteger sum = 0;
    for (Player *playerVar in self.playersArray) {
        if (playerVar.isAlive) {
            sum += playerVar.voteID.count;
        }
    }
    return sum;
}
- (BOOL)availableVoteWithVotePlayer:(Player *)votePlayer andVotedPlayer:(Player *)votedPlayer{
    if (votedPlayer.isAlive == NO) {
        return NO; // already dead
    }
    if ([votedPlayer.voteID containsObject:votePlayer.ID]) {
        return NO; // already vote to this VotedPlayer
    }
    for (int i = 0; i < self.playersArray.count; i++) {
        Player *playerVar = self.playersArray[i];
        if ([playerVar.voteID containsObject:votePlayer.ID])
        {
            [playerVar.voteID removeObject:votePlayer.ID];
            break;
        }
        
    }
    [votedPlayer.voteID addObject:votePlayer.ID];
    return YES;
}

- (void)analysisResult{
    [self.delegate upDateVotedLabelWithCounted:[self countVoted]];
    NSInteger shouldVoteCount = 0;
    NSMutableArray *array = [NSMutableArray array];
    for (Player *playerVar in self.playersArray) {
        if (playerVar.isAlive) {
            shouldVoteCount++;
            [array addObject:[NSNumber numberWithInteger:playerVar.voteID.count]];
        }
    }
    if (shouldVoteCount > [self countVoted]) {
        return;
    }
    [array sortUsingSelector:@selector(compare:)];
    if (array.count < 2) {
        return;
    }
    NSInteger maxVoted = ((NSNumber *)[array lastObject]).integerValue;
    NSInteger secondMaxVoted = ((NSNumber *)array[array.count-2]).integerValue;
    if (maxVoted == secondMaxVoted) {
        [self.delegate notifactionWithVotedResult:SpyGameVotedResultReVote];
        return;
    }
    int i = 0;
    for (i = 0; i < self.playersArray.count; i++) {
        Player *playerVar = self.playersArray[i];
        if (maxVoted == playerVar.voteID.count && playerVar.isAlive) {
            break;
        }
    }
    Player *playerVar = self.playersArray[i];
    playerVar.isAlive = NO;
    for (Player *pl in self.playersArray) {
        NSLog(@"%@,isSpy:%d,isAlive:%d",pl.name,pl.isSpy,pl.isAlive);
    }
   
    [self.delegate removeDeathPlayerViewFromSuperView:playerVar];
    if (playerVar.isSpy) {
        [self.delegate notifactionWithVotedResult:SpyGameVotedResultSpyLost];
        return; //spy lost
    }
    if (array.count == 3){ // kill a citizen,only remian one citizen and spy
        [self.delegate notifactionWithVotedResult:SpyGameVotedResultSpyWin];
        return;
    }
    [self.delegate notifactionWithVotedResult:SpyGameVotedResultContinue];
    
}
#pragma mark - adveritise massages
- (void)dispatchCard{
    NSArray *array = [BNRTools getQuestionFromFile];
    int spyNumber = arc4random()%self.playersArray.count;
    NSString *spyID;
    for (int i = 0; i < self.playersArray.count; i++) {
        Player *playerVar = self.playersArray[i];
        if (i == spyNumber) {
            playerVar.card = array[1];
            playerVar.isSpy = YES;
            spyID = playerVar.ID;
        }else{
            playerVar.card = array[0];
            playerVar.isSpy = NO;
        }
    }
    for (int i = 0; i < self.playersArray.count; i++) {
        Player *playerVar = self.playersArray[i];
        if ([playerVar.ID isEqualToString:self.localPlayer.ID]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate upDateCard];
            });
        }
    /*    NSDictionary *dic = @{@"card":playerVar.card,@"ID":playerVar.ID,@"packetType":[NSNumber numberWithInteger:DispatchCard],@"isSpy":[NSNumber numberWithBool:playerVar.isSpy]};
        NSMutableData *data = [NSMutableData data];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [archiver encodeObject:dic forKey:@"dictionary"];
        [archiver finishEncoding];
        [self.session sendData:data toPeers:self.session.connectedPeers withMode:MCSessionSendDataReliable error:nil];*/
            
    }
    NSLog(@"before send spyID:%@",spyID);
    NSMutableArray *arrayCard = [NSMutableArray array];
    for (Player *pl in self.playersArray) {
        [arrayCard addObject:pl.card];
    }
    NSDictionary *dic = @{@"ID":self.localPlayer.ID,@"arrayCard":arrayCard,@"packetType":[NSNumber numberWithInteger:DispatchCard],@"spyID":spyID};
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:dic forKey:@"dictionary"];
    [archiver finishEncoding];
    [self.session sendData:data toPeers:self.session.connectedPeers withMode:MCSessionSendDataReliable error:nil];

}
- (void)sendText:(NSString *)msg{
    NSDictionary *dic = @{@"ID":self.localPlayer.ID,@"msg":msg,@"packetType":[NSNumber numberWithInteger:DispatchMsg]};
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:dic forKey:@"dictionary"];
    [archiver finishEncoding];
    [self.session sendData:data toPeers:self.session.connectedPeers withMode:MCSessionSendDataReliable error:nil];
}
- (void)sendVoiceMsg:(NSString *)path{
    if (path.length > 0) {
        if (self.localPlayer.voiceMsg) {
            self.localPlayer.voiceMsg = nil;
        }
        self.localPlayer.voiceMsg = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:path]];
        
        NSDictionary *dic = @{@"ID":self.localPlayer.ID,@"voiceMsg":self.localPlayer.voiceMsg,@"packetType":[NSNumber numberWithInteger:DispatchVoiceMsg]};
        NSMutableData *data = [NSMutableData data];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [archiver encodeObject:dic forKey:@"dictionary"];
        [archiver finishEncoding];
        [self.session sendData:data toPeers:self.session.connectedPeers withMode:MCSessionSendDataReliable error:nil];
    }
}
-(void)tellAllStartVote{
    NSDictionary *dic = @{@"ID":self.localPlayer.ID,@"startVote":[NSNumber numberWithBool:YES],@"packetType":[NSNumber numberWithInteger:StartVote]};
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:dic forKey:@"dictionary"];
    [archiver finishEncoding];
    [self.session sendData:data toPeers:self.session.connectedPeers withMode:MCSessionSendDataReliable error:nil];
}

- (void)advertiseVoteWithVotePlayer:(Player *)votePlayer andVotedPlayer:(Player *)votedPlayer{
    NSDictionary *dic = @{@"ID":self.localPlayer.ID,@"voteID":votePlayer.ID,@"votedID":votedPlayer.ID,@"packetType":[NSNumber numberWithInteger:AdvertiseVote]};
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:dic forKey:@"dictionary"];
    [archiver finishEncoding];
    [self.session sendData:data toPeers:self.session.connectedPeers withMode:MCSessionSendDataReliable error:nil];
}

- (void)advertiseRestart{
    NSDictionary *dic = @{@"ID":self.localPlayer.ID,@"packetType":[NSNumber numberWithInteger:AdveristeRestart]};
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:dic forKey:@"dictionary"];
    [archiver finishEncoding];
    [self.session sendData:data toPeers:self.session.connectedPeers withMode:MCSessionSendDataReliable error:nil];

}
@end
