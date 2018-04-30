//
//  CanvasView.h
//  FaceRecognition
//  Created by dang on 16/7/10.
//  Copyright © 2016年 dang. All rights reserved.

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface CanvasView : UIView

#define POINTS_KEY @"POINTS_KEY"
#define RECT_KEY   @"RECT_KEY"
#define RECT_ORI   @"RECT_ORI"
#define ORI_POINTS_KEY @"ORI_POINTS_KEY"
@property (nonatomic , strong) NSArray *arrPersons;
@property (nonatomic , strong) NSArray *arrFixed;
@property (nonatomic) NSInteger canvasCase;
@end
