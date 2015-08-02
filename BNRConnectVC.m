//
//  BNRConnectVC.m
//  ChinesePoker
//
//  Created by IT_yangjing on 1/8/15.
//  Copyright (c) 2015 IT_yangjing. All rights reserved.
//

#import "BNRConnectVC.h"
#import "common.h"
#import "SpyGame.h"
#import "BNRSpyGameVC.h"
#import "BNRGobangVC.h"
@interface BNRConnectVC ()
@property (weak, nonatomic) IBOutlet UITextField *myName;
@property (weak, nonatomic) IBOutlet UILabel *playerName;
@property (weak, nonatomic) IBOutlet UILabel *noteLabel;
@property (weak, nonatomic) IBOutlet UIButton *readyStart;
@property (weak, nonatomic) IBOutlet UILabel *gameName;
@property (weak, nonatomic) IBOutlet UIImageView *tableViewBorder;
@property (strong,nonatomic) BNRMatchMakingServer *server;
@property (strong,nonatomic)UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *avtorImg;
@end

@implementation BNRConnectVC
{
    int _minPlayerNumber;
}
- (IBAction)backToMainVC:(id)sender {
    [_server endSession];
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)readyStart:(id)sender {
    switch (_whichGame) {
        case 1:
            if (_server.connectedClients.count >= 2)
            {
                [_server stopAcceptingConnections];
                NSLog(@"ready to start who is spy");// should send players imformation to others,tell all how many players
                [self.server advertisePlayersInfo];
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                BNRSpyGameVC *spyGameVC = [storyboard instantiateViewControllerWithIdentifier:@"spyGameVC"];
                spyGameVC.spyGame = [[SpyGame alloc] initWithSession:self.server.session withMode:GameModeServer];
                spyGameVC.spyGame.localPlayer = [self getPlayerFromHost];
                [spyGameVC.spyGame.playersArray addObject:spyGameVC.spyGame.localPlayer];
                [spyGameVC.spyGame.playersArray addObjectsFromArray:self.server.arrayPlayers];
                [self.navigationController pushViewController:spyGameVC animated:YES];
            }
            else{
                [BNRTools popTipMessage:@"至少有4个人才能玩" atView:self.view];
            }
            break;
        case 2:
            if (_server.connectedClients.count != 2) {
                [BNRTools popTipMessage:@"必须是3个人才能玩" atView:self.view];
            }
            else{
                NSLog(@"ready to start chinese poker");
            }
            break;
        case 3:
            if (_server.connectedClients.count != 1) {
                [BNRTools popTipMessage:@"必须是2个人才能玩" atView:self.view];
            }
            else{
                NSLog(@"ready to start gobang");
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                BNRGobangVC *gobangVC = [storyboard instantiateViewControllerWithIdentifier:@"gobangVC"];
                gobangVC.game = [[GobangGame alloc] initWithSession:self.server.session withGameMode:GameModeServer];
                if (![self.myName.text isEqualToString:@""]) {
                    gobangVC.game.localPlayer.name = self.myName.text;
                }else{
                    gobangVC.game.localPlayer.name = self.myName.placeholder;
                }
                gobangVC.game.localPlayer.avtor = [UIImage imageNamed:@"boss"];
                gobangVC.game.localPlayer.ID = @"100";
                gobangVC.game.localPlayer.peerID = self.server.session.myPeerID;
                gobangVC.game.vsPlayer.ID = @"101";
                gobangVC.game.vsPlayer.peerID = self.server.session.connectedPeers[0];
                [self.navigationController pushViewController:gobangVC animated:YES];
            }
            break;
        default:
            break;
    }

}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self.myName action:@selector(resignFirstResponder)];
    [self.view addGestureRecognizer:tap];
    self.myName.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, self.myName.frame.size.height)];
    self.myName.leftView.backgroundColor = [UIColor clearColor];
    self.myName.leftViewMode = UITextFieldViewModeAlways;
    self.myName.font = [UIFont STXiheiFontWithSize:18.0f];
    self.playerName.font = [UIFont STXiheiFontWithSize:20.0f];
    self.noteLabel.font = [UIFont STXiheiFontWithSize:20.0f];
    switch (_whichGame) {
        case 1:
            self.gameName.text = @"谁是卧底";
            _minPlayerNumber = 4;
            break;
        case 2:
            self.gameName.text = @"斗地主";
            _minPlayerNumber = 3;
            break;
        case 3:
            self.gameName.text = @"五子棋";
            _minPlayerNumber = 2;
            break;
        default:
            break;
    }
    self.gameName.font = [UIFont STXiheiFontWithSize:20.0f];
    [self.readyStart buttonNewType];
    [self addTableViewIntoBorder];
    _server = [[BNRMatchMakingServer alloc] init];
    _server.delegate = self;
    NSDictionary *infoDic = @{@"whichGame":[NSString stringWithFormat:@"%d",_whichGame],
                              @"minNumberOfPlayer":[NSString stringWithFormat:@"%d",_minPlayerNumber],
                              @"name":self.myName.text};
    [_server startAcceptingConnectionsWith:infoDic];
    self.myName.placeholder = [UIDevice currentDevice].name;
    
}

- (void)addTableViewIntoBorder{
    //add table view in table view border
    _tableView = [[UITableView alloc] init];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.tableViewBorder addSubview:_tableView];
    
    //layout in border view
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *dicView = NSDictionaryOfVariableBindings(_tableViewBorder,_tableView);
    [self.tableViewBorder addConstraints:[NSLayoutConstraint
                                         constraintsWithVisualFormat:@"H:|-0-[_tableView]-5-|"
                                         options:NSLayoutFormatDirectionLeadingToTrailing
                                          metrics:nil views:dicView]];
    [self.tableViewBorder addConstraints:[NSLayoutConstraint
                                          constraintsWithVisualFormat:@"V:|-2-[_tableView]-2-|"
                                          options:NSLayoutFormatDirectionLeadingToTrailing
                                          metrics:nil views:dicView]];
}
- (IBAction)popSetAvtorView:(UILongPressGestureRecognizer *)sender {
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
    self.avtorImg.image = newImage;
    self.avtorImg.layer.masksToBounds = YES;
    self.avtorImg.layer.cornerRadius = CGRectGetHeight([self.avtorImg bounds])/2.0;
    UIView *view = [self.view viewWithTag:101];
    [view removeFromSuperview];
    [picker dismissViewControllerAnimated:YES completion:nil];
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    UIView *view = [self.view viewWithTag:101];
    [view removeFromSuperview];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - table view delegate and datasoure
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_server) {
        long count = [_server.connectedClients count];
        switch (_whichGame) {
            case 1:
                break;
            case 2:
                if (count == 2) {
                    [_server stopAcceptingConnections];
                }
                break;
            case 3:
                if (count == 1) {
                    [_server stopAcceptingConnections];
                }
                break;
            default:
                break;
        }
       return count;
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"playersCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"playersCell"];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.numberOfLines = 0;
        //note :keep space in label ,add '\r' in string could make jump to next line 
        cell.textLabel.lineBreakMode = NSLineBreakByCharWrapping;
    }
    if (indexPath.row >= _server.connectedClients.count ) {
        return cell;
    }
    MCPeerID *peerID = [_server.connectedClients objectAtIndex:indexPath.row];
    cell.textLabel.text = peerID.displayName;
    cell.textLabel.font = [UIFont STXiheiFontWithSize:20];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
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


#pragma mark - textfeild delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - BNRMatchMakingServerDelegate
- (void)matchmakingServer:(BNRMatchMakingServer *)server clientDidConnect:(MCPeerID *)peerID{
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.tableView reloadData];
    });
    
}
- (void)matchmakingServer:(BNRMatchMakingServer *)server clientDidDisconnect:(MCPeerID *)peerID{
    [self.tableView reloadData];
}
- (void)matchmakingServerNoNetwork:(BNRMatchMakingServer *)server
{
#ifdef DEBUG
    NSLog(@"NO network");
#endif
}
- (void)matchmakingServerSessionDidEnd:(BNRMatchMakingServer *)server{
    _server.delegate = nil;
    _server = nil;
    [self.tableView reloadData];
}
- (Player *)getPlayerFromHost{
    Player *hostPlayer = [[Player alloc] init];
    if (![self.myName.text isEqualToString:@""]) {
        hostPlayer.name = self.myName.text;
    }else{
        hostPlayer.name = self.myName.placeholder;
    }
    hostPlayer.img = [UIImage imageNamed:@"boss"];
    hostPlayer.peerID = self.server.localPeerID;
    hostPlayer.ID = [NSString stringWithFormat:@"%d",100]; //hostPlayer.ID is always 100
    return hostPlayer;
}

- (void)dealloc{
    NSLog(@"delloc :%@",self);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
