//
//  BNRJoinGameVC.m
//  ChinesePoker
//
//  Created by IT_yangjing on 1/10/15.
//  Copyright (c) 2015 IT_yangjing. All rights reserved.
//

#import "BNRJoinGameVC.h"
#import "BNRMatchMakingClient.h"
#import "BNRSpyGameVC.h"
#import "BNRGobangVC.h"
#import "GobangGame.h"
@interface BNRJoinGameVC ()
@property (weak, nonatomic) IBOutlet UILabel *joinGameLabel;
@property (weak, nonatomic) IBOutlet UILabel *playerName;
@property (weak, nonatomic) IBOutlet UITextField *myNameTextFeild;
@property (weak, nonatomic) IBOutlet UILabel *availabelGameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *tableViewBorder;
@property (strong,nonatomic) UITableView *tableView;
@property (strong,nonatomic)BNRMatchMakingClient *client;
@end

@implementation BNRJoinGameVC
{
    int _joinGameType;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initUI];
    [self serachServer];
}
- (void)initUI{
    self.joinGameLabel.font = [UIFont STXiheiFontWithSize:20];
    self.playerName.font = [UIFont STXiheiFontWithSize:20];
    self.myNameTextFeild.font = [UIFont STXiheiFontWithSize:18];
    self.myNameTextFeild.delegate = self;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self.myNameTextFeild action:@selector(resignFirstResponder)];
    [self.view addGestureRecognizer:tap];
    self.myNameTextFeild.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, self.myNameTextFeild.frame.size.height)];
    self.myNameTextFeild.leftViewMode = UITextFieldViewModeAlways;
    self.myNameTextFeild.placeholder = [UIDevice currentDevice].name;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
    self.availabelGameLabel.font = [UIFont STXiheiFontWithSize:20];
    [self addTableViewIntoBorder];
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
- (void)serachServer{
    _client = [[BNRMatchMakingClient alloc] init];
    _client.delegate = self;
    [_client startSearchingForServers];
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
- (IBAction)back:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:NO];
}


#pragma mark - textfeild delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _client.availableServers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"serverRoom"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"serverRoom"];
        cell.textLabel.font = [UIFont STXiheiFontWithSize:20];
        cell.detailTextLabel.font = [UIFont STXiheiFontWithSize:16];
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectedBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"CellBackgroundSelected"]];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    NSDictionary *dic = _client.availableServers[indexPath.row];
    MCPeerID *peerID = [dic objectForKey:@"peerID"];
    cell.textLabel.text = peerID.displayName;
    NSString *gameType = [dic objectForKey:@"whichGame"];
    switch (gameType.intValue) {
        case 1:
            cell.detailTextLabel.text = @"谁是卧底";
            break;
        case 2:
            cell.detailTextLabel.text = @"斗地主";
            break;
        case 3:
            cell.detailTextLabel.text = @"五子棋";
            break;
        default:
            break;
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"accessory");
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *gameTypeString = cell.detailTextLabel.text;
    if ([gameTypeString isEqualToString:@"谁是卧底"]) {
        _joinGameType = 1;
    }else if ([gameTypeString isEqualToString:@"斗地主"]){
        _joinGameType = 2;
    }else{
        _joinGameType = 3;
    }
    [_client connectavailableServersAtIndex:indexPath.row];
}

#pragma mark - matchMakingClientDelegate
- (void)matchMakingClient:(BNRMatchMakingClient *)client serverDidChange:(MCPeerID *)peerID{
    dispatch_async(dispatch_get_main_queue(), ^{
       [self.tableView reloadData];
    });
}
- (void)promptConnectionStatus:(MCSessionState)state{
    switch (state) {
        case MCSessionStateNotConnected:
            [BNRTools popTipMessage:@"丢失连接,请重新加入" atView:self.view.window];
            [self.navigationController popToRootViewControllerAnimated:NO];
            break;
        case MCSessionStateConnecting:
            [BNRTools popTipMessage:@"正在连接..." atView:self.view];
            break;
        case MCSessionStateConnected:
            [BNRTools popTipMessage:@"连接成功" atView:self.view.window];
            break;
        default:
            break;
    }

}
- (void)pushToGameVCWithSession:(MCSession *)session{
    if (_joinGameType == 1) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BNRSpyGameVC *spyGameVC = [storyboard instantiateViewControllerWithIdentifier:@"spyGameVC"];
        spyGameVC.spyGame = [[SpyGame alloc] initWithSession:session withMode:GameModeClient];
        if ([self.myNameTextFeild.text isEqualToString:@""]) {
            spyGameVC.spyGame.localPlayer.name = self.myNameTextFeild.placeholder;
        }else
            spyGameVC.spyGame.localPlayer.name = self.myNameTextFeild.text;
        [self.navigationController pushViewController:spyGameVC animated:YES];
    }
    else if (_joinGameType == 2){ //chinese poker
    }else if(_joinGameType == 3){ //gobang
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BNRGobangVC *gobangVC = [storyboard instantiateViewControllerWithIdentifier:@"gobangVC"];
        gobangVC.game = [[GobangGame alloc] initWithSession:self.client.session withGameMode:GameModeClient];
        if (![self.myNameTextFeild.text isEqualToString:@""]) {
            gobangVC.game.localPlayer.name = self.myNameTextFeild.text;
        }else{
            gobangVC.game.localPlayer.name = self.myNameTextFeild.placeholder;
        }
        gobangVC.game.localPlayer.avtor = [UIImage imageNamed:@"pic_0000_password"];
        gobangVC.game.localPlayer.ID = @"101";
        gobangVC.game.localPlayer.peerID = self.client.session.myPeerID;
        gobangVC.game.vsPlayer.ID = @"100";
        gobangVC.game.vsPlayer.avtor = [UIImage imageNamed:@"boss"];
        gobangVC.game.vsPlayer.peerID = self.client.session.connectedPeers[0];
        [self.navigationController pushViewController:gobangVC animated:YES];
    
    }
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
