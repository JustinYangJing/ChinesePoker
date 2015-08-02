//
//  BNRGobangVC.h
//  ChinesePoker
//
//  Created by IT_yangjing on 15/1/26.
//  Copyright (c) 2015年 IT_yangjing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "common.h"
#import "GobangGame.h"
#import "BNRGobangView.h"
@interface BNRGobangVC : UIViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate,GobangDelegate,BNRGobangViewDelegate>
@property (nonatomic,strong) GobangGame* game;
@end
