//
//  XuanranViewController.m
//  DLZDemo
//
//  Created by 董力祯 on 2017/5/8.
//  Copyright © 2017年 董力祯. All rights reserved.
//

#import "XuanranViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

#import <MediaPlayer/MediaPlayer.h>

#import "FWAmaroFilter.h"//经典
#import "FWNashvilleFilter.h"//奶昔色调
#import "FWLordKelvinFilter.h"//上野
#import "FWRiseFilter.h"//彩虹普
#import "FWHudsonFilter.h"//云端
#import "FWXproIIFilter.h"//淡雅
#import "FW1977Filter.h"//粉红佳人
#import "FWValenciaFilter.h"//复古
#import "FWWaldenFilter.h"//候鸟
#import "FWLomofiFilter.h"//黑白
#import "FWLOMOFilter1.h"//LOMO
#import "FWInkwellFilter.h"//1900
#import "FWSierraFilter.h"//古铜色
#import "FWEarlybirdFilter.h"//哥特
#import "FWSutroFilter.h"//移轴
#import "FWToasterFilter.h"//test1
#import "FWBrannanFilter.h"//test2
#import "FWHefeFilter.h"//test3

@interface XuanranViewController ()<UITableViewDelegate,UITableViewDataSource>{

    
    GPUImageFilterGroup *_filterGroup;
    
    BOOL _isMake;
    
    GPUImageVideoCamera *_videoCamera;
    GPUImageView *_filteredVideoView;
    
    GPUImageSepiaFilter *_filter;
    
    GPUImageMovieWriter *_writer;
    
    NSString *_movieUrl;
    
    MPMoviePlayerController *_mvc;
    
    NSArray *_source;
    
    UIImage *_originImage;
    
    GPUImagePicture *_outimageSource;
}

@end

@implementation XuanranViewController

-(id)init{

    self=[[[NSBundle mainBundle] loadNibNamed:@"XuanranViewController" owner:self options:nil] lastObject];
    if (self) {
        [self loadData];
    }
    return self;
}
-(void)loadData{
    
    CGPoint center=_table.center;

    CGRect frame=_table.frame;
    frame.size.width=80;
    frame.size.height=self.view.frame.size.width;
    _table.frame=frame;
    
    center.x=self.view.frame.size.width/2;
    _table.center=center;

    _table.transform=CGAffineTransformMakeRotation(-M_PI_2);
    

    _source=@[@"原画",@"测试",@"黑白",@"复古",@"HDR",@"优格",@"经典",@"奶昔色调",@"上野",@"彩虹普",@"云端",@"淡雅",@"粉红佳人",@"复古",@"候鸟",@"LOMO",@"1900",@"古铜色",@"哥特",@"移轴",@"test1",@"test2",@"test3"];

    _originImage = [UIImage imageNamed:@"111.jpeg"];
    
    _showImage.image=_originImage;
    
    
    
    //获取数据源
    _outimageSource = [[GPUImagePicture alloc]initWithImage:_originImage];
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return _source.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"filtercellid"];
    if (!cell) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"filtercellid"];
        cell.transform=CGAffineTransformMakeRotation(M_PI_2);
        cell.textLabel.textAlignment=NSTextAlignmentCenter;
        cell.textLabel.font=[UIFont systemFontOfSize:14];
    }
    cell.textLabel.text=[_source objectAtIndex:indexPath.row];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 80.0f;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    NSString *key=[_source objectAtIndex:indexPath.row];
    if ([key isEqualToString:@"原画"]) {
        
        _showImage.image=_originImage;
    }else if ([key isEqualToString:@"测试"]){
        
        GPUImageSharpenFilter *filter=[[GPUImageSharpenFilter alloc]init];
        filter.sharpness=1;
        //设置要渲染的区域
        [filter forceProcessingAtSize:_originImage.size];
        [filter useNextFrameForImageCapture];
        
        GPUImageContrastFilter *filter2=[[GPUImageContrastFilter alloc]init];
        filter2.contrast=0.8;
        [filter2 forceProcessingAtSize:_originImage.size];
        [filter2 useNextFrameForImageCapture];
        
        GPUImageSmoothToonFilter *filter3=[[GPUImageSmoothToonFilter alloc]init];
        filter3.blurRadiusInPixels=1;
        [filter3 forceProcessingAtSize:_originImage.size];
        [filter3 useNextFrameForImageCapture];
        
        GPUImageWhiteBalanceFilter *filter4=[[GPUImageWhiteBalanceFilter alloc]init];
        filter4.temperature=10000.0f;
        [filter4 forceProcessingAtSize:_originImage.size];
        [filter4 useNextFrameForImageCapture];
        
        
        GPUImageBrightnessFilter *filter6=[[GPUImageBrightnessFilter alloc]init];
        filter6.brightness=0.3;
        [filter6 forceProcessingAtSize:_originImage.size];
        [filter6 useNextFrameForImageCapture];
        
        
        _filterGroup = [[GPUImageFilterGroup alloc] init];
        [_outimageSource addTarget:_filterGroup];
        //        [self addGPUImageFilter:filter6];
        
        //            [self addGPUImageFilter:filter];
        [self addGPUImageFilter:filter2];
        [self addGPUImageFilter:filter3];
        [self addGPUImageFilter:filter4];
        
        
        [_outimageSource   processImage];
        UIImage *newImage = [_filterGroup imageFromCurrentFramebuffer];
        
        
        _showImage.image=newImage;
    }else if ([key isEqualToString:@"黑白"]){
    
        GPUImageSketchFilter *filter=[[GPUImageSketchFilter alloc] init];
        [filter forceProcessingAtSize:_originImage.size];
        [filter useNextFrameForImageCapture];
        
        [_outimageSource addTarget:filter];
        [_outimageSource   processImage];
        
        UIImage *newImage = [filter imageFromCurrentFramebuffer];
        
        _showImage.image=newImage;
    }else if ([key isEqualToString:@"复古"]){
        
        GPUImageSoftEleganceFilter *filter=[[GPUImageSoftEleganceFilter alloc] init];
        [filter forceProcessingAtSize:_originImage.size];
        [filter useNextFrameForImageCapture];
        
        _filterGroup = [[GPUImageFilterGroup alloc] init];
        [self addGPUImageFilter:filter];
        
        [_outimageSource addTarget:_filterGroup];
        [_outimageSource   processImage];
        
        
        UIImage *newImage = [_filterGroup imageFromCurrentFramebuffer];
        
        _showImage.image=newImage;
    }else if ([key isEqualToString:@"HDR"]){
        
        GPUImageMissEtikateFilter *filter=[[GPUImageMissEtikateFilter alloc] init];
        [filter forceProcessingAtSize:_originImage.size];
        [filter useNextFrameForImageCapture];
        
        _filterGroup = [[GPUImageFilterGroup alloc] init];
        [self addGPUImageFilter:filter];
        
        [_outimageSource addTarget:_filterGroup];
        [_outimageSource   processImage];
        
        
        UIImage *newImage = [_filterGroup imageFromCurrentFramebuffer];
        
        _showImage.image=newImage;
    }else if ([key isEqualToString:@"优格"]){
        
        GPUImageAmatorkaFilter *filter=[[GPUImageAmatorkaFilter alloc] init];
        [filter forceProcessingAtSize:_originImage.size];
        [filter useNextFrameForImageCapture];
        
        _filterGroup = [[GPUImageFilterGroup alloc] init];
        [self addGPUImageFilter:filter];
        
        [_outimageSource addTarget:_filterGroup];
        [_outimageSource   processImage];
        
        
        UIImage *newImage = [_filterGroup imageFromCurrentFramebuffer];
        
        _showImage.image=newImage;
    }else if ([key isEqualToString:@"经典"]){
        
        FWAmaroFilter *filter=[[FWAmaroFilter alloc] init];
        [filter forceProcessingAtSize:_originImage.size];
        [filter useNextFrameForImageCapture];
        
        _filterGroup = [[GPUImageFilterGroup alloc] init];
        [self addGPUImageFilter:filter];
        
        [_outimageSource addTarget:_filterGroup];
        [_outimageSource   processImage];
        
        
        UIImage *newImage = [_filterGroup imageFromCurrentFramebuffer];
        
        _showImage.image=newImage;
    }else if ([key isEqualToString:@"奶昔色调"]){
        
        FWNashvilleFilter *filter = [[FWNashvilleFilter alloc] init];
        [filter forceProcessingAtSize:_originImage.size];
        [filter useNextFrameForImageCapture];

        _filterGroup = [[GPUImageFilterGroup alloc] init];
        [self addGPUImageFilter:filter];
        
        [_outimageSource addTarget:_filterGroup];
        [_outimageSource   processImage];
        
        UIImage *newImage = [_filterGroup imageFromCurrentFramebuffer];
        _showImage.image=newImage;
    }else if ([key isEqualToString:@"上野"]){
        
        FWLordKelvinFilter *filter = [[FWLordKelvinFilter alloc] init];
        [filter forceProcessingAtSize:_originImage.size];
        [filter useNextFrameForImageCapture];
        
        _filterGroup = [[GPUImageFilterGroup alloc] init];
        [self addGPUImageFilter:filter];
        
        [_outimageSource addTarget:_filterGroup];
        [_outimageSource   processImage];
        
        UIImage *newImage = [_filterGroup imageFromCurrentFramebuffer];
        _showImage.image=newImage;
    }else if ([key isEqualToString:@"彩虹普"]){
        
        FWRiseFilter *filter = [[FWRiseFilter alloc] init];
        [filter forceProcessingAtSize:_originImage.size];
        [filter useNextFrameForImageCapture];
        
        _filterGroup = [[GPUImageFilterGroup alloc] init];
        [self addGPUImageFilter:filter];
        
        [_outimageSource addTarget:_filterGroup];
        [_outimageSource   processImage];
        
        UIImage *newImage = [_filterGroup imageFromCurrentFramebuffer];
        _showImage.image=newImage;
    }else if ([key isEqualToString:@"云端"]){
        
        FWHudsonFilter *filter = [[FWHudsonFilter alloc] init];
        [filter forceProcessingAtSize:_originImage.size];
        [filter useNextFrameForImageCapture];
        
        _filterGroup = [[GPUImageFilterGroup alloc] init];
        [self addGPUImageFilter:filter];
        
        [_outimageSource addTarget:_filterGroup];
        [_outimageSource   processImage];
        
        UIImage *newImage = [_filterGroup imageFromCurrentFramebuffer];
        _showImage.image=newImage;
    }else if ([key isEqualToString:@"淡雅"]){
        
        FWXproIIFilter *filter = [[FWXproIIFilter alloc] init];
        [filter forceProcessingAtSize:_originImage.size];
        [filter useNextFrameForImageCapture];
        
        _filterGroup = [[GPUImageFilterGroup alloc] init];
        [self addGPUImageFilter:filter];
        
        [_outimageSource addTarget:_filterGroup];
        [_outimageSource   processImage];
        
        UIImage *newImage = [_filterGroup imageFromCurrentFramebuffer];
        _showImage.image=newImage;
    }else if ([key isEqualToString:@"粉红佳人"]){
        
        FW1977Filter *filter = [[FW1977Filter alloc] init];
        [filter forceProcessingAtSize:_originImage.size];
        [filter useNextFrameForImageCapture];
        
        _filterGroup = [[GPUImageFilterGroup alloc] init];
        [self addGPUImageFilter:filter];
        
        [_outimageSource addTarget:_filterGroup];
        [_outimageSource   processImage];
        
        UIImage *newImage = [_filterGroup imageFromCurrentFramebuffer];
        _showImage.image=newImage;
    }else if ([key isEqualToString:@"复古"]){
        
        FWValenciaFilter *filter = [[FWValenciaFilter alloc] init];
        [filter forceProcessingAtSize:_originImage.size];
        [filter useNextFrameForImageCapture];
        
        _filterGroup = [[GPUImageFilterGroup alloc] init];
        [self addGPUImageFilter:filter];
        
        [_outimageSource addTarget:_filterGroup];
        [_outimageSource   processImage];
        
        UIImage *newImage = [_filterGroup imageFromCurrentFramebuffer];
        _showImage.image=newImage;
    }else if ([key isEqualToString:@"候鸟"]){
        
        FWWaldenFilter *filter = [[FWWaldenFilter alloc] init];
        [filter forceProcessingAtSize:_originImage.size];
        [filter useNextFrameForImageCapture];
        
        _filterGroup = [[GPUImageFilterGroup alloc] init];
        [self addGPUImageFilter:filter];
        
        [_outimageSource addTarget:_filterGroup];
        [_outimageSource   processImage];
        
        UIImage *newImage = [_filterGroup imageFromCurrentFramebuffer];
        _showImage.image=newImage;
    }
    else if ([key isEqualToString:@"LOMO"]){
        
        FWLOMOFilter1 *filter = [[FWLOMOFilter1 alloc] init];
        [filter forceProcessingAtSize:_originImage.size];
        [filter useNextFrameForImageCapture];
        
        _filterGroup = [[GPUImageFilterGroup alloc] init];
        [self addGPUImageFilter:filter];
        
        [_outimageSource addTarget:_filterGroup];
        [_outimageSource   processImage];
        
        UIImage *newImage = [_filterGroup imageFromCurrentFramebuffer];
        _showImage.image=newImage;
    }
    else if ([key isEqualToString:@"1900"]){
        
        FWInkwellFilter *filter = [[FWInkwellFilter alloc] init];
        [filter forceProcessingAtSize:_originImage.size];
        [filter useNextFrameForImageCapture];
        
        _filterGroup = [[GPUImageFilterGroup alloc] init];
        [self addGPUImageFilter:filter];
        
        [_outimageSource addTarget:_filterGroup];
        [_outimageSource   processImage];
        
        UIImage *newImage = [_filterGroup imageFromCurrentFramebuffer];
        _showImage.image=newImage;
    }
    else if ([key isEqualToString:@"古铜色"]){
        
        FWSierraFilter *filter = [[FWSierraFilter alloc] init];
        [filter forceProcessingAtSize:_originImage.size];
        [filter useNextFrameForImageCapture];
        
        _filterGroup = [[GPUImageFilterGroup alloc] init];
        [self addGPUImageFilter:filter];
        
        [_outimageSource addTarget:_filterGroup];
        [_outimageSource   processImage];
        
        UIImage *newImage = [_filterGroup imageFromCurrentFramebuffer];
        _showImage.image=newImage;
    }
    else if ([key isEqualToString:@"哥特"]){
        
        FWEarlybirdFilter *filter = [[FWEarlybirdFilter alloc] init];
        [filter forceProcessingAtSize:_originImage.size];
        [filter useNextFrameForImageCapture];
        
        _filterGroup = [[GPUImageFilterGroup alloc] init];
        [self addGPUImageFilter:filter];
        
        [_outimageSource addTarget:_filterGroup];
        [_outimageSource   processImage];
        
        UIImage *newImage = [_filterGroup imageFromCurrentFramebuffer];
        _showImage.image=newImage;
    }else if ([key isEqualToString:@"移轴"]){
        
        FWSutroFilter *filter = [[FWSutroFilter alloc] init];
        [filter forceProcessingAtSize:_originImage.size];
        [filter useNextFrameForImageCapture];
        
        _filterGroup = [[GPUImageFilterGroup alloc] init];
        [self addGPUImageFilter:filter];
        
        [_outimageSource addTarget:_filterGroup];
        [_outimageSource   processImage];
        
        UIImage *newImage = [_filterGroup imageFromCurrentFramebuffer];
        _showImage.image=newImage;
    }else if ([key isEqualToString:@"test1"]){
        
        FWToasterFilter *filter = [[FWToasterFilter alloc] init];
        [filter forceProcessingAtSize:_originImage.size];
        [filter useNextFrameForImageCapture];
        
        _filterGroup = [[GPUImageFilterGroup alloc] init];
        [self addGPUImageFilter:filter];
        
        [_outimageSource addTarget:_filterGroup];
        [_outimageSource   processImage];
        
        UIImage *newImage = [_filterGroup imageFromCurrentFramebuffer];
        _showImage.image=newImage;
    }else if ([key isEqualToString:@"test2"]){
        
        FWBrannanFilter *filter = [[FWBrannanFilter alloc] init];
        [filter forceProcessingAtSize:_originImage.size];
        [filter useNextFrameForImageCapture];
        
        _filterGroup = [[GPUImageFilterGroup alloc] init];
        [self addGPUImageFilter:filter];
        
        [_outimageSource addTarget:_filterGroup];
        [_outimageSource   processImage];
        
        UIImage *newImage = [_filterGroup imageFromCurrentFramebuffer];
        _showImage.image=newImage;
    }else if ([key isEqualToString:@"test3"]){
        
        FWHefeFilter *filter = [[FWHefeFilter alloc] init];
        [filter forceProcessingAtSize:_originImage.size];
        [filter useNextFrameForImageCapture];
        
        _filterGroup = [[GPUImageFilterGroup alloc] init];
        [self addGPUImageFilter:filter];
        
        [_outimageSource addTarget:_filterGroup];
        [_outimageSource   processImage];
        
        UIImage *newImage = [_filterGroup imageFromCurrentFramebuffer];
        _showImage.image=newImage;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    

//
//    
//    
////    //添加上滤镜
////    [stillImageSource addTarget:filter];
//    //开始渲染
//    [_outimageSource processImage];
//    //获取渲染后的图片
//    UIImage *newImage = [_filterGroup imageFromCurrentFramebuffer];
//    
//    _showImage.image=newImage;
//    
//    _isMake=NO;
//    
//    _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
//    _videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
//    [_videoCamera addAudioInputsAndOutputs];
//
//    
//    _filteredVideoView = [[GPUImageView alloc] initWithFrame:_videoView.bounds];
//    _filteredVideoView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
//    _filteredVideoView.enabled=YES;
//    [_videoView addSubview:_filteredVideoView];
//
//    GPUImageSepiaFilter *filter=[[GPUImageSepiaFilter alloc] init];
//    
//    [_videoCamera addTarget:filter];
//    [filter addTarget:_filteredVideoView];
//    
//    [_videoCamera startCameraCapture];
}
- (void)addGPUImageFilter:(GPUImageOutput<GPUImageInput> *)filter
{
    [_filterGroup addFilter:filter];
    
    GPUImageOutput<GPUImageInput> *newTerminalFilter = filter;
    
    NSInteger count = _filterGroup.filterCount;
    
    if (count == 1)
    {
        _filterGroup.initialFilters = @[newTerminalFilter];
        _filterGroup.terminalFilter = newTerminalFilter;
        
    } else
    {
        GPUImageOutput<GPUImageInput> *terminalFilter    = _filterGroup.terminalFilter;
        NSArray *initialFilters                          = _filterGroup.initialFilters;
        
        [terminalFilter addTarget:newTerminalFilter];
        
        _filterGroup.initialFilters = @[initialFilters[0]];
        _filterGroup.terminalFilter = newTerminalFilter;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)start:(id)sender {
    
    if (!_isMake) {//开始录制
        
        NSDateFormatter *formater=[[NSDateFormatter alloc]init];
        [formater setDateFormat:@"yyyyMMddHHmmss"];
        
        _movieUrl=[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:[formater stringFromDate:[NSDate date]]];

        AudioChannelLayout channelLayout;
        memset(&channelLayout, 0, sizeof(AudioChannelLayout));
        channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
        
        _writer=[[GPUImageMovieWriter alloc]initWithMovieURL:[NSURL fileURLWithPath:_movieUrl] size:CGSizeMake(640, 480)];
        _videoCamera.audioEncodingTarget = _writer;
        _writer.encodingLiveVideo = YES;

        _writer.hasAudioTrack=YES;
        [_filter addTarget:_writer];
        
        [_writer startRecording];
        _isMake=YES;
        NSLog(@"开始录制");

    }else{//结束录制并开始保存
        NSLog(@"结束录制");

        [_writer finishRecordingWithCompletionHandler:^{
            NSLog(@"可以播放 ，stime=%f",CMTimeGetSeconds(_writer.duration));
            
            [_filter removeTarget:_writer];
            _videoCamera.audioEncodingTarget=nil;
        }];
        _isMake=NO;
    }
}

- (IBAction)play:(id)sender {//播放
    
    NSLog(@"开始播放");
    
    NSFileManager *manger=[NSFileManager defaultManager];
    NSArray *type=[[manger attributesOfItemAtPath:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"m4v"] error:nil] allValues];
    NSLog(@"values=%@",type);


    if ([manger fileExistsAtPath:_movieUrl]) {
        
        CGFloat size=[[manger attributesOfItemAtPath:_movieUrl error:nil] fileSize];
        NSString *type=[[manger attributesOfItemAtPath:_movieUrl error:nil] fileType];
        
        NSLog(@"存在文件，大小=%fM  type=%@",size/1024.0f/1024.0f,type);

    }else{
        NSLog(@"没有文件");
    }

    
//    NSString *path=[[NSBundle mainBundle] pathForResource:@"test" ofType:@"m4v"];
//    _mvc=[[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:path]];
    _mvc=[[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:_movieUrl]];
    _mvc.view.frame=self.view.bounds;
    [_mvc prepareToPlay];
    [_mvc setShouldAutoplay:NO];
    [self.view addSubview:_mvc.view];
    _mvc.movieSourceType=MPMovieSourceTypeFile;
    [_mvc play];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playfinished) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
//    
//    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//
//    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(_movieUrl)) {
//        [library writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:_movieUrl] completionBlock:^(NSURL *assetURL, NSError *error){
//            dispatch_async(dispatch_get_main_queue(), ^{
//                
//                if (error) {
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"视频保存失败" message:nil
//                                                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                    [alert show];
//                } else {
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"视频保存成功" message:nil
//                                                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                    [alert show];
//                }
//            });
//        }];
//    }else {
//        NSLog(@"error mssg)");
//    }
}
-(void)playfinished{

    [_mvc.view removeFromSuperview];
}
@end
