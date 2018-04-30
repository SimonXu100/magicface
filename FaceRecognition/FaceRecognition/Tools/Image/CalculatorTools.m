//
//  CalculatorTools.m
//  FaceRecognition
//
//  Created by dang on 16/7/15.
//  Copyright © 2016年 dang. All rights reserved.
//

#import "CalculatorTools.h"
CGPoint pScale(CGPoint p ,CGFloat wScale, CGFloat hScale){
    p.x *= wScale;
    p.y *= hScale;
    return p;
}

CGRect rScale(CGRect r ,CGFloat wScale, CGFloat hScale){
    r.size.width *= wScale;
    r.size.height *= hScale;
    r.origin.x *= wScale;
    r.origin.y *= hScale;
    return r;
}

int imageDirection(UIImage* img){
    if(!img){
        return -1;
    }
    int dir=1;
    switch (img.imageOrientation) {
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:{
            dir=2;
        }
            break;
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:{
            dir=1;
        }
            break;
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:{
            dir=3;
        }
            break;
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:{
            dir=0;
        }
            break;
    }
    return dir;
}

