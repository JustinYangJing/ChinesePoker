//
//  BNRShowMsgView.m
//  ChinesePoker
//
//  Created by IT_yangjing on 15/1/27.
//  Copyright (c) 2015年 IT_yangjing. All rights reserved.
//

#import "BNRShowMsgView.h"

@interface BNRShowMsgView ()
@property (nonatomic,copy) NSString *audioFileName;
@property (nonatomic,copy) NSString *msg;
@property (nonatomic,strong) UIImage *avtor;
@property (nonatomic,weak) IBOutlet UIImageView *bubbleMsg;
@property (nonatomic,weak) IBOutlet UIImageView *bubbleVoice;
@property (nonatomic,strong) UIView *maskView;
@property (nonatomic,weak) IBOutlet UIImageView *avtor1;
@property (nonatomic,weak) IBOutlet UIImageView *avtor2;
@property (nonatomic,strong) UIImageView *bubbleMsgReal;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,strong) UIButton *playerVoiceBtn;
@property (nonatomic,strong) XHAudioPlayerHelper *audioPlayer;
@end
@implementation BNRShowMsgView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(instancetype)initWithFrame:(CGRect)frame withAvtor:(UIImage *)img withAudioFileName:(NSString *)aName withMsg:(NSString *)msg{
    self = [super initWithFrame:frame];
    if (self) {
        _avtor = img;
        _audioFileName = aName;
        _msg = msg;
    }
    return self;
}
- (void)setAvtorImg:(UIImage *)avtor aduioFileName:(NSString *)aName textMsg:(NSString *)msg{
    _avtor = avtor;
    _audioFileName = aName;
    _msg = msg;
}

-(void)layoutSubviews{
    if (self.superview != nil){
        CGRect bounds = self.superview.bounds;
        self.maskView = [[UIView alloc] initWithFrame:bounds];
        self.maskView.backgroundColor = [UIColor whiteColor];
        self.maskView.alpha = 0.3;
        [self.superview insertSubview:self.maskView belowSubview:self];
    }

    if (_avtor) {
        self.avtor1.image = _avtor;
        self.avtor2.image = _avtor;
    }
    if (_audioFileName) {
        self.playerVoiceBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0,30 , 30)];
        [self.playerVoiceBtn setBackgroundImage:[UIImage imageNamed:@"ReceiverVoiceNodePlaying003"] forState:UIControlStateNormal];
        [self.playerVoiceBtn addTarget:self action:@selector(playAudioFile:) forControlEvents:UIControlEventTouchUpInside];
        self.playerVoiceBtn.center = self.bubbleVoice.center;
        [self addSubview:self.playerVoiceBtn];

    }
    if (_msg) {
        UIEdgeInsets edgeInsets = {30,15,15,15};
        UIImage *bubble = [[UIImage imageNamed:@"weChatBubble_Receiving_Solid"] resizableImageWithCapInsets:edgeInsets];
        self.bubbleMsg.image = bubble;
        CGSize limitSize = CGSizeMake(170, 400);
        CGRect rect = [_msg boundingRectWithSize:limitSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont STXiheiFontWithSize:15]} context:nil];
        self.bubbleMsg.hidden = YES;
        if (!_bubbleMsgReal) {
            _bubbleMsgReal = [[UIImageView alloc] initWithImage:bubble];
            _bubbleMsgReal.frame = CGRectMake(self.bubbleMsg.frame.origin.x, self.bubbleMsg.frame.origin.y, rect.size.width+30, rect.size.height+10);
            UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, rect.size.width, rect.size.height)];
            textLabel.text = _msg;
            textLabel.textColor = [UIColor whiteColor];
            textLabel.font = [UIFont STXiheiFontWithSize:15];
            textLabel.numberOfLines = 0;
            textLabel.lineBreakMode = NSLineBreakByCharWrapping;
            [_bubbleMsgReal addSubview:textLabel];
            [self addSubview:_bubbleMsgReal];
        }
       
    }
    self.layer.cornerRadius = 7.0f;
    self.layer.masksToBounds = YES;
}
- (IBAction)exit:(id)sender{
    if (_maskView) {
        [_maskView removeFromSuperview];
    }
    if (_audioPlayer) {
        [_audioPlayer stopAudio];
        _audioPlayer.delegate = nil;
    }
    [self removeFromSuperview];
}
- (void)playAudioFile:(UIButton *)btn{
    if (!_audioPlayer) {
        _audioPlayer = [XHAudioPlayerHelper shareInstance];
        _audioPlayer.delegate = self;
    }
    [_audioPlayer managerAudioWithFileName:_audioFileName toPlay:YES];
}

#pragma mark - XHAudioPlayerHelper delegate
- (void)didAudioPlayerBeginPlay:(AVAudioPlayer*)audioPlayer{
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(changeVoiceImg:) userInfo:nil repeats:YES];
    }
    self.playerVoiceBtn.enabled = NO;
}
- (void)didAudioPlayerStopPlay:(AVAudioPlayer*)audioPlayer{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
        [self.playerVoiceBtn setBackgroundImage:[UIImage imageNamed:@"ReceiverVoiceNodePlaying003"] forState:UIControlStateNormal];
    }
    self.playerVoiceBtn.enabled = YES;
}
- (void)didAudioPlayerPausePlay:(AVAudioPlayer*)audioPlayer{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
        [self.playerVoiceBtn setBackgroundImage:[UIImage imageNamed:@"ReceiverVoiceNodePlaying003"] forState:UIControlStateNormal];
    }
    self.playerVoiceBtn.enabled = YES;
}

- (void)changeVoiceImg:(NSTimer *)timer{
    static int i = 1;
    [self.playerVoiceBtn setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"ReceiverVoiceNodePlaying00%d",i]] forState:UIControlStateNormal];
    i++;
    if (i > 3) {
        i = 1;
    }
}
- (void)dealloc{
    if (_audioPlayer) {
        _audioPlayer.delegate = nil;
    }
    if (_timer) {
        [_timer invalidate];
    }
}
@end
