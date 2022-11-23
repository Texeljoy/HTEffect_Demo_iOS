//
//  CameraViewController.m
//  HTEffectDemoiOS
//
//  Created by N17 on 2022/5/6.
//  Copyright © 2022 Tillusory Tech. All rights reserved.
//

#import "CameraViewController.h"
#import "HTCaptureSessionManager.h"
#import "AppDelegate.h"

#import <HTEffect/HTEffect.h>
#import "HTUIManager.h"
#import <HTEffect/HTEffectView.h>

@interface CameraViewController () <HTUIManagerDelegate,HTEffectDelegate,HTCaptureSessionManagerDelegate>

@property (nonatomic, strong) HTEffectView *htLiveView;

@property (nonatomic, assign) BOOL isRenderInit;

@property (nonatomic, strong) CIImage *outputImage;
@property (nonatomic, assign) CVPixelBufferRef outputImagePixelBuffer;

@end

@implementation CameraViewController

- (HTEffectView *)htLiveView{
    if (!_htLiveView) {
        _htLiveView = [[HTEffectView alloc] init];
        _htLiveView.contentMode = HTEffectViewContentModeScaleAspectFill;
        _htLiveView.orientation = HTEffectViewOrientationLandscapeLeft;
        _htLiveView.userInteractionEnabled = YES;
    }
    return _htLiveView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.htLiveView];
    [self.htLiveView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
        make.width.height.equalTo(self.view);
    }];
    
    if ([isSDKInit  isEqual: @"初始化失败"]) {
        [[HTEffect shareInstance] initHTEffect:@"Your AppId" withDelegate:self];
    }
    [[HTCaptureSessionManager shareManager] startAVCaptureDelegate:self];
    [[HTUIManager shareManager] loadToWindowDelegate:self];
    [self.view addSubview:[HTUIManager shareManager].defaultButton];
}

//切换相机
- (void)SwitchCamera:(UIButton *)button{
    [[HTCaptureSessionManager shareManager] didClickSwitchCameraButton];
    self.isRenderInit = false;
}

// MARK: --TiUIManagerDelegate Delegate--
- (void)didClickCameraCaptureButton{
    //拍照
    [self takePhoto];
}

- (void)didClickSwitchCameraButton{
    //切换摄像头
    [[HTCaptureSessionManager shareManager] didClickSwitchCameraButton];
    self.isRenderInit = false;
}

// MARK: --HTCaptureSessionManager Delegate--
- (void)captureSampleBuffer:(CMSampleBufferRef)sampleBuffer Rotation:(NSInteger)rotation Mirror:(BOOL)isMirror{
    
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    if (pixelBuffer == NULL) {
        return;
    }
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    unsigned char *baseAddress = (unsigned char *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    
    // 视频帧格式
    HTFormatEnum format;
    switch (CVPixelBufferGetPixelFormatType(pixelBuffer)) {
        case kCVPixelFormatType_32BGRA:
            format = HTFormatBGRA;
            break;
        case kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange:
        case kCVPixelFormatType_420YpCbCr8BiPlanarFullRange:
            format = HTFormatNV12;
            break;
        default:
            NSLog(@"错误的视频帧格式！");
            format = HTFormatBGRA;
            break;
    }
    
    int imageWidth, imageHeight;
    if (format == HTFormatBGRA) {
        imageWidth = (int)CVPixelBufferGetBytesPerRow(pixelBuffer) / 4;
        imageHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
    } else {
        imageWidth = (int)CVPixelBufferGetWidthOfPlane(pixelBuffer , 0);
        imageHeight = (int)CVPixelBufferGetHeightOfPlane(pixelBuffer , 0);
    }
    
    if (!_isRenderInit) {
        [[HTEffect shareInstance] releaseBufferRenderer];
        _isRenderInit = [[HTEffect shareInstance] initBufferRenderer:format width:imageWidth height:imageHeight rotation:HTRotationClockwise90 isMirror:isMirror maxFaces:5];
    }
    
    [[HTEffect shareInstance] processBuffer:baseAddress];

    [self.htLiveView displayPixelBuffer:pixelBuffer isMirror:isMirror];
    
    self.outputImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    self.outputImagePixelBuffer = pixelBuffer;
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
}

- (void)takePhoto {
    if (self.outputImage) {
        /* 录制 前置摄像头修正图片朝向*/
        UIImage *processedImage = [self image:[self imageFromCVPixelBufferRef:_outputImagePixelBuffer] rotation:HTRotationClockwise270];
        UIImageWriteToSavedPhotosAlbum(processedImage, self, @selector(image:finishedSavingWithError:contextInfo:), nil);
    }else{
        UIAlertController *alertView = [[UIAlertController alloc] init];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil];
        [alertView addAction:cancelAction];
        [alertView setTitle:@"拍照失败,请重试"];
        [self presentViewController:alertView animated:NO completion:nil];
    }
}

- (void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    UIAlertController *alertView = [[UIAlertController alloc] init];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil];
    [alertView addAction:cancelAction];
    [alertView setTitle:@"拍照成功"];
    
    if (error) {
        [alertView setMessage:[NSString stringWithFormat:@"拍照失败，原因：%@", error]];
        NSLog(@"save failed.");
    } else {
        [alertView setMessage:[NSString stringWithFormat:@"TiFancy已为您保存到相册！"]];
        NSLog(@"save success.");
    }
    [self presentViewController:alertView animated:NO completion:nil];
    
}

#pragma mark -- CVPixelBufferRef-BGRA转UIImage
- (UIImage *)imageFromCVPixelBufferRef:(CVPixelBufferRef)pixelBuffer{
    UIImage *image;
    @autoreleasepool {
        CGImageRef cgImage = NULL;
        CVPixelBufferRef pb = (CVPixelBufferRef)pixelBuffer;
        CVPixelBufferLockBaseAddress(pb, kCVPixelBufferLock_ReadOnly);
        OSStatus res = CreateCGImageFromCVPixelBuffer(pb,&cgImage);
        if (res == noErr){
            image= [UIImage imageWithCGImage:cgImage scale:1.0 orientation:UIImageOrientationUp];
        }
        CVPixelBufferUnlockBaseAddress(pb, kCVPixelBufferLock_ReadOnly);
        CGImageRelease(cgImage);
    }
    return image;
}

static OSStatus CreateCGImageFromCVPixelBuffer(CVPixelBufferRef pixelBuffer, CGImageRef *imageOut)
{
    OSStatus err = noErr;
    OSType sourcePixelFormat;
    size_t width, height, sourceRowBytes;
    void *sourceBaseAddr = NULL;
    CGBitmapInfo bitmapInfo;
    CGColorSpaceRef colorspace = NULL;
    CGDataProviderRef provider = NULL;
    CGImageRef image = NULL;
    sourcePixelFormat = CVPixelBufferGetPixelFormatType( pixelBuffer );
    if ( kCVPixelFormatType_32ARGB == sourcePixelFormat )
        bitmapInfo = kCGBitmapByteOrder32Big | kCGImageAlphaNoneSkipFirst;
    else if ( kCVPixelFormatType_32BGRA == sourcePixelFormat )
        bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst;
    else
        return -95014; // only uncompressed pixel formats
    sourceRowBytes = CVPixelBufferGetBytesPerRow( pixelBuffer );
    width = CVPixelBufferGetWidth( pixelBuffer );
    height = CVPixelBufferGetHeight( pixelBuffer );
    CVPixelBufferLockBaseAddress( pixelBuffer, 0 );
    sourceBaseAddr = CVPixelBufferGetBaseAddress( pixelBuffer );
    colorspace = CGColorSpaceCreateDeviceRGB();
    CVPixelBufferRetain( pixelBuffer );
    provider = CGDataProviderCreateWithData( (void *)pixelBuffer, sourceBaseAddr, sourceRowBytes * height, ReleaseCVPixelBuffer);
    image = CGImageCreate(width, height, 8, 32, sourceRowBytes, colorspace, bitmapInfo, provider, NULL, true, kCGRenderingIntentDefault);
    if ( err && image ) {
        CGImageRelease( image );
        image = NULL;
    }
    if ( provider ) CGDataProviderRelease( provider );
    if ( colorspace ) CGColorSpaceRelease( colorspace );
    *imageOut = image;
    return err;
}

static void ReleaseCVPixelBuffer(void *pixel, const void *data, size_t size)
{
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)pixel;
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    CVPixelBufferRelease(pixelBuffer);
}

#pragma mark -- 旋转UIImage为正向
- (UIImage *)image:(UIImage *)image rotation:(HTRotationEnum)orientation
{
    long double rotate = 0.0;
    CGRect rect;
    float translateX = 0;
    float translateY = 0;
    float scaleX = 1.0;
    float scaleY = 1.0;
    
    switch (orientation) {
        case HTRotationClockwise90:
            rotate = M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = 0;
            translateY = -rect.size.width;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case HTRotationClockwise270:
            rotate = 3 * M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = -rect.size.height;
            translateY = 0;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case HTRotationClockwise180:
            rotate = M_PI;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = -rect.size.width;
            translateY = -rect.size.height;
            break;
        default:
            rotate = 0.0;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = 0;
            translateY = 0;
            break;
    }
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //做CTM变换
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, rotate);
    CGContextTranslateCTM(context, translateX, translateY);
    
    CGContextScaleCTM(context, scaleX, scaleY);
    //绘制图片
    CGContextDrawImage(context, CGRectMake(0, 0, rect.size.width, rect.size.height), image.CGImage);
    
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    
    if ([[HTCaptureSessionManager shareManager].cameraPosition position] == AVCaptureDevicePositionFront) {
        //前置摄像头要转换镜像图片
        newPic = [self convertMirrorImage:newPic];
    }
    
    return newPic;
}

- (UIImage *)convertMirrorImage:(UIImage *)image {
    //Quartz重绘图片
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 2);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextClipToRect(currentContext, rect);
    CGContextRotateCTM(currentContext, (CGFloat) M_PI);
    CGContextTranslateCTM(currentContext, -rect.size.width, -rect.size.height);
    CGContextDrawImage(currentContext, rect, image.CGImage);
    
    //翻转图片
    UIImage *drawImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImage *flipImage = [[UIImage alloc] initWithCGImage:drawImage.CGImage];
    
    return flipImage;
}

- (void)dealloc {
    //todo --- tillusory start ---
    [[HTEffect shareInstance] releaseBufferRenderer];
    [[HTUIManager shareManager] destroy];
    //todo --- tillusory end ---
}

- (void)onInitFailure {
    isSDKInit = @"初始化失败";
}

- (void)onInitSuccess {
    isSDKInit = @"初始化成功";
}

@end
