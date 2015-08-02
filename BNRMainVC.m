//
//  BNRMainVC.m
//  ChinesePoker
//
//  Created by IT_yangjing on 1/5/15.
//  Copyright (c) 2015 IT_yangjing. All rights reserved.
//

#import "BNRMainVC.h"
#import "common.h"
#import "BNRHostGameVC.h"
#import "BNRJoinGameVC.h"
#define kCurrentWidth 667
#define kCurrentHeight 375
#define kWidthScale (kWidth/kCurrentWidth)
#define kHeightScale (kHeight/kCurrentHeight)
@interface BNRMainVC ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distanceBetweenLogoAndTop;
@property (weak, nonatomic) IBOutlet UIButton *hostGameButton;
@property (weak, nonatomic) IBOutlet UIButton *joinGameButton;
@property (weak, nonatomic) IBOutlet UIImageView *logo1;
@property (weak, nonatomic) IBOutlet UIImageView *logo2;
@property (weak, nonatomic) IBOutlet UIImageView *logo3;
@property (weak, nonatomic) IBOutlet UIImageView *logo4;
@property (weak, nonatomic) IBOutlet UIImageView *logo5;
@property (nonatomic,assign) BOOL buttonsEnabled;
@property (nonatomic,assign) BOOL performAnimation;

@end

@implementation BNRMainVC
{
    CGPoint _logoCenterArray[5];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _performAnimation = YES;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self fixAutoLayoutByScale];
    [self.navigationController setNavigationBarHidden:YES];
    _performAnimation = YES;
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_performAnimation) {
        [self prepaeForAnimation];
    }
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    _logoCenterArray[0] = self.logo1.center;
    _logoCenterArray[1] = self.logo2.center;
    _logoCenterArray[2] = self.logo3.center;
    _logoCenterArray[3] = self.logo4.center;
    _logoCenterArray[4] = self.logo5.center;

    if (_performAnimation){
        [self performMainAnimation];
    }
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    //recovery the logos center
    self.logo1.center = _logoCenterArray[0];
    self.logo2.center = _logoCenterArray[1];
    self.logo3.center = _logoCenterArray[2];
    self.logo4.center = _logoCenterArray[3];
    self.logo5.center = _logoCenterArray[4];
}
- (void)fixAutoLayoutByScale{
    self.logoWidth.constant *= kHeightScale;
    self.logoHeight.constant *= kHeightScale;
    self.distanceBetweenLogoAndTop.constant *= kHeightScale;
    [self.hostGameButton buttonNewType];
    [self.joinGameButton buttonNewType];
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
- (void)prepaeForAnimation{
    self.logo1.hidden = YES;
    self.logo2.hidden = YES;
    self.logo3.hidden = YES;
    self.logo4.hidden = YES;
    self.logo5.hidden = YES;
    self.buttonsEnabled = NO;
    self.hostGameButton.alpha = 0;
    self.joinGameButton.alpha = 0;
}

- (void)performMainAnimation{
    self.logo1.hidden = NO;
    self.logo2.hidden = NO;
    self.logo3.hidden = NO;
    self.logo4.hidden = NO;
    self.logo5.hidden = NO;
    
    CGPoint point = CGPointMake(self.view.bounds.size.width/2.0f, self.view.bounds.size.height*2.0f);
    self.logo1.center = point;
    self.logo2.center = point;
    self.logo3.center = point;
    self.logo4.center = point;
    self.logo5.center = point;
    
    [UIView animateWithDuration:0.65f delay:0.5f options:UIViewAnimationOptionCurveEaseOut
                     animations:^
    {
        self.logo1.center = CGPointMake(_logoCenterArray[0].x,_logoCenterArray[0].y+20);//_logoCenterArray[0];
        self.logo1.transform = CGAffineTransformMakeRotation(-0.2f);
        self.logo2.center = CGPointMake(_logoCenterArray[1].x,_logoCenterArray[1].y+7);//_logoCenterArray[1];
        self.logo2.transform = CGAffineTransformMakeRotation(-0.1f);
        self.logo3.center = _logoCenterArray[2];
        self.logo4.center = CGPointMake(_logoCenterArray[3].x,_logoCenterArray[3].y+7);
        self.logo4.transform = CGAffineTransformMakeRotation(0.1f);
        self.logo5.center = CGPointMake(_logoCenterArray[4].x,_logoCenterArray[4].y+20);//_logoCenterArray[4];
        self.logo5.transform = CGAffineTransformMakeRotation(0.2f);
    } completion:nil];
    
    [UIView animateWithDuration:0.5f delay:1.0f options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.hostGameButton.alpha = 1.0f;
                         self.joinGameButton.alpha = 1.0f;
                     } completion:^(BOOL finished){
                         _buttonsEnabled = YES;
                     }];
}

- (void)performExitAnimationWithBlock:(void(^)(BOOL))block
{
    _buttonsEnabled = NO;
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseOut
                     animations:^
    {
        self.logo1.center = self.logo3.center;
        self.logo1.transform = self.logo3.transform;
        self.logo2.center = self.logo3.center;
        self.logo2.transform = self.logo3.transform;
        self.logo4.center = self.logo3.center;
        self.logo4.transform = self.logo3.transform;
        self.logo5.center = self.logo3.center;
        self.logo5.transform = self.logo3.transform;
    } completion:^(BOOL finished){
        CGPoint point = CGPointMake(self.logo3.center.x, self.view.frame.size.height*-2.0f);
       [UIView animateWithDuration:1.0f delay:0
                           options:UIViewAnimationOptionCurveEaseOut
                        animations:^{
                            self.logo1.center = point;
                            self.logo2.center = point;
                            self.logo3.center = point;
                            self.logo4.center = point;
                            self.logo5.center = point;
                        } completion:block];
        [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.hostGameButton.alpha = 0.0f;
                             self.joinGameButton.alpha = 0.0f;
                         } completion:nil];
    }];
}
- (IBAction)hostGame:(id)sender {
    [self performExitAnimationWithBlock:^(BOOL finished){
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BNRHostGameVC *hostGameVC = [storyBoard instantiateViewControllerWithIdentifier:@"hostGameVC"];
        [self.navigationController pushViewController:hostGameVC animated:NO];
    }];
}
- (IBAction)joinGame:(id)sender {
    [self performExitAnimationWithBlock:^(BOOL finished){
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BNRJoinGameVC *joinGameVC = [storyBoard instantiateViewControllerWithIdentifier:@"joinGameVC"];
        [self.navigationController pushViewController:joinGameVC animated:NO];
    }];

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
