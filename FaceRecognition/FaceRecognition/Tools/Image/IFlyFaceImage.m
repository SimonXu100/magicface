//
//  IFlyFaceImage.m
//  FaceRecognition
//
//  Created by dang on 16/7/10.
//  Copyright © 2016年 dang. All rights reserved.
//

#import "IFlyFaceImage.h"
#import "iflyMSC/IFlyFaceSDK.h"
#import "CalculatorTools.h"


@implementation IFlyFaceImage

@synthesize data = _data;

-(instancetype)init{
    if (self = [super init]) {
        _data = nil;
        self.width = 0;
        self.height = 0;
    }
    return self;
}

-(void)dealloc{
    self.data = nil;
}

@end
