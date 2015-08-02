//
//  BNRGobangView.m
//  AuoLayout
//
//  Created by IT_yangjing on 15/1/26.
//  Copyright (c) 2015年 IT_yangjing. All rights reserved.
//

#import "BNRGobangView.h"
#import "XHAudioPlayerHelper.h"
#define NUMBEROFSIDE    15
#define NUMBEROFSIDE1   (NUMBEROFSIDE+2)

@interface BNRGobangView()
@property(nonatomic,strong)UITapGestureRecognizer *tap;
@property(nonatomic,assign)CGFloat side;
@property(nonatomic,strong) NSMutableArray *cardArray;
@property(nonatomic,strong) NSMutableArray *undoArray;
@end

@implementation BNRGobangView
{
    int _board[NUMBEROFSIDE+1+8][NUMBEROFSIDE+1+8];
}
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        if (!_tap) {
            _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(locationAtView:)];
            [self addGestureRecognizer:_tap];
        }
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
        _isBaiZiFirst = YES;
        for (int i = 0; i < NUMBEROFSIDE+1+8; i++) {
            for (int j = 0; j < NUMBEROFSIDE + 1+8; j++) {
                _board[i][j] = 0;
            }
        }
    }
    return self;
}
- (instancetype)init{
    self = [super init];
    if (self) {
        if(!_tap)
        {
            _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(locationAtView:)];
            [self addGestureRecognizer:_tap];
        }
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
        _isBaiZiFirst = YES;
        for (int i = 0; i < NUMBEROFSIDE+1+8; i++) {
            for (int j = 0; j < NUMBEROFSIDE + 1+8; j++) {
                _board[i][j] = 0;
            }
        }
    }
    return self;
}
- (void)awakeFromNib{
    if (!_tap) {
        _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(locationAtView:)];
        [self addGestureRecognizer:_tap];
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
        _isBaiZiFirst = YES;
        for (int i = 0; i < NUMBEROFSIDE+1+8; i++) {
            for (int j = 0; j < NUMBEROFSIDE + 1+8; j++) {
                _board[i][j] = 0;
            }
        }
    }
}
- (NSMutableArray *)cardArray{
    if (!_cardArray) {
        _cardArray = [NSMutableArray array];
    }
    return _cardArray;
}
- (NSMutableArray *)undoArray{
    if (!_undoArray) {
        _undoArray = [NSMutableArray array];
    }
    return _undoArray;
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGFloat sideOfLen = MIN(rect.size.width, rect.size.height);
    _side = sideOfLen/NUMBEROFSIDE1;
    self.bounds = CGRectMake(0, 0, sideOfLen, sideOfLen);
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = 1.0f;
    for (int i = 2; i < (NUMBEROFSIDE1 -1); i++) {
        [path moveToPoint:CGPointMake(_side, i*_side)];
        [path addLineToPoint:CGPointMake((NUMBEROFSIDE1 -1)*_side, i*_side)] ;
    }
    for (int i = 2; i < (NUMBEROFSIDE1 -1); i++) {
        [path moveToPoint:CGPointMake(i*_side, _side)];
        [path addLineToPoint:CGPointMake(i*_side, (NUMBEROFSIDE1 -1)*_side)] ;
    }
    [path stroke];
    UIBezierPath *path1 = [UIBezierPath bezierPathWithRect:CGRectMake(_side, _side, NUMBEROFSIDE*_side, NUMBEROFSIDE*_side)];
    path1.lineWidth = 3;
    [path1 stroke];
    UIBezierPath *path2 = [UIBezierPath bezierPathWithRect:CGRectMake(_side*2/3.0, _side*2/3.0, NUMBEROFSIDE*_side+2*_side/3., NUMBEROFSIDE*_side+2*_side/3.)];
    path2.lineWidth = 2.0f;
    [path2 stroke];
}

- (void)locationAtView:(UITapGestureRecognizer *)tap{
    if (tap.state == UIGestureRecognizerStateEnded) {
        CGPoint point = [tap locationInView:self];
        int row = (point.x + _side/2.)/_side;
        int section = (point.y + _side/2.)/_side;
        if (0<row && row<17&& 0<section&&section<17) {
//            NSLog(@"you taped : %d_%d",section,row);
            if (_role==0&&_isBaiZiFirst) {
                if ([self.delegate respondsToSelector:@selector(gobangView:tapAtIndexPath:)]) {
                    [self.delegate gobangView:self tapAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
                }
                [self moveWithX:row withY:section];
            }
            else if(_role == 0){
                [BNRTools popTipMessage:@"轮到黑子走步" atView:self];
                return;
            }
            if (_role==1&&_isBaiZiFirst==NO) {
                if ([self.delegate respondsToSelector:@selector(gobangView:tapAtIndexPath:)]) {
                    [self.delegate gobangView:self tapAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
                }
                [self moveWithX:row withY:section];
            }
            else if(_role == 1){
                [BNRTools popTipMessage:@"轮到白子走步" atView:self];
                return;
            }
        }
    }
}
- (void)moveWithX:(int)x withY:(int)y{
    if(_board[y-1+4][x-1+4] == 0){
        NSString *url = [[NSBundle mainBundle] pathForResource:@"44" ofType:@"caf"];
        XHAudioPlayerHelper *player = [XHAudioPlayerHelper shareInstance];
        if (player.isPlaying) {
            [player stopAudio];
        }
        [player managerAudioWithFileName:url toPlay:YES];
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        UIImageView *imgView = nil;
        if (_isBaiZiFirst) {
            imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"baizi"]];
            _isBaiZiFirst = NO;
            _board[y-1+4][x-1+4] = 1;
            
        }else {
            imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"heizi"]];
            _isBaiZiFirst = YES;
            _board[y-1+4][x-1+4] = -1;
        }
        imgView.bounds = CGRectMake(0, 0, 4*_side/5.0, 4*_side/5.0);
        imgView.center = CGPointMake(x*_side, y*_side);
        [self.cardArray addObject:imgView];
        [self.undoArray addObject:[NSIndexPath indexPathForRow:x-1+4 inSection:y-1+4]];
        [self addSubview:imgView];
        if ([self judgeWinWithX:x-1+4 withY:y-1+4]) {
            NSLog(@"%@ win",_isBaiZiFirst?@"heizi":@"baizi");
            if (_isBaiZiFirst) {
                [self.delegate notificateWin:@"heizi"];
            }else [self.delegate notificateWin:@"baizi"];
        }
    }
}

- (BOOL)judgeWinWithX:(int)x withY:(int)y{
    for (int i = 0; i < 5; i++) {
        int sum = _board[y][x+i-4]+_board[y][x+i-3]+_board[y][x+i-2]+_board[y][x+i-1]+_board[y][x+i];
        if (ABS(sum) == 5) {
            return YES;
        }
    }
    for (int i = 0; i < 5; i++) {
        int sum = _board[y+i-4][x]+_board[y+i-3][x]+_board[y+i-2][x]+_board[y+i-1][x]+_board[y+i][x];
        if (ABS(sum) == 5) {
            return YES;
        }
    }
    for (int i = 0; i < 5; i++) {
        int sum = _board[y+i-4][x+i-4]+_board[y+i-3][x+i-3]+_board[y+i-2][x+i-2]+_board[y+i-1][x+i-1]+_board[y+i][x+i];
        if (ABS(sum) == 5) {
            return YES;
        }
    }
    for (int i = 0; i < 5; i++) {
        int sum = _board[y+i-4][x-i+4]+_board[y+i-3][x-i+3]+_board[y+i-2][x-i+2]+_board[y+i-1][x-i+1]+_board[y+i][x-i];
        if (ABS(sum) == 5) {
            return YES;
        }
    }
    return NO;
}
- (void)undoPreviousStep{
    if (self.cardArray.count) {
        UIImageView *view = [self.cardArray lastObject];
        [view removeFromSuperview];
        [self.cardArray removeLastObject];
        NSIndexPath *path = [self.undoArray lastObject];
        _board[path.section][path.row] = 0;
        _isBaiZiFirst = _isBaiZiFirst?NO:YES;

    }
}
- (void)restart{
    for (UIView *view in self.cardArray) {
        [view removeFromSuperview];
    }
    [self.cardArray removeAllObjects];
    [self.undoArray removeAllObjects];
    for (int i = 0; i < NUMBEROFSIDE+1+8; i++) {
        for (int j = 0; j < NUMBEROFSIDE + 1+8; j++) {
            _board[i][j] = 0;
        }
    }
}
- (void)enableBoard:(BOOL)enable{
    self.tap.enabled = enable;
}


@end
