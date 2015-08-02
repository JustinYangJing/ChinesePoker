//
//  BNRGobangVC.m
//  ChinesePoker
//
//  Created by IT_yangjing on 15/1/26.
//  Copyright (c) 2015年 IT_yangjing. All rights reserved.
//

#import "BNRGobangVC.h"

@interface BNRGobangVC ()
@property (weak, nonatomic) IBOutlet UILabel *localPlayerName;
@property (weak, nonatomic) IBOutlet UIImageView *localPlayerAvtor;
@property (weak, nonatomic) IBOutlet UISegmentedControl *whichOneFirst;
@property (weak, nonatomic) IBOutlet UIButton *goBackStep;
@property (weak, nonatomic) IBOutlet UIButton *startBtn;
@property (weak, nonatomic) IBOutlet UILabel *vsPlayerName;
@property (weak, nonatomic) IBOutlet UIImageView *vsPlayerAvtor;
@property (strong,nonatomic) BNRGobangView *gobangView;
@end

@implementation BNRGobangVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initUI];
}
#pragma mark - other init and set for VC
- (void)initUI{
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundForGobang"]];
    self.localPlayerName.font = [UIFont STXiheiFontWithSize:17];
    self.localPlayerName.textColor = [UIColor lightGrayColor];
    NSDictionary *attrs = @{NSFontAttributeName:[UIFont STXiheiFontWithSize:13],NSForegroundColorAttributeName:[UIColor lightGrayColor]};
    [self.whichOneFirst setTitleTextAttributes:attrs forState:UIControlStateNormal];
    [self.goBackStep buttonNewType];
    [self.startBtn buttonNewType];
    self.vsPlayerName.font = [UIFont STXiheiFontWithSize:17];
    self.vsPlayerName.textColor = [UIColor lightGrayColor];
    
    self.gobangView = [[BNRGobangView alloc] init]; //]WithFrame:CGRectMake(0, 0, 375, 375)];
    self.gobangView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.gobangView];
    self.gobangView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *dic = NSDictionaryOfVariableBindings(_gobangView);
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_gobangView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_gobangView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_gobangView]-0-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:dic]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_gobangView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_gobangView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
    [self.gobangView enableBoard:NO];
    self.gobangView.delegate = self;
    
    if (self.game.gameMode == GameModeServer) {
        self.localPlayerAvtor.image = self.game.localPlayer.avtor;
        self.localPlayerName.text = self.game.localPlayer.name;
        self.vsPlayerName.text = self.game.vsPlayer.peerID.displayName;
        [self.whichOneFirst setSelectedSegmentIndex:0];
        [self.whichOneFirst addTarget:self action:@selector(changeWhoIsFirst:) forControlEvents:UIControlEventValueChanged];
        self.goBackStep.enabled = NO;
        [self.startBtn setTitle:@"开始" forState:UIControlStateNormal];
        self.gobangView.role = 0;
    }
    else{
        self.localPlayerName.text = self.game.localPlayer.name;
        self.localPlayerAvtor.image = self.game.localPlayer.avtor;
        self.vsPlayerAvtor.image = self.game.vsPlayer.avtor;
        self.vsPlayerName.text = self.game.vsPlayer.peerID.displayName;
        [self.whichOneFirst setSelectedSegmentIndex:0];
        self.whichOneFirst.enabled = NO;
        self.goBackStep.enabled = NO;
        self.localPlayerAvtor.userInteractionEnabled = NO;
        [self.startBtn setTitle:@"等待开始" forState:UIControlStateNormal];
        self.startBtn.enabled = NO;
        self.gobangView.role = 1;
    }
    self.game.delegate = self;
    
}
- (void)changeWhoIsFirst:(UISegmentedControl *)segmentControl{
    if (self.game.gameMode == GameModeServer) {
        self.gobangView.isBaiZiFirst = segmentControl.selectedSegmentIndex == 0?YES:NO;
    }
}
- (IBAction)exit:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:NO];
}
- (IBAction)goBackToPrevious:(id)sender {
    [self.gobangView undoPreviousStep];
    [self.game postPreviousStep];
}

- (IBAction)popSetProfile:(UILongPressGestureRecognizer *)sender {
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
    UIGraphicsBeginImageContext(self.localPlayerAvtor.frame.size);
    [image drawInRect:CGRectMake(0, 0, self.localPlayerAvtor.frame.size.width, self.localPlayerAvtor.frame.size.height)];
    UIImage  *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.game.localPlayer.avtor = newImage;
    self.localPlayerAvtor.image = newImage;
    self.localPlayerAvtor.layer.masksToBounds = YES;
    self.localPlayerAvtor.layer.cornerRadius = CGRectGetHeight([self.localPlayerAvtor bounds])/2.0;
    UIView *view = [self.view viewWithTag:101];
    [view removeFromSuperview];
    WEAKSELF;
    [picker dismissViewControllerAnimated:YES completion:^{
        [weakSelf.game updateProfile];
    }];
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    UIView *view = [self.view viewWithTag:101];
    [view removeFromSuperview];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
- (IBAction)controlGame:(UIButton *)sender {
    if (self.game.gameMode == GameModeServer) {
        switch (self.game.gameState) {
            case GobangGameStateReady:
                [self.startBtn setTitle:@"重新开始" forState:UIControlStateNormal];
                self.game.gameState = GameStateStart;
                //self.whichOneFirst.enabled = NO;
                self.gobangView.isBaiZiFirst = (self.whichOneFirst.selectedSegmentIndex == 0)?YES:NO;
                self.goBackStep.enabled = YES;
                [self.gobangView enableBoard:YES];
                [self.game postStartWithWhoIsFirst:self.whichOneFirst.selectedSegmentIndex];
                break;
            case GobangGameStateStart:
                [self.startBtn setTitle:@"重新开始" forState:UIControlStateNormal];
                self.game.gameState = GameStateStart;
                //self.whichOneFirst.enabled = NO;
                self.gobangView.isBaiZiFirst = (self.whichOneFirst.selectedSegmentIndex == 0)?YES:NO;
                self.goBackStep.enabled = YES;
                [self.gobangView restart];
                [self.game postStartWithWhoIsFirst:self.whichOneFirst.selectedSegmentIndex];              break;
            case GobangGameStateOver:
                [self.startBtn setTitle:@"重新开始" forState:UIControlStateNormal];
                self.game.gameState = GameStateStart;
               // self.whichOneFirst.enabled = NO;
                self.gobangView.isBaiZiFirst = (self.whichOneFirst.selectedSegmentIndex == 0)?YES:NO;
                self.goBackStep.enabled = YES;
                [self.gobangView restart];
                [self.gobangView enableBoard:YES];
                [self.game postStartWithWhoIsFirst:self.whichOneFirst.selectedSegmentIndex];                 break;
            default:
                break;
        }
    }
}

#pragma mark - keep iphone as landscape
- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationLandscapeRight;
}
- (BOOL)shouldAutorotate{
    return YES;
}

#pragma mark - gobangGame delegate
- (void)promptConnectionStatus:(NSString *)tip{
    WEAKSELF
    dispatch_async(dispatch_get_main_queue(), ^{
        [BNRTools popTipMessage:tip atView:self.view.window];
        [weakSelf.navigationController popToRootViewControllerAnimated:NO];
    });
}
- (void)refreshVsPlayer{
    self.vsPlayerName.text = self.game.vsPlayer.name;
    self.vsPlayerAvtor.image = self.game.vsPlayer.avtor;
    self.vsPlayerAvtor.layer.masksToBounds = YES;
    self.vsPlayerAvtor.layer.cornerRadius = CGRectGetHeight([self.vsPlayerAvtor bounds])/2.0;
}
- (void)notificationStartWithWhoFirst:(NSInteger )index{
    [self.gobangView enableBoard:YES];
    if (self.game.gameMode == GameModeClient) {
        self.whichOneFirst.selectedSegmentIndex = index;
        self.localPlayerAvtor.userInteractionEnabled = YES;
        [self.startBtn setTitle:@"游戏中" forState:UIControlStateNormal];
        self.goBackStep.enabled = YES;
        [self.gobangView restart];
        self.gobangView.isBaiZiFirst = (index == 0)?YES:NO;
    }
}
- (void)notificationMoveCardAtIndexPath:(NSIndexPath *)path{
    [self.gobangView moveWithX:(int)path.row withY:(int)path.section];
}
#pragma mark - gobangView delegeta
-(void)gobangView:(BNRGobangView *)view tapAtIndexPath:(NSIndexPath *)path{
    [self.game sendMoveCardAtIndexPath:path];
}
- (void)notificateWin:(NSString *)whoWin{
    NSString *tip = nil;
    if ([whoWin isEqualToString:@"baizi"])
        tip = @"白子胜利";
    else
        tip = @"黑子胜利";
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:tip delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alertView show];
    self.game.gameState = GobangGameStateOver;
    self.goBackStep.enabled = NO;
    [self.gobangView enableBoard:NO];
    if (self.game.gameMode == GameModeClient) {
        [self.startBtn setTitle:@"游戏结束" forState:UIControlStateNormal];
    }
}

- (void)notificationGoToPreviousStep{
    [self.gobangView undoPreviousStep];
}
@end
