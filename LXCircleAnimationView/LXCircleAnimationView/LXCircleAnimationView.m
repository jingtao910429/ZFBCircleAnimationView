//
//  LXCircleAnimationView.m
//  LXCircleAnimationView
//
//  Created by Leexin on 15/12/18.
//  Copyright © 2015年 Garden.Lee. All rights reserved.
//

#import "LXCircleAnimationView.h"
#import "UIColor+Extensions.h"
#import "UIView+Extensions.h"

#define kDeviceWidth [UIScreen mainScreen].bounds.size.width
#define kDeviceHeight [UIScreen mainScreen].bounds.size.height
#define degreesToRadians(x) (M_PI*(x)/180.0) //把角度转换成PI的方式
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define kMinScore 350.0
#define kMaxScore 1000.0
// 文字颜色
#define TEXT_COLOR UIColorFromRGB(0x52CDFF)
// 时间文字颜色
#define TIME_TEXT_COLOR UIColorFromRGB(0xD8D8D8)

static const CGFloat kMarkerRadius = 5.f; // 光标直径
static const CGFloat kAnimationTime = 2.f;

@interface LXCircleAnimationView ()

//颜色变化的view
@property(nonatomic,strong)CAGradientLayer *bottomBackGroundViewLayer;
@property (nonatomic, strong) CAShapeLayer *bottomLayer; // 进度条底色
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) CAGradientLayer *gradientLayer; // 渐变进度条
@property (nonatomic, strong) UIImageView *markerImageView; // 光标
@property (nonatomic, strong) UIImageView *bgImageView; // 背景图片

@property (nonatomic, assign) CGFloat circelRadius; //圆直径
@property (nonatomic, assign) CGFloat lineWidth; // 弧线宽度
@property (nonatomic, assign) CGFloat startAngle; // 开始角度
@property (nonatomic, assign) CGFloat endAngle; // 结束角度
@property (nonatomic) CGFloat totalAngle;
@property (nonatomic) CGFloat divisionAngle;

//数字label
@property (nonatomic, strong) UILabel *numLabel;
@property (strong, nonatomic) UILabel *assessmentTimeLabel;
@property (strong, nonatomic) UILabel *infoLabel;

@property (nonatomic, assign) CGSize textSize;
@property (nonatomic, assign) CGSize smallSize;

@end

@implementation LXCircleAnimationView

#pragma mark - Life cycle

- (id) initWithFrame:(CGRect)frame grades: (NSArray *) grades gradePoints: (NSArray *) gradePoints {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        if (!grades || grades.count == 0 || !gradePoints || gradePoints.count == 0) {
            return self;
        }
        
        self.circelRadius = self.frame.size.width - 80.f;
        self.lineWidth = 2.f;
        self.startAngle = -205.f;//200
        self.endAngle = 25.f;//20
        
        _grades = grades;
        _gradePoints = gradePoints;
        
        _totalAngle = _endAngle - _startAngle;
        _divisionAngle = _totalAngle / _grades.count;
        
        UIFont *numFont = [UIFont systemFontOfSize:55.0];
        UIFont *smallFont = [UIFont systemFontOfSize:12.0];
        UIFont *textFont = [UIFont systemFontOfSize:20.0];
        NSString *testNum = @"测";
        CGSize numSize = [testNum sizeWithAttributes:@{ NSFontAttributeName: numFont }];
        _smallSize = [testNum sizeWithAttributes:@{ NSFontAttributeName: smallFont }];
        _textSize = [testNum sizeWithAttributes:@{ NSFontAttributeName: textFont }];
        numSize = CGSizeMake(numSize.width, 40.0);
        
        // 尺寸需根据图片进行调整
        self.bgImageView.frame = CGRectMake(40, 48.5, self.circelRadius, self.circelRadius * 2 / 3);
        [self addSubview:self.bgImageView];
        [self addSubview:self.numLabel];
        [self addSubview:self.infoLabel];
        [self addSubview:self.assessmentTimeLabel];
        
        [self setAssessmentTime:@"2016-6-7"];
        
        [self initSubView];
        
    }
    return self;
}

- (void)initSubView {
    
    // 圆形路径
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.width / 2, self.height / 2)
                                                        radius:(self.circelRadius - self.lineWidth) / 2
                                                    startAngle:degreesToRadians(self.startAngle)
                                                      endAngle:degreesToRadians(self.endAngle)
                                                     clockwise:YES];
    
    // 底色
    self.bottomLayer = [CAShapeLayer layer];
    self.bottomLayer.frame = self.bounds;
    self.bottomLayer.fillColor = [[UIColor clearColor] CGColor];
    //self.bottomLayer.strokeColor = [[UIColor  colorWithRed:206.f / 256.f green:241.f / 256.f blue:227.f alpha:1.f] CGColor];
    self.bottomLayer.strokeColor = [[UIColor  whiteColor] CGColor];
    self.bottomLayer.opacity = 0.5;
    self.bottomLayer.lineCap = kCALineCapRound;
    self.bottomLayer.lineWidth = self.lineWidth;
    self.bottomLayer.path = [path CGPath];
    [self.layer addSublayer:self.bottomLayer];
    
    _bottomBackGroundViewLayer = [[CAGradientLayer alloc] init];
    _bottomBackGroundViewLayer.frame = CGRectMake(0, 0, kDeviceWidth, kDeviceHeight);
    [_bottomBackGroundViewLayer setStartPoint:CGPointMake(0, 0)];
    [_bottomBackGroundViewLayer setEndPoint:CGPointMake(1, 0)];
    _bottomBackGroundViewLayer.position = self.center;
    [self.layer insertSublayer:_bottomBackGroundViewLayer atIndex:0];
    
    self.progressLayer = [CAShapeLayer layer];
    self.progressLayer.frame = self.bounds;
    self.progressLayer.fillColor =  [[UIColor whiteColor] CGColor];
    self.progressLayer.strokeColor  = [[UIColor whiteColor] CGColor];
    self.progressLayer.lineCap = kCALineCapRound;
    self.progressLayer.lineWidth = self.lineWidth;
    self.progressLayer.path = [path CGPath];
    self.progressLayer.strokeEnd = 0;
    [self.bottomLayer setMask:self.progressLayer];
    
    self.gradientLayer = [CAGradientLayer layer];
    self.gradientLayer.frame = self.bounds;
//    [self.gradientLayer setColors:[NSArray arrayWithObjects:
//                                   (id)[[UIColor colorWithHex:0xFF6347] CGColor],
//                                   [(id)[UIColor colorWithHex:0xFFEC8B] CGColor],
//                                   (id)[[UIColor colorWithHex:0xEEEE00] CGColor],
//                                   (id)[[UIColor colorWithHex:0x7FFF00] CGColor],
//                                   nil]];
    
    [self.gradientLayer setColors:[NSArray arrayWithObjects:
                                   (id)[[UIColor whiteColor] CGColor],
                                   nil]];
    [self.gradientLayer setLocations:@[@0.2, @0.5, @0.7, @1]];
    [self.gradientLayer setStartPoint:CGPointMake(0, 0)];
    [self.gradientLayer setEndPoint:CGPointMake(1, 0)];
    [self.gradientLayer setMask:self.progressLayer];
    
    [self.layer addSublayer:self.gradientLayer];
    
    // 240 是用整个弧度的角度之和 |-205| + 25 = 230
    [self createAnimationWithStartAngle:degreesToRadians(self.startAngle)
                               endAngle:degreesToRadians(self.startAngle + 230 * 0)];
}

#pragma mark - Animation

- (void)createAnimationWithStartAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle { // 光标动画
    
    // 设置动画属性
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.calculationMode = kCAAnimationPaced;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.duration = kAnimationTime;
    pathAnimation.repeatCount = 1;
    
    // 设置动画路径
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddArc(path, NULL, self.width / 2, self.height / 2, (self.circelRadius - kMarkerRadius / 2) / 2, startAngle, endAngle, 0);
    pathAnimation.path = path;
    CGPathRelease(path);
    
    self.markerImageView.frame = CGRectMake(-100, self.height, kMarkerRadius, kMarkerRadius);
    self.markerImageView.layer.cornerRadius = self.markerImageView.frame.size.height / 2;
    [self addSubview:self.markerImageView];
    
    [self.markerImageView.layer addAnimation:pathAnimation forKey:@"moveMarker"];
}

- (void)circleAnimation { // 弧形动画
    
    // 复原
    [CATransaction begin];
    [CATransaction setDisableActions:NO];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    [CATransaction setAnimationDuration:0];
    self.progressLayer.strokeEnd = 0;
    [CATransaction commit];
    
    [CATransaction begin];
    [CATransaction setDisableActions:NO];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    [CATransaction setAnimationDuration:kAnimationTime];
    self.progressLayer.strokeEnd = _percent / 100.0;
    [CATransaction commit];
}

-(void)changeColor{
    
    if (self.currentPercent >= self.percent) {
        return;
    }
    
    CGFloat perPercent = 2;
    self.currentPercent += perPercent;
    
    CGFloat colorH;
    CGFloat colorS;
    CGFloat colorB;
    CGFloat offsetH;
    
    if  (self.currentPercent <= 19.0){
        colorH = 0 + 37 / 19.0 * self.currentPercent;
        colorS = 0.70;
    }else if (self.currentPercent <= 20.8){
        colorH = 37 + (100 - 37) / (20.8 - 19.0) * (self.currentPercent - 19.0);
        colorS = 0.65;
    }else if (self.currentPercent <= 30.0){
        colorH = 100 + (120 - 100) / (30.0 - 20.8) * (self.currentPercent - 20.8);
        colorS = 0.60;
    }else if (self.currentPercent <= 40.0){
        colorH = 120;
        colorS = 0.60;
        
    }else if (self.currentPercent <= 70.0){
        colorH = 120 + (360 - 120) / 60.0 * (self.currentPercent - 40.0);
        colorS = 0.60;
        
    }else{
        colorH = 240;
        colorS = 0.90;
    }
    
    if  (self.currentPercent <= 17.0){
        colorB = 0.92;
    }else if (self.currentPercent <= 19.0){
        colorB = 0.85;
    }else if (self.currentPercent <= 30.0){
        colorB = 0.70;
        
    }else if (self.currentPercent <= 40.0){
        colorB = 0.74;
        
    }else if (self.currentPercent <= 70.0){
        colorB = 0.74;
        
    }else{
        colorB = 0.95;
        
    }
    
    if  (self.currentPercent <= 17.0){
        offsetH = 12;
    }else if (self.currentPercent <= 19.5){
        offsetH = 5;
    }else if (self.currentPercent <= 20.5){
        offsetH = -5;
    }else if (self.currentPercent <= 45.0){
        offsetH = -30;
    }else{
        offsetH = -20;
        
    }
    
    
    
    
    UIColor *color1 = [UIColor colorWithHue:colorH / 360.0
                                 saturation:colorS
                                 brightness:colorB
                                      alpha:1.0];
    
    
    UIColor *color2 = [UIColor colorWithHue:(colorH + offsetH) / 360.0
                                 saturation:colorS
                                 brightness:colorB
                                      alpha:1.0];
    
    self.bottomBackGroundViewLayer.colors = @[(id)color1.CGColor,(id)color2.CGColor];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.04 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self changeColor];
    });
}

-(void)addTextLabel{
    
    if (self.currentScore + 0.5 >= self.targetScore) {
        return;
    }
    CGFloat perScore = (self.targetScore - kMinScore) / 50.0;
    self.currentScore += perScore;
    self.numLabel.text = [NSString stringWithFormat:@"%.0f",self.currentScore];
    NSTimeInterval interval = (kAnimationTime * self.percent / 100) / 50;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self addTextLabel];
    });
    
}

- (CGFloat) getAngleWithIntegral: (NSInteger) integral {
    
    CGFloat angle = 0.0;
    if (integral <= [_gradePoints[0] integerValue]) {
        return angle;
    } else if (integral >= [_gradePoints[_gradePoints.count - 1] integerValue]) {
        return _totalAngle;
    }
    NSInteger count = _grades.count;
    NSInteger preLimit;
    NSInteger postLimit;
    for (int i = 0; i < count; i++) {
        preLimit = [((NSNumber *) [LXCircleAnimationView getArrayMemberWithIndex:i fromArray:_gradePoints]) integerValue];
        postLimit = [((NSNumber *) [LXCircleAnimationView getArrayMemberWithIndex:i + 1 fromArray:_gradePoints]) integerValue];
        if (integral > preLimit && integral <= postLimit) {
            angle = ((CGFloat)(integral - preLimit)) / ((CGFloat)(postLimit - preLimit)) * _divisionAngle + _divisionAngle * (i + 1);
            return angle;
        }
    }
    
    return angle;
}

- (NSInteger) getIntegralWithAngle:(CGFloat) angle {
    NSInteger integral = [_gradePoints[0] integerValue];
    if (angle <= 0) {
        return integral;
    } else if (angle >= _totalAngle) {
        return [_gradePoints[_gradePoints.count - 1] integerValue];
    }
    NSInteger count = _grades.count;
    CGFloat preLimit;
    CGFloat postLimit;
    for (int i = 0; i < count; i++) {
        preLimit = _divisionAngle * (CGFloat)i;
        postLimit = _divisionAngle * (CGFloat)(i + 1);
        if (angle > preLimit && angle <= postLimit) {
            NSInteger prePoints= [((NSNumber *) [LXCircleAnimationView getArrayMemberWithIndex:i fromArray:_gradePoints]) integerValue];
            NSInteger postPoints= [((NSNumber *) [LXCircleAnimationView getArrayMemberWithIndex:i + 1 fromArray:_gradePoints]) integerValue];
            integral = (angle - _divisionAngle * (CGFloat)i) / _divisionAngle * (CGFloat)(postPoints - prePoints) + prePoints;
            return integral;
        }
    }
    
    return 100;
}

- (NSString *) getGradeNameWithIntegral: (NSInteger) integral {
    if (integral <= [((NSNumber *) [LXCircleAnimationView getArrayMemberWithIndex:0 fromArray:_gradePoints]) integerValue]) {
        return (NSString *) [LXCircleAnimationView getArrayMemberWithIndex:0 fromArray:_grades];
    } else if (integral >= [_gradePoints[_gradePoints.count - 1] integerValue]) {
        return (NSString *) [LXCircleAnimationView getArrayMemberWithIndex:_grades.count - 1 fromArray:_grades];
    }
    NSInteger count = _grades.count;
    NSInteger preLimit;
    NSInteger postLimit;
    for (int i = 0; i < count; i++) {
        preLimit = [((NSNumber *) [LXCircleAnimationView getArrayMemberWithIndex:i fromArray:_gradePoints]) integerValue];
        postLimit = [((NSNumber *) [LXCircleAnimationView getArrayMemberWithIndex:i + 1 fromArray:_gradePoints]) integerValue];
        if (integral >= preLimit && integral < postLimit) {
            return (NSString *) [LXCircleAnimationView getArrayMemberWithIndex:i fromArray:_grades];
        }
    }
    
    return (NSString *) [LXCircleAnimationView getArrayMemberWithIndex:0 fromArray:_grades];
}

- (NSInteger) getGradePointsWithIndex:(NSInteger) index {
    if (index < 0 || index >= _gradePoints.count) {
        index = 0;
    }
    return [((NSNumber *) [LXCircleAnimationView getArrayMemberWithIndex:index fromArray:_gradePoints]) integerValue];;
}

+ (NSObject *) getArrayMemberWithIndex:(NSInteger)index fromArray: (NSArray *) array {
    if (!array || array.count == 0) {
        return nil;
    }
    if (index < 0) {
        return array[0];
    } else if (index >= array.count) {
        return array[array.count - 1];
    } else {
        return array[index];
    }
}

#pragma mark - Setters / Getters

- (void)setScore:(NSInteger)score {
    [self setScore:score animated:YES];
}

- (void)setScore:(CGFloat)score animated:(BOOL)animated {
    
    _score = score;
    [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(circleAnimation) userInfo:nil repeats:NO];
    
    [self createAnimationWithStartAngle:degreesToRadians(self.startAngle)
                               endAngle:degreesToRadians(self.startAngle + [self getAngleWithIntegral:score])];
    
    self.infoLabel.text = [self getGradeNameWithIntegral:score];
    
    self.percent = score / 10.0;
    
    self.currentPercent = -1;
    [self changeColor];
    
    self.targetScore = _score;
    self.currentScore = kMinScore;
    self.numLabel.text = [NSString stringWithFormat:@"%.0f",kMinScore];
    
    [self addTextLabel];
}

- (void)setBgImage:(UIImage *)bgImage {
    
    _bgImage = bgImage;
    self.bgImageView.image = bgImage;
}

- (void)setText:(NSString *)text {
    
    _text = text;
}

- (void) setAssessmentTime:(NSString *)assessmentTime {
    [_assessmentTimeLabel setText:[NSString stringWithFormat:@"评估时间：%@", assessmentTime]];
}

- (UIImageView *)markerImageView {
    
    if (nil == _markerImageView) {
        _markerImageView = [[UIImageView alloc] init];
        //_markerImageView.backgroundColor = [UIColor colorWithHex:0x20B2AA];
        _markerImageView.backgroundColor = [UIColor whiteColor];
        _markerImageView.alpha = 0.7;
        //_markerImageView.layer.shadowColor = [UIColor colorWithHex:0x20B2AA].CGColor;
        _markerImageView.layer.shadowColor = [UIColor whiteColor].CGColor;
        _markerImageView.layer.shadowOffset = CGSizeMake(0, 0);
        _markerImageView.layer.shadowRadius = 3.f;
        _markerImageView.layer.shadowOpacity = 1;
    }
    return _markerImageView;
}

- (UIImageView *)bgImageView {
    
    if (nil == _bgImageView) {
        _bgImageView = [[UIImageView alloc] init];
        _bgImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _bgImageView;
}

- (UILabel *)numLabel {
    if (!_numLabel) {
        
        _numLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
        _numLabel.text = [NSString stringWithFormat:@"%.0f", kMinScore];
        _numLabel.textColor = [UIColor whiteColor];
        _numLabel.font = [UIFont systemFontOfSize:65];
        _numLabel.textAlignment = NSTextAlignmentCenter;
        _numLabel.center = CGPointMake(self.width / 2, self.height / 2 - 25);
        
    }
    return _numLabel;
}

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _numLabel.frame.origin.y + _numLabel.frame.size.height - 15, self.frame.size.width, _textSize.height)];
        _infoLabel.textAlignment = NSTextAlignmentCenter;
        _infoLabel.textColor = [UIColor whiteColor];
        _infoLabel.font = [UIFont systemFontOfSize:20.0];
    }
    return _infoLabel;
}

- (UILabel *)assessmentTimeLabel {
    if (!_assessmentTimeLabel) {
        _assessmentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _infoLabel.frame.origin.y + _infoLabel.frame.size.height + 5.0f, _infoLabel.frame.size.width, _smallSize.height)];
        _assessmentTimeLabel.textAlignment = NSTextAlignmentCenter;
        _assessmentTimeLabel.textColor = TIME_TEXT_COLOR;
        _assessmentTimeLabel.font = [UIFont systemFontOfSize:12.0];
        
    }
    return _assessmentTimeLabel;
}

@end
