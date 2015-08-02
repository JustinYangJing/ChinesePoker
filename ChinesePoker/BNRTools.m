//
//  BNRTools.m
//  ChinesePoker
//
//  Created by IT_yangjing on 1/10/15.
//  Copyright (c) 2015 IT_yangjing. All rights reserved.
//

#import "BNRTools.h"
#import "UIFont+NewFont.h"
@implementation BNRTools
+ (void) popTipMessage:(NSString *)msg withRect:(CGRect)rect inView:(UIView *)view{
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:rect];
    tipLabel.text = msg;
    tipLabel.textColor = [UIColor whiteColor];
    tipLabel.backgroundColor = [UIColor clearColor];
    tipLabel.alpha = 0.8;
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.font = [UIFont systemFontOfSize:20];
    tipLabel.transform = CGAffineTransformScale(tipLabel.transform, 0.001, 0.001);
    tipLabel.layer.cornerRadius = 10.0;
    tipLabel.layer.backgroundColor =[UIColor grayColor].CGColor;
    tipLabel.font = [UIFont STXiheiFontWithSize:20];
    [view addSubview:tipLabel];
    [UIView animateWithDuration:0.5 animations:^{
        tipLabel.transform = CGAffineTransformScale(tipLabel.transform, 1000, 1000);
    }];
    
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(disapperTipView:) userInfo:tipLabel repeats:NO];
}
+ (void) disapperTipView:(NSTimer *)timer{
    UIView * label = (UIView *)timer.userInfo;
    [label removeFromSuperview];
}

+ (void) popTipMessage:(NSString *)tipStr atView:(UIView *)view{
    CGSize size = [tipStr sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20]}];
    CGRect rect = CGRectMake(view.center.x - size.width/2 - 15, view.center.y - size.height/2 - 15, size.width+30, size.height+30);
    [self popTipMessage:tipStr withRect:rect
                 inView:view];
}

+ (NSArray *)getQuestionFromFile{
    const NSArray *questionArray = @[@[@"何炅",@"维嘉"],@[@"王菲",@"那英"],@[@"元芳",@"展昭"],@[@"麻雀",@"乌鸦"],@[@"胖子",@"肥肉"],
                                     @[@"眉毛",@"胡须"],@[@"状元",@"冠军"],@[@"饺子",@"包子"],@[@"端午节",@"中秋节"],@[@"摩托车",@"电动车"],
                                     @[@"高跟鞋",@"增高鞋"],@[@"汉堡包",@"肉夹馍"],@[@"小矮人",@"葫芦娃"],@[@"蜘蛛侠",@"蜘蛛精"],@[@"节节高升",@"票房大卖"],
                                     @[@"反弹琵琶",@"乱弹棉花"],@[@"玫瑰",@"月季"],@[@"董永",@"许仙"],@[@"若曦",@"晴川"],@[@"谢娜",@"李湘"],
                                    @[@"孟非",@"乐嘉"],@[@"牛奶",@"豆浆"],@[@"保安",@"保镖"],@[@"白菜",@"生菜"], @[@"辣椒",@"芥末"],
                                    @[@"金庸",@"古龙"],@[@"赵敏",@"黄蓉"],@[@"海豚",@"海狮"],@[@"水盆",@"水桶"],@[@"唇膏",@"口红"],@[@"森马",@"以纯"],
                                     @[@"烤肉",@"涮肉"],@[@"气泡",@"水泡"],@[@"纸巾",@"手帕"],@[@"杭州",@"苏州"],@[@"香港",@"台湾"],@[@"首尔",@"东京"],
                                     @[@"橙子",@"橘子"],@[@"葡萄",@"提子"],@[@"蝴蝶",@"蜜蜂"],@[@"小品",@"话剧"],@[@"裸婚",@"闪婚"],
                                     @[@"新年",@"跨年"],@[@"吉他",@"琵琶"],@[@"公交",@"地铁"],@[@"剩女",@"御姐"],@[@"童话",@"神话"],
                                     @[@"作家",@"编剧"],@[@"警察",@"捕快"],@[@"结婚",@"订婚"],@[@"奖牌",@"金牌"]];
    int randNumber = arc4random()%questionArray.count;
    return questionArray[randNumber];
}
@end
