//
//  BNRRopeView.m
//  ChinesePoker
//
//  Created by IT_yangjing on 15/1/20.
//  Copyright (c) 2015年 IT_yangjing. All rights reserved.
//

#import "BNRRopeView.h"
@interface BNRRopeView ()
@property (nonatomic,strong) UIView *attachedView;
@property (nonatomic,strong) NSMutableArray *ropesArray;
@end
@implementation BNRRopeView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)dealloc{
    [self.attachedView removeObserver:self forKeyPath:@"center"];
}

- (instancetype)initWithAnchorPoint:(CGPoint)p withAttachedView:(UIView *)view ropeLength:(CGFloat)len
{
    if (!_ropesArray) {
        UIImageView *previousView = nil;
        UIImage *ropeImg = [UIImage imageNamed:@"ropeTexture"];
        int numberOfRope = len / ropeImg.size.height;
        _ropesArray = [NSMutableArray arrayWithCapacity:numberOfRope];
        UIDynamicAnimator *animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
        UIGravityBehavior *gravity = [[UIGravityBehavior alloc] init];
        [animator addBehavior:gravity];
        for (int i = 0; i < numberOfRope; i++) {
            if (i == 0) {
                UIImageView *imgView = [[UIImageView alloc] initWithImage:ropeImg];
                imgView.bounds = CGRectMake(0, 0, ropeImg.size.width, ropeImg.size.height);
                imgView.center = CGPointMake(p.x, p.y+ropeImg.size.height/2.0f);
                [self addSubview:imgView];
                UIAttachmentBehavior *attachment = [[UIAttachmentBehavior alloc]initWithItem:imgView attachedToAnchor:p];
                [animator addBehavior:attachment];
                [gravity addItem:imgView];
                previousView = imgView;
            }else if(i == numberOfRope - 1){
                UIImageView *imgView = [[UIImageView alloc] initWithImage:ropeImg];
                imgView.bounds = CGRectMake(0, 0, ropeImg.size.width, ropeImg.size.height);
                imgView.center = CGPointMake(previousView.center.x,previousView.center.y + ropeImg.size.height);
                [self addSubview:imgView];
                UIAttachmentBehavior *attachment = [[UIAttachmentBehavior alloc] initWithItem:imgView attachedToItem:previousView];
                [animator addBehavior:attachment];
                UIAttachmentBehavior *attachment1 = [[UIAttachmentBehavior alloc] initWithItem:imgView attachedToItem:view];
                [animator addBehavior:attachment1];
                [gravity addItem:imgView];
            }
            else{
                UIImageView *imgView = [[UIImageView alloc] initWithImage:ropeImg];
                imgView.bounds = CGRectMake(0, 0, ropeImg.size.width, ropeImg.size.height);
                imgView.center = CGPointMake(previousView.center.x,previousView.center.y + ropeImg.size.height);
                [self addSubview:imgView];
                UIAttachmentBehavior *attachment = [[UIAttachmentBehavior alloc] initWithItem:imgView attachedToItem:previousView];
                [animator addBehavior:attachment];
                [gravity addItem:imgView];
                previousView = imgView;
            }
            
        }
        
    }
    return nil;
}
@end
