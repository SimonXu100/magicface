//
//  CanvasView.m
//  Created by dang on 16/7/10.
//  FaceRecognition
//  Copyright © 2016年 dang. All rights reserved.
//

#import "CanvasView.h"

@interface CanvasView()
@property (nonatomic, strong) UIImageView *hatImageView;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UIImageView *toothImageView;
@property (nonatomic, strong) UIImageView *maskImageView;
@property (nonatomic, strong) UIImageView *rightEyeMaskImageView;
@end
@implementation CanvasView
{
    CGContextRef context ;
    CGPoint nose;
}

- (void)drawRect:(CGRect)rect
{
    [self drawPointWithPoints:self.arrPersons];
}

- (void)drawPointWithPoints:(NSArray *)arrPersons
{
    if (context) {
        CGContextClearRect(context, self.bounds) ;
    }
    context = UIGraphicsGetCurrentContext();
    
    for (NSDictionary *dicPerson in arrPersons) {
        NSMutableArray *array = [dicPerson objectForKey:POINTS_KEY];
        NSString *nosePoint = [array objectAtIndex:12];
        nose = CGPointFromString(nosePoint);

        if (self.canvasCase == 1) {
            [self.toothImageView removeFromSuperview];
            self.toothImageView = nil;
            [self.hatImageView removeFromSuperview];
            self.hatImageView = nil;
            [self.maskImageView removeFromSuperview];
            self.maskImageView = nil;
            if (array) {
                int down = 0;
               
                for (int i = 0; i < [array count]; i++) {
                    NSString *strPoints = [array objectAtIndex:i];
                    CGPoint p = CGPointFromString(strPoints);
                    if (i == 5 || i == 6 || i == 20 || i ==19 || i == 8) {
                        p = CGPointMake(p.x, p.y + down);
                    }
                    CGContextAddEllipseInRect(context, CGRectMake(p.x - 1 , p.y - 1 , 2 , 2));
                }
            }
        }
        BOOL isOriRect=NO;
        if ([dicPerson objectForKey:RECT_ORI]) {
            isOriRect=[[dicPerson objectForKey:RECT_ORI] boolValue];
        }
        
        if ([dicPerson objectForKey:RECT_KEY]) {
            
            CGRect rect=CGRectFromString([dicPerson objectForKey:RECT_KEY]);
            if (self.canvasCase == 2) {
                [self.maskImageView removeFromSuperview];
                self.maskImageView = nil;
                [self initHatImageViewWithFaceFrame:rect];
            } else if (self.canvasCase == 3) {
                [self.toothImageView removeFromSuperview];
                self.toothImageView = nil;
                [self.hatImageView removeFromSuperview];
                self.hatImageView = nil;
                [self initMaskImageViewWithFaceFrame:rect];
            }             
        }
    }
    if (self.canvasCase== 2) {
        [self addSubview:self.toothImageView];
    }
    [[UIColor greenColor] set];
    CGContextSetLineWidth(context, 2);
    CGContextStrokePath(context);
}

- (void)initHatImageViewWithFaceFrame:(CGRect) rect{
    _hatImageView.frame = CGRectMake(0, 0, rect.size.width*2, rect.size.width*3/2);
    _hatImageView.center = CGPointMake(rect.origin.x + rect.size.width / 2 + 20, rect.origin.y - rect.size.width / 2-60);
    if (!_hatImageView) {
        _hatImageView = [[UIImageView alloc] init];
        NSMutableArray *marray = [[NSMutableArray alloc] init];
        for (int i = 0; i < 35; i++) {
            if (i < 10) {
                [marray addObject:[UIImage imageNamed:[NSString stringWithFormat:@"F_RabbitEar_00%d", i]]];
            } else {
                [marray addObject:[UIImage imageNamed:[NSString stringWithFormat:@"F_RabbitEar_0%d", i]]];
            }
        }
         _hatImageView.animationImages = marray;
        _hatImageView.animationDuration = 3.0;
        // repeat the annimation forever
        _hatImageView.animationRepeatCount = 0;
        [_hatImageView startAnimating];
        [self addSubview:_hatImageView];
        
    }
}

- (void)initMaskImageViewWithFaceFrame:(CGRect) rect {
    _maskImageView.frame = CGRectMake(0, 0, rect.size.width*2+30, rect.size.height*2+30);
    _maskImageView.center= CGPointMake(rect.origin.x + rect.size.width / 2, rect.origin.y + rect.size.width / 2-60);
    if (!_maskImageView) {
        _maskImageView = [[UIImageView alloc] init];
        NSMutableArray *marray = [[NSMutableArray alloc] init];
        for (int i = 0; i < 107; i++) {
            if (i < 10) {
                [marray addObject:[UIImage imageNamed:[NSString stringWithFormat:@"F_helmet_00%d", i]]];
            } else if(i < 100) {
                [marray addObject:[UIImage imageNamed:[NSString stringWithFormat:@"F_helmet_0%d", i]]];
            } else {
                [marray addObject:[UIImage imageNamed:[NSString stringWithFormat:@"F_helmet_%d", i]]];
            }
        }
        _maskImageView.animationImages = marray;
        _maskImageView.animationDuration = 4.5;
        // repeat the annimation forever
        _maskImageView.animationRepeatCount = 0;
        [_maskImageView startAnimating];
        [self addSubview:_maskImageView];
    }
}

- (UIImageView *)toothImageView{
    _toothImageView.frame = CGRectMake(0, 0,255, 150);
    _toothImageView.center =  CGPointMake(nose.x, nose.y+10);
    if (!_toothImageView) {
        _toothImageView = [[UIImageView alloc] init];
        NSMutableArray *marray = [[NSMutableArray alloc] init];
        for (int i = 0; i < 35; i++) {
            if (i < 10) {
                [marray addObject:[UIImage imageNamed:[NSString stringWithFormat:@"F_RabbitTeeth_00%d", i]]];
            } else {
                [marray addObject:[UIImage imageNamed:[NSString stringWithFormat:@"F_RabbitTeeth_0%d", i]]];
            }
        }
        _toothImageView.animationImages = marray;
        _toothImageView.animationDuration = 3.0;
        _toothImageView.animationRepeatCount = 0;
        [_toothImageView startAnimating];
    }
    return _toothImageView;
}
@end
