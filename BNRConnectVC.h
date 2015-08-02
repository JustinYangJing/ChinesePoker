//
//  BNRConnectVC.h
//  ChinesePoker
//
//  Created by IT_yangjing on 1/8/15.
//  Copyright (c) 2015 IT_yangjing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BNRMatchMakingServer.h"
@interface BNRConnectVC : UIViewController<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,BNRMatchMakingServerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (nonatomic,assign)int whichGame; //1:who is spy ,2:chinese poker ,3:gobang

@end
