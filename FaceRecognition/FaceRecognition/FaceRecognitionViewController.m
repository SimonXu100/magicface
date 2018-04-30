//
//  FaceRecognitionViewController.m
//  FaceRecognition
//
//  Created by dang on 16/7/19.
//  Copyright © 2016年 dang. All rights reserved.
//

#import "FaceRecognitionViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>
#import "iflyMSC/IFlyFaceSDK.h"
#import "CaptureManager.h"
#import "CanvasView.h"
#import "CalculatorTools.h"
#import "IFlyFaceImage.h"
#import "IFlyFaceResultKeys.h"
@interface FaceRecognitionViewController ()<CaptureManagerDelegate,CaptureNowImageDelegate>
{
    BOOL isCrossBorder;//判断是否越界
}
@property (nonatomic, retain ) UIView                     *previewView;
@property (nonatomic, retain ) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, retain ) CaptureManager             *captureManager;
@property (nonatomic, retain ) IFlyFaceDetector           *faceDetector;
@property (nonatomic, strong ) CanvasView                 *viewCanvas;
@property (nonatomic, strong) UIToolbar *toolBar;
@property (nonatomic, strong) UIImageView *bgImageView;

@end

@implementation FaceRecognitionViewController
@synthesize captureManager;

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    //创建界面
    [self makeUI];
    //创建摄像页面
    [self makeCamera];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //停止摄像
    [self.previewLayer.session stopRunning];
    [self.captureManager removeObserver];
}

#pragma mark - 创建UI界面
-(void)makeUI
{
    self.previewView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 44-64)];
    [self.view addSubview:self.previewView];
    [self.view addSubview:self.toolBar];
}

#pragma mark - 创建相机
-(void)makeCamera
{
    self.title = @"人脸识别";
    
    self.view.backgroundColor=[UIColor blackColor];
    self.previewView.backgroundColor=[UIColor clearColor];
    
    //设置初始化打开识别
    self.faceDetector = [IFlyFaceDetector sharedInstance];
    [self.faceDetector setParameter:@"1" forKey:@"detect"];
    [self.faceDetector setParameter:@"1" forKey:@"align"];
    
    //初始化 CaptureSessionManager
    self.captureManager = [[CaptureManager alloc] init];
    self.captureManager.capturedelegate = self;
    
    self.previewLayer = self.captureManager.previewLayer;
    
    self.captureManager.previewLayer.frame= self.previewView.frame;
    self.captureManager.previewLayer.position=self.previewView.center;
    self.captureManager.previewLayer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    [self.previewView.layer addSublayer:self.captureManager.previewLayer];
    
    self.viewCanvas = [[CanvasView alloc] initWithFrame:self.captureManager.previewLayer.frame] ;
    self.viewCanvas.canvasCase = 1;
    [self.previewView addSubview:self.viewCanvas] ;
    self.viewCanvas.center=self.captureManager.previewLayer.position;
    self.viewCanvas.backgroundColor = [UIColor clearColor];
    NSString *str = [NSString stringWithFormat:@"{{%f, %f}, {220, 240}}",(ScreenWidth-220)/2,(ScreenWidth-240)/2+15];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:str forKey:@"RECT_KEY"];
    [dic setObject:@"1" forKey:@"RECT_ORI"];
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    [arr addObject:dic];
    self.viewCanvas.arrFixed = arr;
    self.viewCanvas.hidden = NO;
    
    //开始摄像
    [self.captureManager setup];
    [self.captureManager addObserver];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    [self.captureManager observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

#pragma mark - 开启识别
- (void) showFaceLandmarksAndFaceRectWithPersonsArray:(NSMutableArray *)arrPersons
{
    if (self.viewCanvas.hidden) {
        self.viewCanvas.hidden = NO;
    }
    self.viewCanvas.arrPersons = arrPersons;
    [self.viewCanvas setNeedsDisplay] ;
}

#pragma mark - 关闭识别
- (void) hideFace
{
    if (!self.viewCanvas.hidden) {
        self.viewCanvas.hidden = YES ;
    }
}

#pragma mark - 脸部框识别
-(NSString*)praseDetect:(NSDictionary* )positionDic OrignImage:(IFlyFaceImage*)faceImg
{
    if(!positionDic){
        return nil;
    }
    
    // scale coordinates so they fit in the preview box, which may be scaled
    CGFloat widthScaleBy = self.previewLayer.frame.size.width / faceImg.height;
    CGFloat heightScaleBy = self.previewLayer.frame.size.height / faceImg.width;
    
    CGFloat bottom =[[positionDic objectForKey:KCIFlyFaceResultBottom] floatValue];
    CGFloat top=[[positionDic objectForKey:KCIFlyFaceResultTop] floatValue];
    CGFloat left=[[positionDic objectForKey:KCIFlyFaceResultLeft] floatValue];
    CGFloat right=[[positionDic objectForKey:KCIFlyFaceResultRight] floatValue];
    
    float cx = (left+right)/2;
    float cy = (top + bottom)/2;
    float w = right - left;
    float h = bottom - top;
    
    float ncx = cy ;
    float ncy = cx ;
    
    CGRect rectFace = CGRectMake(ncx-w/2 ,ncy-w/2 , w, h);
    //判断位置
    BOOL isNotLocation = [self identifyYourFaceLeft:left right:right top:top bottom:bottom];
    
    if (isNotLocation==YES) {
        return nil;
    }
    
    NSLog(@"left=%f right=%f top=%f bottom=%f",left,right,top,bottom);
    
    isCrossBorder = NO;
    
    rectFace=rScale(rectFace, widthScaleBy, heightScaleBy);
    
    return NSStringFromCGRect(rectFace);
}

#pragma mark - 脸部部位识别
-(NSMutableArray*)praseAlign:(NSDictionary* )landmarkDic OrignImage:(IFlyFaceImage*)faceImg
{
    if(!landmarkDic){
        return nil;
    }
    
    // scale coordinates so they fit in the preview box, which may be scaled
    CGFloat widthScaleBy = self.previewLayer.frame.size.width / faceImg.height;
    CGFloat heightScaleBy = self.previewLayer.frame.size.height / faceImg.width;
    
    NSMutableArray *arrStrPoints = [NSMutableArray array];
    NSEnumerator* keys=[landmarkDic keyEnumerator];
    for(id key in keys){
        id attr=[landmarkDic objectForKey:key];
        if(attr && [attr isKindOfClass:[NSDictionary class]]){
            
            id attr=[landmarkDic objectForKey:key];
            CGFloat x=[[attr objectForKey:KCIFlyFaceResultPointX] floatValue];
            CGFloat y=[[attr objectForKey:KCIFlyFaceResultPointY] floatValue];
            
            CGPoint p = CGPointMake(y,x);
            
            //判断是否越界
            p = pScale(p, widthScaleBy, heightScaleBy);
            [arrStrPoints addObject:NSStringFromCGPoint(p)];
        }
    }
    return arrStrPoints;
}

#pragma mark - 脸部识别
-(void)praseTrackResult:(NSString*)result OrignImage:(IFlyFaceImage*)faceImg
{
    if(!result){
        return;
    }
    
    @try {
        NSError* error;
        NSData* resultData=[result dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* faceDic=[NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:&error];
        resultData=nil;
        if(!faceDic){
            return;
        }
        
        NSString* faceRet=[faceDic objectForKey:KCIFlyFaceResultRet];
        NSArray* faceArray=[faceDic objectForKey:KCIFlyFaceResultFace];
        faceDic=nil;
        
        int ret=0;
        if(faceRet){
            ret=[faceRet intValue];
        }
        //没有检测到人脸或发生错误
        if (ret || !faceArray || [faceArray count]<1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideFace];
            }) ;
            return;
        }
        
        //检测到人脸
        NSMutableArray *arrPersons = [NSMutableArray array] ;
        
        for(id faceInArr in faceArray){
            
            if(faceInArr && [faceInArr isKindOfClass:[NSDictionary class]]){
                
                NSDictionary* positionDic = [faceInArr objectForKey:KCIFlyFaceResultPosition];
                NSString* rectString = [self praseDetect:positionDic OrignImage: faceImg];
                
                positionDic=nil;
                
                NSDictionary* landmarkDic = [faceInArr objectForKey:KCIFlyFaceResultLandmark];
                NSMutableArray* strPoints = [self praseAlign:landmarkDic OrignImage:faceImg];
                
                NSMutableDictionary *dicPerson = [NSMutableDictionary dictionary] ;
                if(rectString){
                    [dicPerson setObject:rectString forKey:RECT_KEY];
                }
                if(strPoints){
                    [dicPerson setObject:strPoints forKey:POINTS_KEY];
                }
                
                strPoints=nil;
                
                [dicPerson setObject:@"0" forKey:RECT_ORI];
                [arrPersons addObject:dicPerson] ;
                
                dicPerson=nil;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showFaceLandmarksAndFaceRectWithPersonsArray:arrPersons];
                });
            }
        }
        faceArray=nil;
    }
    @catch (NSException *exception) {
        NSLog(@"prase exception:%@",exception.name);
    }
    @finally {
    }
}

#pragma mark - CaptureManagerDelegate
-(void)onOutputFaceImage:(IFlyFaceImage*)faceImg
{
    NSString* strResult=[self.faceDetector trackFrame:faceImg.data withWidth:faceImg.width height:faceImg.height direction:(int)faceImg.direction];
    NSLog(@"result:%@",strResult);
    
    //清理图片数据
    faceImg.data=nil;
    
    NSMethodSignature *sig = [self methodSignatureForSelector:@selector(praseTrackResult:OrignImage:)];
    if (!sig) return;
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation setTarget:self];
    [invocation setSelector:@selector(praseTrackResult:OrignImage:)];
    [invocation setArgument:&strResult atIndex:2];
    [invocation setArgument:&faceImg atIndex:3];
    [invocation retainArguments];
    [invocation performSelectorOnMainThread:@selector(invoke) withObject:nil  waitUntilDone:NO];
    faceImg=nil;
}

#pragma mark --- 判断位置
-(BOOL)identifyYourFaceLeft:(CGFloat)left right:(CGFloat)right top:(CGFloat)top bottom:(CGFloat)bottom
{
    return NO;
}

#pragma mark - getter and setter
- (UIToolbar *)toolBar {
    if (!_toolBar) {
        _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, ScreenHeight-44-44-20, ScreenWidth, 44)];
        _toolBar.tintColor=[UIColor blackColor]; //设置颜色
        
        UIBarButtonItem * item0 = [[UIBarButtonItem alloc] initWithTitle:@"特征点" style:UIBarButtonItemStyleDone target:self action:@selector(clickToolBar:)];
        item0.tintColor = [UIColor colorWithRed:(51)/255.f green:(171)/255.f blue:(160)/255.f alpha:1.f];
        item0.tag = 101;
        UIBarButtonItem * item1 = [[UIBarButtonItem alloc] initWithTitle:@"小兔子" style:UIBarButtonItemStyleDone target:self action:@selector(clickToolBar:)];
        item1.tintColor = [UIColor colorWithRed:(51)/255.f green:(171)/255.f blue:(160)/255.f alpha:1.f];
        item1.tag = 102;
        UIBarButtonItem * item2 = [[UIBarButtonItem alloc] initWithTitle:@"变形金钢" style:UIBarButtonItemStyleDone target:self action:@selector(clickToolBar:)];
        item2.tag = 103;
        item2.tintColor = [UIColor colorWithRed:(51)/255.f green:(171)/255.f blue:(160)/255.f alpha:1.f];
        UIBarButtonItem * spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        
        [_toolBar setItems:[NSArray arrayWithObjects:item0, spaceItem, item1, spaceItem, item2, nil] animated:YES];
    }
    return _toolBar;
}

#pragma mark - event response
- (void)clickToolBar:(UIBarButtonItem *) barButtonItem{
    switch (barButtonItem.tag) {
        case 101:
            self.viewCanvas.canvasCase = 1;
            [self.bgImageView removeFromSuperview];
            break;
        case 102:
            self.viewCanvas.canvasCase = 2;
            [self.toolBar addSubview:self.bgImageView];
            break;
        case 103:
            self.viewCanvas.canvasCase = 3;
            [self.bgImageView removeFromSuperview];
            break;
        default:
            break;
    }
    [self.viewCanvas setNeedsDisplay] ;
}

- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] init];
        _bgImageView.frame = CGRectMake(0, -500, ScreenWidth, 500);
        NSMutableArray *marray = [[NSMutableArray alloc] init];
        for (int i = 0; i < 35; i++) {
            if (i < 10) {
                [marray addObject:[UIImage imageNamed:[NSString stringWithFormat:@"B_Backgroud_00%d", i]]];
            } else {
                [marray addObject:[UIImage imageNamed:[NSString stringWithFormat:@"B_Backgroud_0%d", i]]];
            }
        }
        _bgImageView.animationImages = marray;
        _bgImageView.animationDuration = 3.0;
        _bgImageView.animationRepeatCount = 0;
        [_bgImageView startAnimating];
    }
    return _bgImageView;
}
@end
