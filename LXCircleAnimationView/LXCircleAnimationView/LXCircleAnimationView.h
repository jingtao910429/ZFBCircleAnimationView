//
//  ViewController.m
//  LXCircleAnimationView
//
//  Created by wwt on 16/5/27.
//  Copyright © 2016年 ___RongYu100___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LXCircleAnimationView : UIView

@property (nonatomic, assign)CGFloat currentPercent; //当前percent
@property (nonatomic, assign) CGFloat percent; // 百分比 0 - 100
@property (nonatomic, assign)  NSInteger score; //分数
@property (nonatomic, strong) UIImage *bgImage; // 背景图片
@property (nonatomic, strong) NSString *text; // 文字

//加数字用的当前分数，和目标分数
@property (nonatomic, assign) CGFloat targetScore;
@property (nonatomic, assign) CGFloat currentScore;
@property (strong, nonatomic) NSArray *grades;
@property (strong, nonatomic) NSArray *gradePoints;

- (id) initWithFrame:(CGRect)frame grades: (NSArray *) grades gradePoints: (NSArray *) gradePoints;
+ (NSObject *) getArrayMemberWithIndex:(NSInteger) index fromArray: (NSArray *) array;

@end
