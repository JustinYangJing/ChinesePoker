//
//  Player.m
//  ChinesePoker
//
//  Created by IT_yangjing on 1/11/15.
//  Copyright (c) 2015 IT_yangjing. All rights reserved.
//

#import "Player.h"

@implementation Player
- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_img forKey:@"img"];
    [aCoder encodeObject:_peerID forKey:@"peerID"];
    [aCoder encodeObject:_ID forKey:@"ID"];
    [aCoder encodeObject:_card forKey:@"card"];
    [aCoder encodeObject:_voteID forKey:@"voteID"];
    [aCoder encodeObject:_msg forKey:@"msg"];
    [aCoder encodeObject:_voiceMsg forKey:@"voiceMsg"];
    [aCoder encodeObject:_voicePath forKey:@"voicePath"];
}
- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        _name = [aDecoder decodeObjectForKey:@"name"];
        _img = [aDecoder decodeObjectForKey:@"img"];
        _peerID = [aDecoder decodeObjectForKey:@"peerID"];
        _ID = [aDecoder decodeObjectForKey:@"ID"];
        _card = [aDecoder decodeObjectForKey:@"card"];
        _voteID = [aDecoder decodeObjectForKey:@"voteID"];
        _msg = [aDecoder decodeObjectForKey:@"msg"];
        _voiceMsg = [aDecoder decodeObjectForKey:@"voiceMsg"];
        _voicePath = [aDecoder decodeObjectForKey:@"voicePath"];
    }
    return self;
}

- (NSMutableArray *)voteID{
    if (_voteID == nil) {
        _voteID = [[NSMutableArray alloc] init];
    }
    return _voteID;
}

/*- (NSMutableData *)voiceMsg{
    if (_voiceMsg == nil) {
        _voiceMsg = [NSMutableData data];
    }
    return _voiceMsg;
}*/
@end
