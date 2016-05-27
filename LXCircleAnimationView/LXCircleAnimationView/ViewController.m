//
//  ViewController.m
//  LXCircleAnimationView
//
//  Created by wwt on 16/5/27.
//  Copyright © 2016年 ___RongYu100___. All rights reserved.
//

#import "ViewController.h"
#import "LXCircleAnimationView.h"
#import "UIView+Extensions.h"

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

@interface ViewController ()

@property (nonatomic, strong) LXCircleAnimationView *circleProgressView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSArray* grades = @[@"信用很差",@"信用较差",@"信用欠佳",@"信用一般",@"信用较好",@"信用优良",@"信用极好"];
    NSArray* gradePoints = @[@(329),@(359),@(429),@(499),@(599),@(699),@(1000)];
    
    self.circleProgressView = [[LXCircleAnimationView alloc] initWithFrame:CGRectMake(0.f, 10.f, SCREEN_WIDTH, SCREEN_WIDTH) grades:grades gradePoints:gradePoints];
    self.circleProgressView.bgImage = [UIImage imageNamed:@"backgroundImage"];
    self.circleProgressView.percent = 0.f;
    self.circleProgressView.score = 600.f;
    [self.view addSubview:self.circleProgressView];
    
    UIButton *stareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    stareButton.frame = CGRectMake(10.f, self.circleProgressView.bottom + 50.f, SCREEN_WIDTH - 20.f, 38.f);
    [stareButton addTarget:self action:@selector(onStareButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [stareButton setTitle:@"Stare Animation" forState:UIControlStateNormal];
    [stareButton setBackgroundColor:[UIColor lightGrayColor]];
    stareButton.layer.masksToBounds = YES;
    stareButton.layer.cornerRadius = 4.f;
    [self.view addSubview:stareButton];
}

- (void)onStareButtonClick {
    
    //self.circleProgressView.score = 1000.f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
