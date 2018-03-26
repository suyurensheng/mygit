//
//  QRVC.h
//  DLZDemo
//
//  Created by 董力祯 on 2018/1/30.
//  Copyright © 2018年 董力祯. All rights reserved.
//

#import "BaseVC.h"

@interface QRVC : BaseVC
@property (strong,nonatomic)AVCaptureDevice * device;
@property (strong,nonatomic)AVCaptureDeviceInput * input;
@property (strong,nonatomic)AVCaptureMetadataOutput * output;
@property (strong,nonatomic)AVCaptureSession * session;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer * preview;
@end
