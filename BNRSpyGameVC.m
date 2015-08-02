//
//  BNRSpyGameVC.m
//  ChinesePoker
//
//  Created by IT_yangjing on 1/12/15.
//  Copyright (c) 2015 IT_yangjing. All rights reserved.
//

#import "BNRSpyGameVC.h"
#import "XHVoiceRecordHUD.h"
#import "XHVoiceRecordHelper.h"
#import "APLPendulumBehavior.h"

@interface BNRSpyGameVC ()
@property (weak, nonatomic) IBOutlet UITextView *textMsg;
@property (weak, nonatomic) IBOutlet UIButton *sendTextMsg;
@property (weak, nonatomic) IBOutlet UIButton *voiceButton;
@property (weak, nonatomic) IBOutlet UIImageView *avtorImg;
@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *popSetProfileViewGesture;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *showQuestionTap;
@property (weak, nonatomic) IBOutlet UIImageView *faceUp;
@property (weak, nonatomic) IBOutlet UIImageView *faceDown;
@property (strong,nonatomic)UILabel *questionLabel;
@property (weak, nonatomic) IBOutlet UIButton *controlBtn;
@property (weak, nonatomic) IBOutlet UIImageView *voteImgView;

@property (nonatomic, strong, readwrite) XHVoiceRecordHUD *voiceRecordHUD;
@property (nonatomic, strong) XHVoiceRecordHelper *voiceRecordHelper;
@property (nonatomic,assign) BOOL drawPlayerEnable;

@property(nonatomic,strong)UIDynamicAnimator *animator;
@property(nonatomic,strong)UIGravityBehavior *gravity;
@property(nonatomic,strong)UICollisionBehavior *collision;
@property(nonatomic,strong)NSMutableArray *pendulumBehaviorArray;
@property(nonatomic,strong)UIAttachmentBehavior *voteAttachment;
@end

@implementation BNRSpyGameVC
{
    CGSize _textViewoldSize;
}
- (void)viewDidLoad{
    [super viewDidLoad];
    [self initUI];
}
- (void)initUI{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self.textMsg action:@selector(resignFirstResponder)];
    [self.view addGestureRecognizer:tap];
    self.textMsg.layer.cornerRadius = 6.0;
    self.textMsg.layer.masksToBounds = YES;
    self.textMsg.delegate = self;
    self.textMsg.font = [UIFont STXiheiFontWithSize:14.0f];
    [self.sendTextMsg buttonNewType];
    self.questionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.faceUp.bounds.size.width, 0)];
    self.questionLabel.text = @"您好";
    self.questionLabel.textAlignment = NSTextAlignmentCenter;
    self.questionLabel.center = CGPointMake(self.faceDown.center.x, self.faceDown.frame.origin.y);
    self.questionLabel.font = [UIFont STXiheiFontWithSize:15];
    self.questionLabel.textColor = [UIColor whiteColor];
    self.questionLabel.numberOfLines = 0;
    [self.view insertSubview:self.questionLabel belowSubview:self.faceUp];
    [self.controlBtn buttonNewType];
    self.controlBtn.titleLabel.font = [UIFont STXiheiFontWithSize:14];
    if (self.spyGame.gameMode == GameModeClient) {
        self.spyGame.gameState = GameStateUpdateProfileAvailable;
        [self setComponentStatusWithGameState:GameStateUpdateProfileAvailable];
    }
//    UIDynamicItemBehavior *itemBehavior = [[UIDynamicItemBehavior alloc] init];
//    itemBehavior.density = 1000;
//    [itemBehavior addItem:self.avtorImg];
//    [self.animator addBehavior:itemBehavior];

    //data init
    if (self.spyGame.gameMode == GameModeServer) { //already init localPlayer and also get all players info when its server in ConnectVC
        self.avtorImg.image = self.spyGame.localPlayer.img;
    }else
        self.spyGame.localPlayer.img = self.avtorImg.image;
    _drawPlayerEnable = YES;
    self.spyGame.delegate = self;
    [self.spyGame addObserver:self forKeyPath:@"gameState" options:NSKeyValueObservingOptionNew context:nil];
}
- (UIGravityBehavior *)gravity{
    if (!_gravity) {
        _gravity = [[UIGravityBehavior alloc] init];
        [self.animator addBehavior:_gravity];
    }
    return _gravity;
}
- (UICollisionBehavior *)collision{
    if (!_collision) {
        _collision = [[UICollisionBehavior alloc] init];
        _collision.translatesReferenceBoundsIntoBoundary = YES;
        _collision.collisionDelegate = self;
        [self.animator addBehavior:_collision];
    }
    return _collision;
}
- (UIDynamicAnimator *)animator{
    if (!_animator) {
        _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
        _animator.delegate = self;
    }
    return _animator;
}
- (NSMutableArray *)pendulumBehaviorArray{
    if (!_pendulumBehaviorArray) {
        _pendulumBehaviorArray = [NSMutableArray array];
    }
    return _pendulumBehaviorArray;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.spyGame.gameState == GameStateUpdateProfileAvailable && self.spyGame.gameMode == GameModeServer) {
        self.spyGame.gameState = GameStateReady;
        _drawPlayerEnable = NO;
        [self drawPlayersAtGameVCWithLocalPalyer:self.spyGame.localPlayer andPlayers:self.spyGame.playersArray];
    }
}
- (void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationLandscapeRight;
}
- (BOOL)shouldAutorotate{
    return YES;
}
- (XHVoiceRecordHUD *)voiceRecordHUD {
    if (!_voiceRecordHUD) {
        _voiceRecordHUD = [[XHVoiceRecordHUD alloc] initWithFrame:CGRectMake(0, 0, 140, 140)];
    }
    return _voiceRecordHUD;
}
- (XHVoiceRecordHelper *)voiceRecordHelper {
    if (!_voiceRecordHelper) {
        WEAKSELF
        _voiceRecordHelper = [[XHVoiceRecordHelper alloc] init];
        _voiceRecordHelper.maxTimeStopRecorderCompletion = ^{
            DLog(@"已经达到最大限制时间了，进入下一步的提示");
            [weakSelf finishRecorded];
        };
        _voiceRecordHelper.peakPowerForChannel = ^(float peakPowerForChannel) {
            weakSelf.voiceRecordHUD.peakPower = peakPowerForChannel;
        };
        _voiceRecordHelper.maxRecordTime = kVoiceRecorderTotalTime;
    }
    return _voiceRecordHelper;
}


- (IBAction)back:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)keyboardWillAppear:(NSNotification *)aNotification{
    CGRect keyboardRect = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect frame = CGRectMake(self.view.frame.origin.x, 0 - keyboardRect.size.height, self.view.frame.size.width, self.view.frame.size.height);
    [UIView animateWithDuration:animationDuration animations:^{
        self.view.frame = frame;
    }];
}
- (void)keyboardWillHide:(NSNotification *)aNotification
{
    CGRect keyboardRect = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
   CGRect frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + keyboardRect.size.height, self.view.frame.size.width, self.view.frame.size.height);
    [UIView animateWithDuration:animationDuration animations:^{
        self.view.frame = frame;
    }];

}
#pragma mark - textfeild delegate
- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView{
        _textViewoldSize = textView.frame.size;
        textView.frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y-(textView.contentSize.height-_textViewoldSize.height), textView.contentSize.width, textView.contentSize.height);
}



- (IBAction)popSetProfileView:(UILongPressGestureRecognizer *)sender {
#define kViewWidth 300
#define kViewHeight 200
    if (sender.state == UIGestureRecognizerStateEnded) {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(kWidth/2.0 - kViewWidth/2.0, kHeight/2.0-kViewHeight/2.0,kViewWidth,kViewHeight)];
    view.tag = 101;
    view.backgroundColor = [UIColor grayColor];
    view.layer.cornerRadius = 6.0f;
    view.layer.masksToBounds = YES;
    [self.view addSubview:view];
    UIButton *openAblumButton = [[UIButton alloc] initWithFrame:CGRectMake(kViewWidth/4.0, kViewHeight/5.0, kViewWidth/2.0, kViewHeight/5.0)];
    UIButton *openCamera = [[UIButton alloc] initWithFrame:CGRectMake(kViewWidth/4.0, kViewHeight*3/5.0, kViewWidth/2.0, kViewHeight/5.0)];
    [openAblumButton buttonNewType];
    [openCamera buttonNewType];
    [openAblumButton setTitle:@"打开相册" forState:UIControlStateNormal];
    [openCamera setTitle:@"打开相机" forState:UIControlStateNormal];
    [view addSubview:openCamera];
    [view addSubview:openAblumButton];
    openAblumButton.tag = 102;
    openCamera.tag = 103;
    [openAblumButton addTarget:self action:@selector(selectPhoto:) forControlEvents:UIControlEventTouchUpInside];
    [openCamera addTarget:self action:@selector(selectPhoto:) forControlEvents:UIControlEventTouchUpInside];
    }
}
- (void)selectPhoto:(UIButton *)btn{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    if (btn.tag == 103) {
        BOOL isCamera = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
        if (!isCamera) {
            NSLog(@"no camera");
            return ;
        }
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.allowsEditing = YES;
    }
    [self presentViewController:imagePicker animated:YES completion:nil];
}
#pragma mark - image picker view controller delegate
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIGraphicsBeginImageContext(self.avtorImg.frame.size);
    [image drawInRect:CGRectMake(0, 0, self.avtorImg.frame.size.width, self.avtorImg.frame.size.height)];
    UIImage  *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.spyGame.localPlayer.img = newImage;
    self.avtorImg.image = newImage;
    self.avtorImg.layer.masksToBounds = YES;
    self.avtorImg.layer.cornerRadius = CGRectGetHeight([self.avtorImg bounds])/2.0;
    UIView *view = [self.view viewWithTag:101];
    [view removeFromSuperview];
    WEAKSELF;
    [picker dismissViewControllerAnimated:YES completion:^{
        [weakSelf.spyGame updateProfileName:weakSelf.spyGame.localPlayer.name withImage:weakSelf.avtorImg.image];
    }];
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    UIView *view = [self.view viewWithTag:101];
    [view removeFromSuperview];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Voice Recording Helper Method
- (void)finishRecorded {
    WEAKSELF
    [self.voiceRecordHUD stopRecordCompled:^(BOOL fnished) {
        weakSelf.voiceRecordHUD = nil;
    }];
    [self.voiceRecordHelper stopRecordingWithStopRecorderCompletion:^{
        NSLog(@"%@",weakSelf.voiceRecordHelper.recordPath);
        weakSelf.spyGame.localPlayer.voicePath = weakSelf.voiceRecordHelper.recordPath;
        [weakSelf.spyGame sendVoiceMsg:weakSelf.spyGame.localPlayer.voicePath];
    }];
}


- (void)startRecord {
    [self.voiceRecordHUD startRecordingHUDAtView:self.view];
    NSString *recorderPath = [[NSString alloc] initWithFormat:@"%@/Documents/voice.caf", NSHomeDirectory()];
    [self.voiceRecordHelper startRecordingWithPath:recorderPath StartRecorderCompletion:^{
    }];
}

- (void)pauseRecord {
    [self.voiceRecordHUD pauseRecord];
}

- (void)resumeRecord {
    [self.voiceRecordHUD resaueRecord];
}

- (void)cancelRecord {
    WEAKSELF
    [self.voiceRecordHUD cancelRecordCompled:^(BOOL fnished) {
        weakSelf.voiceRecordHUD = nil;
    }];
    [self.voiceRecordHelper cancelledDeleteWithCompletion:^{
        
    }];
}
- (IBAction)holdDownButtonTouchDown:(id)sender {
    [self startRecord];
}
- (IBAction)holdDownButtonTouchUpOutside:(id)sender {
    [self cancelRecord];
}
- (IBAction)holdDownButtonTouchUpInside:(id)sender {
    [self finishRecorded];
}
- (IBAction)holdDownDragOutside:(id)sender {
    [self resumeRecord];
}
- (IBAction)holdDownDragInside:(id)sender {
    [self pauseRecord];
}

#pragma mark - SpyGame delegate
- (void)drawPlayersAtGameVCWithLocalPalyer:(Player *)localPalyer andPlayers:(NSArray *)arrayPlayers{
    for (Player *playerVar in arrayPlayers) {
        playerVar.isAlive = YES;
    }
    
    float widthPerPlayer = kWidth/(arrayPlayers.count - 1);
    float realWidthOfPlayer = 0;
    if (widthPerPlayer < self.avtorImg.bounds.size.width) {
        realWidthOfPlayer = widthPerPlayer;
    }else {
        realWidthOfPlayer = self.avtorImg.bounds.size.width;
    }
        for (int i = 0,j = 0; i < arrayPlayers.count; i++,j++) {
            Player *playerVar = arrayPlayers[i];
            if ([playerVar.ID isEqualToString:localPalyer.ID]) {
                j--;
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMsgView:)];
                tap.numberOfTapsRequired = 1;
                [self.avtorImg addGestureRecognizer:tap];
                
                UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(vote:)];
                doubleTap.numberOfTapsRequired = 2;
                [self.avtorImg addGestureRecognizer:doubleTap];
                [tap requireGestureRecognizerToFail:doubleTap];
                playerVar.imgView = self.avtorImg;
                continue;
            }
            UIImageView *view = [[UIImageView alloc] init];
            playerVar.imgView = view;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMsgView:)];
            tap.numberOfTapsRequired = 1;
            [view addGestureRecognizer:tap];
            UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(vote:)];
            doubleTap.numberOfTapsRequired = 2;
            [view addGestureRecognizer:doubleTap];
            [tap requireGestureRecognizerToFail:doubleTap];
            
            if (playerVar.img == nil) {
                view.image = [UIImage imageNamed:@"pic_0000_password"];
            }
            else {
                if (playerVar.ID.intValue == 100) {
                    view.image = [UIImage imageNamed:@"boss"];
                    playerVar.img = view.image;
                }else
                    view.image = playerVar.img;
            }
            view.frame = CGRectMake(0, 0, realWidthOfPlayer, realWidthOfPlayer);
            view.layer.masksToBounds = YES;
            view.layer.cornerRadius = CGRectGetHeight(view.bounds)/2.0f;
            view.center = CGPointMake(widthPerPlayer/2.0f + j*widthPerPlayer, +realWidthOfPlayer/2.0f);
            UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragPlayer:)];
            [view addGestureRecognizer:pan];
            view.userInteractionEnabled = YES;
            view.tag = 200+j;
            [self.view addSubview:view];
            [self.gravity addItem:view];
            APLPendulumBehavior *pendulum = [[APLPendulumBehavior alloc] initWithWeight:view suspendedFromPoint:CGPointMake(widthPerPlayer/2.f+j*widthPerPlayer, 0)];
            [self.pendulumBehaviorArray addObject:pendulum];
            [self.animator addBehavior:pendulum];
            float randLen = arc4random()%4 * kHeight/8.0f;
            [pendulum setLengthBetweenSuspendedPointAndView:(kHeight/4.0f + randLen)];
            [self addRopeWithAnchorPoint:CGPointMake(widthPerPlayer/2.f+j*widthPerPlayer,0) withAttachedView:view ropeLength:(kHeight/4.0f + randLen)];
            pendulum.attachmentSuspendedPoint.frequency = 1;
            pendulum.attachmentSuspendedPoint.damping = 0.1;
            [self.collision addItem:view];
    }
}
- (void)dragPlayer:(UIPanGestureRecognizer *)gesture{
    APLPendulumBehavior *pendulum = self.pendulumBehaviorArray[gesture.view.tag-200];
    if (gesture.state == UIGestureRecognizerStateBegan){
        [pendulum beginDraggingWeightAtPoint:[gesture locationInView:self.view]];
    }
    else if (gesture.state == UIGestureRecognizerStateEnded)
        [pendulum endDraggingWeightWithVelocity:[gesture velocityInView:self.view]];
    else if (gesture.state == UIGestureRecognizerStateCancelled)
    {
        gesture.enabled = YES;
        [pendulum endDraggingWeightWithVelocity:[gesture velocityInView:self.view]];
    }
    else if (!CGRectContainsPoint(gesture.view.bounds, [gesture locationInView:gesture.view]))
        // End the gesture if the user's finger moved outside square1's bounds.
        // This causes the gesture to transition to the cencelled state.
        gesture.enabled = NO;
    else
        [pendulum dragWeightToPoint:[gesture locationInView:self.view]];

}
- (void)addRopeWithAnchorPoint:(CGPoint)p withAttachedView:(UIView *)view ropeLength:(CGFloat)len
{
        UIImageView *previousView = nil;
        UIImage *ropeImg = [UIImage imageNamed:@"ropeTexture"];
        int numberOfRope = len / ropeImg.size.height;
        for (int i = 0; i < numberOfRope; i++) {
            UIImageView *imgView = [[UIImageView alloc] initWithImage:ropeImg];
            imgView.frame = CGRectMake(p.x, p.y, ropeImg.size.width, ropeImg.size.height);
            [self.view addSubview:imgView];
            if (i == 0) {
                imgView.center = CGPointMake(p.x, p.y+ropeImg.size.height/2.0f);
                UIAttachmentBehavior *attachment = [[UIAttachmentBehavior alloc]initWithItem:imgView attachedToAnchor:p];
                [self.animator addBehavior:attachment];
                
            }else if(i == numberOfRope - 1){
                UIAttachmentBehavior *attachment = [[UIAttachmentBehavior alloc] initWithItem:imgView attachedToItem:previousView];
                attachment.length = ropeImg.size.height;
                [self.animator addBehavior:attachment];
                UIAttachmentBehavior *attachment1 = [[UIAttachmentBehavior alloc] initWithItem:imgView attachedToItem:view];
                attachment1.length = 0;
                [self.animator addBehavior:attachment1];
                }
            else{
                UIAttachmentBehavior *attachment = [[UIAttachmentBehavior alloc] initWithItem:imgView attachedToItem:previousView];
                 attachment.length = ropeImg.size.height;
                [self.animator addBehavior:attachment];
            }
            [self.gravity addItem:imgView];
            previousView = imgView;
            
        }
}

#pragma mark - SpyGame delegate1
- (void)upDateVotedLabelWithCounted:(NSInteger)count{
    UILabel *label = (UILabel *)[self.view viewWithTag:301];
    label.text = [NSString stringWithFormat:@"已投票数为:%d",(int)count];
}
- (void)notifactionWithVotedResult:(SpyGameVotedResult)spyGameVotedResult{
    switch (spyGameVotedResult) {
        case SpyGameVotedResultContinue:
            NSLog(@"继续游戏");
            [BNRTools popTipMessage:@"卧底存在，继续游戏" atView:self.view];
            self.spyGame.gameState = GameStateStart;
            break;
        case SpyGameVotedResultReVote:
            [BNRTools popTipMessage:@"不止一个最大票数，请重新投票" atView:self.view];
            NSLog(@"出现同票，请继续投票");
            break;
        case SpyGameVotedResultSpyLost:
            [BNRTools popTipMessage:@"卧底输了" atView:self.view];
            self.spyGame.gameState = GameStateOver;
            NSLog(@"spy lost");
            break;
        case SpyGameVotedResultSpyWin:
            [BNRTools popTipMessage:@"卧底赢了" atView:self.view];
            self.spyGame.gameState = GameStateOver;
            NSLog(@"spy win");
            break;
        default:
            break;
    }
}
- (void)notifactionResetUIAndData{
    [self resetUIAndData];
}
- (void)removeDeathPlayerViewFromSuperView:(Player *)player{
    if (player.imgView != self.avtorImg) {
        [player.imgView removeFromSuperview];
    }
    if (player.msgViewTip) {
        [player.msgViewTip removeFromSuperview];
        [self.animator removeBehavior:player.attachment];
    }
    if (_voteAttachment) {
        [self.animator removeBehavior:_voteAttachment];
        _voteAttachment = nil;
    }
}
- (void)promptConnectionStatus:(NSString *)tip{
    WEAKSELF
    dispatch_async(dispatch_get_main_queue(), ^{
        [BNRTools popTipMessage:tip atView:self.view.window];
        [weakSelf.navigationController popToRootViewControllerAnimated:NO];
    });
}
- (IBAction)showQuestion:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self.questionLabel sizeToFit];
        CGFloat shiftDistance = self.questionLabel.bounds.size.height/2.f;
        self.questionLabel.center = CGPointMake(self.faceDown.center.x, self.faceDown.frame.origin.y);
        [UIView animateWithDuration:2 animations:^{
            self.faceUp.center = CGPointMake(self.faceUp.center.x,self.faceUp.center.y - shiftDistance);
            self.faceDown.center = CGPointMake(self.faceDown.center.x, self.faceDown.center.y + shiftDistance);
        } completion:^(BOOL finished){
            [UIView animateWithDuration:2 animations:^{
                self.faceUp.center = CGPointMake(self.faceUp.center.x, self.faceUp.center.y + shiftDistance);
                self.faceDown.center = CGPointMake(self.faceDown.center.x, self.faceDown.center.y  - shiftDistance);
            } completion:^(BOOL finished){
            }];

        }];
    }
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    [self setComponentStatusWithGameState:self.spyGame.gameState];
}
- (void)setComponentStatusWithGameState:(GameState)gameState{
    WEAKSELF
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.spyGame.gameMode == GameModeClient) {
            [self.controlBtn setTitle:@"提示" forState:UIControlStateNormal];
            switch (gameState) {
                case GameStateUpdateProfileAvailable:
                    weakSelf.textMsg.editable = NO;
                    weakSelf.voiceButton.enabled = NO;
                    weakSelf.sendTextMsg.enabled = NO;
                    weakSelf.questionLabel.hidden = YES;
                    weakSelf.faceUp.hidden = YES;
                    weakSelf.faceDown.hidden = YES;
                    weakSelf.voteImgView.hidden = YES;
                    weakSelf.popSetProfileViewGesture.enabled = YES;
                    break;
                case GameStateReady:
                    weakSelf.textMsg.editable = NO;
                    weakSelf.voiceButton.enabled = NO;
                    weakSelf.sendTextMsg.enabled = NO;
                    weakSelf.questionLabel.hidden = YES;
                    weakSelf.faceUp.hidden = YES;
                    weakSelf.faceDown.hidden = YES;
                    weakSelf.voteImgView.hidden = YES;
                    weakSelf.popSetProfileViewGesture.enabled = NO;
                    break;
                case GameStateStart:
                    weakSelf.textMsg.editable = YES;
                    weakSelf.voiceButton.enabled = YES;
                    weakSelf.sendTextMsg.enabled = YES;
                    weakSelf.questionLabel.hidden = NO;
                    weakSelf.faceUp.hidden = NO;
                    weakSelf.faceDown.hidden = NO;
                    weakSelf.voteImgView.hidden = NO;
                    break;
                case GameStateVote:
                    [self.controlBtn setTitle:@"请投票" forState:UIControlStateNormal];
                    if (self.spyGame.localPlayer.isAlive) {
                       [BNRTools popTipMessage:@"双击你认为的卧底" atView:self.view];
                    }else
                        [BNRTools popTipMessage:@"你已出局，不能投票" atView:self.view];
                    [self voteInfoDisplay];
                    weakSelf.textMsg.editable = NO;
                    weakSelf.voiceButton.enabled = NO;
                    weakSelf.sendTextMsg.enabled = NO;
                    break;
                case GameStateVoteCount:
                    [self.controlBtn setTitle:@"提示" forState:UIControlStateNormal];
                    weakSelf.textMsg.editable = NO;
                    weakSelf.voiceButton.enabled = NO;
                    weakSelf.sendTextMsg.enabled = NO;
                    break;
                case GameStateOver:
                    [self.controlBtn setTitle:@"等待开始" forState:UIControlStateNormal];
                    weakSelf.questionLabel.hidden = NO;
                    weakSelf.faceUp.hidden = NO;
                    weakSelf.faceDown.hidden = NO;
                    weakSelf.voteImgView.hidden = NO;
                    break;
                default:
                    break;
            }
        }
        else{
            switch (gameState) {
                case GameStateUpdateProfileAvailable:
                    [self.controlBtn setTitle:@"开始游戏" forState:UIControlStateNormal];
                    self.controlBtn.enabled = NO;
                    weakSelf.textMsg.editable = NO;
                    weakSelf.voiceButton.enabled = NO;
                    weakSelf.sendTextMsg.enabled = NO;
                    weakSelf.questionLabel.hidden = YES;
                    weakSelf.faceUp.hidden = YES;
                    weakSelf.faceDown.hidden = YES;
                    weakSelf.voteImgView.hidden = YES;
                    weakSelf.popSetProfileViewGesture.enabled = YES;
                    break;
                case GameStateReady:
                    [self.controlBtn setTitle:@"开始游戏" forState:UIControlStateNormal];
                    self.controlBtn.enabled = YES;
                    weakSelf.textMsg.editable = NO;
                    weakSelf.voiceButton.enabled = NO;
                    weakSelf.sendTextMsg.enabled = NO;
                    weakSelf.questionLabel.hidden = YES;
                    weakSelf.faceUp.hidden = YES;
                    weakSelf.faceDown.hidden = YES;
                    weakSelf.voteImgView.hidden = YES;
                    weakSelf.popSetProfileViewGesture.enabled = NO;
                    break;
                case GameStateStart:
                    [self.controlBtn setTitle:@"开始投票" forState:UIControlStateNormal];
                    self.controlBtn.enabled = YES;
                    weakSelf.textMsg.editable = YES;
                    weakSelf.voiceButton.enabled = YES;
                    weakSelf.sendTextMsg.enabled = YES;
                    weakSelf.questionLabel.hidden = NO;
                    weakSelf.faceUp.hidden = NO;
                    weakSelf.faceDown.hidden = NO;
                    weakSelf.voteImgView.hidden = NO;
                    break;
                case GameStateVote:
                    [self.controlBtn setTitle:@"投票中" forState:UIControlStateNormal];
                    if (self.spyGame.localPlayer.isAlive) {
                        [BNRTools popTipMessage:@"双击你认为的卧底" atView:self.view];
                    }else
                        [BNRTools popTipMessage:@"你已出局，不能投票" atView:self.view];
                    [self voteInfoDisplay];
                    self.controlBtn.enabled = NO;
                    weakSelf.textMsg.editable = NO;
                    weakSelf.voiceButton.enabled = NO;
                    weakSelf.sendTextMsg.enabled = NO;
                    break;
                case GameStateVoteCount:
                    [self.controlBtn setTitle:@"投票结束" forState:UIControlStateNormal];
                    self.controlBtn.enabled = NO;
                    weakSelf.textMsg.editable = NO;
                    weakSelf.voiceButton.enabled = NO;
                    weakSelf.sendTextMsg.enabled = NO;
                    break;
                case GameStateOver:
                    [self.controlBtn setTitle:@"重新开始" forState:UIControlStateNormal];
                    self.controlBtn.enabled = YES;
                    weakSelf.questionLabel.hidden = NO;
                    weakSelf.faceUp.hidden = NO;
                    weakSelf.faceDown.hidden = NO;
                    weakSelf.voteImgView.hidden = NO;
                    break;
                default:
                    break;
            }
        }
    });
}
- (IBAction)controlGame:(UIButton *)sender {
    if (self.spyGame.gameMode == GameModeClient) {
        NSLog(@"tip");
    }
    else{
        switch (self.spyGame.gameState) {
            case GameStateReady:
                [self.spyGame dispatchCard];
                self.spyGame.gameState = GameStateStart;
                break;
             case GameStateStart:
                self.spyGame.gameState = GameStateVote;
                [self.spyGame tellAllStartVote];
                break;
            case GameStateOver:
                [self.spyGame advertiseRestart];
                [self resetUIAndData];
                [self.spyGame dispatchCard];
                self.spyGame.gameState = GameStateStart;
                break;
            default:
                break;
        }
    }
}
- (void)upDateCard{
    self.questionLabel.text = self.spyGame.localPlayer.card;
    [self.questionLabel sizeToFit];
    NSLog(@"recevied:%@",self.spyGame.localPlayer.card);
}
- (void)newMsgPromptForPlayer:(NSInteger)index{
    UIImageView *msgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newMsg"]];
    msgImage.frame = CGRectMake(0, 0, 15, 10);
    [self.view addSubview:msgImage];
    Player *playerVar = self.spyGame.playersArray[index];
    if (playerVar.msgViewTip != nil) {
       [playerVar.msgViewTip removeFromSuperview];
        [self.animator removeBehavior:playerVar.attachment];
    }
    playerVar.msgViewTip = msgImage;
    UIAttachmentBehavior *attachment = [[UIAttachmentBehavior alloc] initWithItem:msgImage attachedToItem:playerVar.imgView];
    [self.animator addBehavior:attachment];
    playerVar.attachment = attachment;
    attachment.length = sqrt(pow(playerVar.imgView.bounds.size.width/2.f, 2));
}
- (IBAction)sendTextMsg:(UIButton *)sender {
    if (![self.textMsg.text isEqualToString:@""]) {
        [self.spyGame sendText:self.textMsg.text];
        self.spyGame.localPlayer.msg = self.textMsg.text;
        self.textMsg.text = @"";
    }
}
- (void)showMsgView:(UITapGestureRecognizer *)tap{
    if (tap.state == UIGestureRecognizerStateEnded) {
        UIImageView *tapView = (UIImageView *)tap.view;
        int i = 0;
        for (i = 0; i < self.spyGame.playersArray.count; i++) {
            Player *playerVar = self.spyGame.playersArray[i];
            if (tapView == playerVar.imgView)  break;
        }
        if (i < self.spyGame.playersArray.count) {
            Player *playerVar = self.spyGame.playersArray[i];
            NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"showMsgView" owner:self options:nil];
            BNRShowMsgView *showMsgView = nibArray[0];
            [showMsgView setAvtorImg:playerVar.img aduioFileName:playerVar.voicePath textMsg:playerVar.msg];
            showMsgView.center = self.view.center;
            [self.view addSubview:showMsgView];
            [playerVar.msgViewTip removeFromSuperview];
            [self.animator removeBehavior:playerVar.attachment];
        }
    }
    
}

#pragma  mark - for vote function
- (void)vote:(UITapGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateEnded) {
        return;
    }
    if (self.spyGame.localPlayer.isAlive == NO) {
        return;
    }
    if (self.spyGame.gameState == GameStateVote)
        if (sender.state == UIGestureRecognizerStateEnded) {
            UIImageView *tapView = (UIImageView *)sender.view;
            int i = 0;
            for (i = 0; i < self.spyGame.playersArray.count; i++) {
                Player *playerVar = self.spyGame.playersArray[i];
                if (tapView == playerVar.imgView)  break;
            }
            if (i < self.spyGame.playersArray.count) {
                Player *playerVar = self.spyGame.playersArray[i];
                if ([self.spyGame availableVoteWithVotePlayer:self.spyGame.localPlayer andVotedPlayer:playerVar] == NO) return;
                [self.spyGame advertiseVoteWithVotePlayer:self.spyGame.localPlayer andVotedPlayer:playerVar];
                [self.spyGame analysisResult];
                if (_voteAttachment) {
                    [self.animator removeBehavior:_voteAttachment];
                    _voteAttachment = nil;
                }
                _voteAttachment = [[UIAttachmentBehavior alloc] initWithItem:self.voteImgView attachedToItem:playerVar.imgView];
                [self.animator addBehavior:_voteAttachment];
                    _voteAttachment.length = sqrt(pow(playerVar.imgView.bounds.size.width/2.f, 2));}
        }
}

- (void)voteInfoDisplay{
    UILabel *votedCountLabel = [[UILabel alloc] init];
    NSInteger votedCount = [self.spyGame countVoted];
    votedCountLabel.text = [NSString stringWithFormat:@"已投票数为:%d",(int)votedCount];
    votedCountLabel.textColor = [UIColor whiteColor];
    votedCountLabel.font = [UIFont STXiheiFontWithSize:14];
    votedCountLabel.tag = 301;
    [votedCountLabel sizeToFit];
    [self.view addSubview:votedCountLabel];
}
- (void)resetUIAndData{
    NSArray *subViews = self.view.subviews;
    for (int i = 13; i < subViews.count; i++) {
        UIView *tmpView = subViews[i];
        [tmpView removeFromSuperview];
    }
    [self.animator removeAllBehaviors];
    _gravity = nil;
    _collision = nil;
    [_pendulumBehaviorArray removeAllObjects];
    _voteAttachment = nil;
    for (int i = 0; i < self.spyGame.playersArray.count; i++) {
        Player *playerVar = self.spyGame.playersArray[i];
        [playerVar.voteID removeAllObjects];
        playerVar.msg = @"";
        playerVar.voicePath = @"";
       // playerVar.isSpy = NO; 
        playerVar.isAlive = YES;
    }
    [self drawPlayersAtGameVCWithLocalPalyer:self.spyGame.localPlayer andPlayers:self.spyGame.playersArray];
}
- (void)dealloc{
    [self.spyGame removeObserver:self forKeyPath:@"gameState"];
    NSLog(@"spygame VC dealloc");
}
@end
