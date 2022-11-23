//
//  HTCaptureSessionManager.h
//
//  Created by N17 on 2021/2/23.
//  Copyright © 2021 Tillusory Tech. All rights reserved.
//

#import <Masonry/Masonry.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol HTCaptureSessionManagerDelegate <NSObject>

- (void)captureSampleBuffer:(CMSampleBufferRef)sampleBuffer Rotation:(NSInteger)rotation Mirror:(BOOL)isMirror;

@end

@interface HTCaptureSessionManager : NSObject
/**
 *   初始化单例
 */
+ (HTCaptureSessionManager *)shareManager;
/**
 * 释放资源
 */
- (void)destroy;

- (void)startAVCaptureDelegate:(id<HTCaptureSessionManagerDelegate>)delegate;

- (void)didClickSwitchCameraButton;

@property(nonatomic, weak) id <HTCaptureSessionManagerDelegate> delegate;

@property (nonatomic, strong) AVCaptureDevice *cameraPosition;
@property (nonatomic, strong) AVCaptureSession *session;

@end
