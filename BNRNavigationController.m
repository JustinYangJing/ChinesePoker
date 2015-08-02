//
//  BNRNavigationController.m
//  ChinesePoker
//
//  Created by IT_yangjing on 1/7/15.
//  Copyright (c) 2015 IT_yangjing. All rights reserved.
//

#import "BNRNavigationController.h"
#import "BNRMainVC.h"
@interface BNRNavigationController ()

@end

@implementation BNRNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (BOOL)shouldAutorotate{
   return  [[self.viewControllers lastObject] shouldAutorotate];
}
- (NSUInteger)supportedInterfaceOrientations{
    return [[self.viewControllers lastObject] supportedInterfaceOrientations];
    
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
}
//- (NSUInteger)supportedInterfaceOrientations{
//    return UIInterfaceOrientationMaskLandscape;
//}
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
//    return UIInterfaceOrientationLandscapeRight;
//}
//- (BOOL)shouldAutorotate{
//    return YES;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
