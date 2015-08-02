//
//  BNRHostGameVC.m
//  ChinesePoker
//
//  Created by IT_yangjing on 1/7/15.
//  Copyright (c) 2015 IT_yangjing. All rights reserved.
//

#import "BNRHostGameVC.h"
#import "BNRConnectVC.h"
#import "BNRShowMsgView.h"
@interface BNRHostGameVC ()
@property (weak, nonatomic) IBOutlet UIButton *entryButton;
@property (weak, nonatomic) IBOutlet UIImageView *whoIsSpy;
@property (weak, nonatomic) IBOutlet UIButton *chinesePoker;
@property (weak, nonatomic) IBOutlet UIButton *gobang;


@end


@implementation BNRHostGameVC
{
    int _whichOneShouldBeDrag; //0:no one should be draged , 1:whoIsSpy should be Draged 2:chinesePoker should be draged 3:gobang should be draged
    BOOL _alreadyEntryAnotherVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self drawEntryButton];
    [self initForInstance];
}
- (void)initForInstance{
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _alreadyEntryAnotherVC = NO;
}
- (void)drawEntryButton{
    CAShapeLayer *shapeLayer = [CAShapeLayer new];
    UIBezierPath *stroPath = [UIBezierPath bezierPath];//bezierPathWithRect:self.entryButton.bounds];
    shapeLayer.frame = self.entryButton.bounds;
    //[stroPath addArcWithCenter:CGPointMake(shapeLayer.frame.size.width/2.0f, shapeLayer.frame.size.width/2.0f) radius:shapeLayer.frame.size.width/2.0f startAngle:0 endAngle:2*M_PI clockwise:YES];
    [stroPath moveToPoint:CGPointMake(0, 0)];
    [stroPath addLineToPoint:CGPointMake(self.entryButton.bounds.size.width, 0)];
    [stroPath addLineToPoint:CGPointMake(self.entryButton.bounds.size.width, self.entryButton.bounds.size.height)];
    [stroPath addLineToPoint:CGPointMake(0, self.entryButton.bounds.size.height)];
    [stroPath closePath];
    
    shapeLayer.lineWidth = 5.0f;
    shapeLayer.path = stroPath.CGPath;
    shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
    shapeLayer.fillColor = nil;
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.shadowColor = [UIColor yellowColor].CGColor;
    shapeLayer.shadowOffset = CGSizeMake(0, 0);
    shapeLayer.shadowRadius = 10.0;
    shapeLayer.shadowOpacity = 1.0f;
    
    
    
    [self.entryButton.layer addSublayer:shapeLayer];
    self.entryButton.hidden = YES;
//    self.entryButton.layer.cornerRadius = 4.0f;
//    self.entryButton.layer.masksToBounds = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)backToMainVC:(id)sender {
    [self.navigationController popViewControllerAnimated:NO];
}
- (IBAction)dragIntoConnectVC:(UIPanGestureRecognizer *)sender {
    static CGPoint originPoint;
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.entryButton.hidden = NO;
        originPoint = sender.view.center;
    }
    CGPoint currentPoint = [sender locationInView:self.view];
    sender.view.center = currentPoint;
    if (CGRectContainsPoint(CGRectMake(self.entryButton.frame.origin.x+10, self.entryButton.frame.origin.y+10, self.entryButton.frame.size.width-20, self.entryButton.frame.size.height-20), currentPoint)) {
        if (_alreadyEntryAnotherVC == NO) {
            _alreadyEntryAnotherVC = YES;
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            BNRConnectVC *connectVC = [storyboard instantiateViewControllerWithIdentifier:@"connectVC"];
            connectVC.whichGame = (int)sender.view.tag - 100;
            [self.navigationController pushViewController:connectVC animated:YES];
            [UIView animateWithDuration:0.4f animations:^{
                sender.view.center = originPoint;
                self.entryButton.alpha = 0.0f;
            } completion:^(BOOL finished){
                self.entryButton.hidden = YES;
                self.entryButton.alpha = 1.0f;
            }];
        }
    }
    if (sender.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.4f animations:^{
            sender.view.center = originPoint;
            self.entryButton.alpha = 0.0f;
        } completion:^(BOOL finished){
            self.entryButton.hidden = YES;
            self.entryButton.alpha = 1.0f;
        }];
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
