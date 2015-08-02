//
//  BNRSpyGameVC.h
//  ChinesePoker
//
//  Created by IT_yangjing on 1/12/15.
//  Copyright (c) 2015 IT_yangjing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "common.h"
#import "SpyGame.h"
@interface BNRSpyGameVC : UIViewController <UITextViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,SpyGameDelegate,UIDynamicAnimatorDelegate,UICollisionBehaviorDelegate>
@property (nonatomic,strong)SpyGame *spyGame;
@end
