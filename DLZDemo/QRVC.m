//
//  QRVC.m
//  DLZDemo
//
//  Created by 董力祯 on 2018/1/30.
//  Copyright © 2018年 董力祯. All rights reserved.
//

#import "QRVC.h"
#import <ZBarSDK.h>

@protocol ScanCodeViewDelegate <NSObject>

-(void)finishRead:(NSString *)barCode;

@end

@interface QRVC ()<AVCaptureMetadataOutputObjectsDelegate,ZBarReaderDelegate,ZBarReaderViewDelegate>{
    
    UIImageView *lineView;
}

@property (nonatomic,strong)ZBarReaderView *readerView;

@property(assign,nonatomic) id<ScanCodeViewDelegate> delegate;
@end

@implementation QRVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
 //   [self began];
 //   [self zbarControllerBegan];
    [self zbarViewBegan];
}

-(void)began{
    // Device
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // Session
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    
    //连接输入和输出
    if ([_session canAddInput:self.input]){
        [_session addInput:self.input];
    }
    
    if ([_session canAddOutput:self.output]){
        [_session addOutput:self.output];
    }
    
    //设置条码类型
    _output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];
    
    //添加扫描画面
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:_session];
    _preview.videoGravity =AVLayerVideoGravityResizeAspectFill;
    _preview.frame =self.view.layer.bounds;
    [self.view.layer insertSublayer:_preview atIndex:0];
    
    [_session startRunning];
}
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    if ([metadataObjects count] >0){
        //停止扫描
        [_session stopRunning];
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        NSString *stringValue = metadataObject.stringValue;
        NSLog(@"result=%@",stringValue);
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)zbarControllerBegan{
    
    ZBarReaderViewController *zbar=[[ZBarReaderViewController alloc]init];
    zbar.readerDelegate=self;
    zbar.supportedOrientationsMask=ZBarOrientationMaskAll;
    
    ZBarImageScanner *scanner = zbar.scanner;
    
    [scanner setSymbology:ZBAR_I25 config:ZBAR_CFG_ENABLE to:0];
    zbar.showsZBarControls = YES;
    
    [self presentViewController:zbar animated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    // ADD: get the decode results
    id<NSFastEnumeration> results =
    [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        // EXAMPLE: just grab the first barcode
        break;
    
    NSLog(@"result=%@",symbol.data);
    // EXAMPLE: do something useful with the barcode data
//
//    // EXAMPLE: do something useful with the barcode image
//    self.imageView.image =
//    [info objectForKey: UIImagePickerControllerOriginalImage];
    
    // ADD: dismiss the controller (NB dismiss from the *reader*!)
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    
    return (YES);
}

-(void)zbarViewBegan{
    
    
    _readerView=[[ZBarReaderView alloc]init];
    _readerView.readerDelegate = self;
    //关闭闪光灯
    _readerView.torchMode = 0;
    //取消手动对焦
    _readerView.allowsPinchZoom=NO;
    
    //扫描区域，这里可以自己调整
    CGRect scanMaskRect = CGRectMake(100, CGRectGetMidY(_readerView.frame) - 126, 250, 250);
    
    //处理模拟器
    if (TARGET_IPHONE_SIMULATOR) {
        ZBarCameraSimulator *cameraSimulator
        = [[ZBarCameraSimulator alloc]initWithViewController:self];
        cameraSimulator.readerView = _readerView;
    }
    [self.view addSubview:_readerView];
    //扫描区域计算
    
    CGRect scanCrop=[self getScanCrop:scanMaskRect readerViewBounds:self.readerView.bounds];
    _readerView.scanCrop = scanCrop;
    
    //这里添加了一个类似微信的扫描框，可以根据自己需要添加
    UIImageView *imageView=[[UIImageView alloc] init];
    if([UIScreen mainScreen].bounds.size.height==568){
        imageView.image=[UIImage imageNamed:@"scan_bg_568h"];
        imageView.frame=CGRectMake(0, 0, 320, 568);
        
    }else{
        imageView.image=[UIImage imageNamed:@"scan_bg"];
        imageView.frame=CGRectMake(0, 0, 320, 480);
        
    }
    
    [self.view addSubview:imageView];
    
    //这里添加了类似微信的扫描线，并开始上线滑动动画
    lineView=[[UIImageView alloc] initWithFrame:CGRectMake(51, 200, 219, 3)];
    lineView.image=[UIImage imageNamed:@"scan_line"];
    [self.view addSubview:lineView];
    
    [self loadAnimationStart];
    
    [_readerView start];
}
-(void)loadAnimationStart{
    
    if([UIScreen mainScreen].bounds.size.height==568){
        
        [UIView animateWithDuration:2.0 animations:^{
            lineView.frame=CGRectMake(lineView.frame.origin.x, 390,lineView.frame.size.width,lineView.frame.size.height);
        } completion:^(BOOL finished) {
            
            [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(secStart) userInfo:nil repeats:NO];
        }];
    }else{
        
        [UIView animateWithDuration:2.0 animations:^{
            lineView.frame=CGRectMake(lineView.frame.origin.x, 345,lineView.frame.size.width,lineView.frame.size.height);
        } completion:^(BOOL finished) {
            
            [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(secStart) userInfo:nil repeats:NO];
        }];
        
    }
    
}

-(void)secStart{
    
    if([UIScreen mainScreen].bounds.size.height==568){
        
        lineView.frame=CGRectMake(lineView.frame.origin.x, 175,lineView.frame.size.width,lineView.frame.size.height);
        [self loadAnimationStart];
        
    }else{
        
        lineView.frame=CGRectMake(lineView.frame.origin.x, 130,lineView.frame.size.width,lineView.frame.size.height);
        [self loadAnimationStart];
        
        
    }
    
}


-(void)cancelScan{
    
    [_readerView stop];
//    [self dismissViewControllerAnimated:YES completion:nil];
    
}



- (CGRect)getScanCrop:(CGRect)rect readerViewBounds:(CGRect)rvBounds{
    CGFloat x,y,width,height;
    x = rect.origin.y / rvBounds.size.height;
    y = 1 - (rect.origin.x + rect.size.width) / rvBounds.size.width;
    width = (rect.origin.y + rect.size.height) / rvBounds.size.height;
    height = 1 - rect.origin.x / rvBounds.size.width;
    return CGRectMake(x, y, width, height);
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:YES];
//    [_readerView start];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self cancelScan];
}

- (void)readerView:(ZBarReaderView *)readerView didReadSymbols:(ZBarSymbolSet *)symbols fromImage:(UIImage *)image
{
    NSString *str;
    
    for (ZBarSymbol *symbol in symbols) {
        NSLog(@"%@", symbol.data);
        str=symbol.data;
        break;
    }
    
    
    [_readerView stop];
    
    if([_delegate respondsToSelector:@selector(finishRead:)]){
        
        [_delegate finishRead:str];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
