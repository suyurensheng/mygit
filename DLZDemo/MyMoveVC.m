//
//  MyMoveVC.m
//  DLZDemo
//
//  Created by 董力祯 on 2018/1/29.
//  Copyright © 2018年 董力祯. All rights reserved.
//

#import "MyMoveVC.h"

@interface MyMoveVC ()<UITableViewDelegate,UITableViewDataSource>{
    
    dispatch_queue_t _zDispatchQueue;
    dispatch_source_t _zSource;
    NSString *_filePath;
    
    UITableView *_table;
    NSArray *_list;
}

@end

@implementation MyMoveVC


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    [self startMonitoringDirectory:_filePath];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileChanged) name:ZFileChangedNotification object:nil];
    
    _table=[[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _table.dataSource=self;
    _table.delegate=self;
    _table.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_table];
    [self fileChanged];
}


-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ZFileChangedNotification object:nil];
    [self stopMonitoringDocument];
}

-(void)fileChanged{
    
    // ZFileChangedNotification 通知是在子线程中发出的, 因此通知关联的方法会在子线程中执行
    NSLog(@"文件发生了改变, %@", [NSThread currentThread]);
    
    NSError *error;
    // 获取指定路径对应文件夹下的所有文件
    NSArray <NSString *> *fileArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_filePath error:&error];
    if (error) {
        NSLog(@"读取错误");
    }else{
        NSMutableArray *list=[[NSMutableArray alloc]init];
        for (NSString *str in fileArray) {
            NSString *path=[_filePath stringByAppendingPathComponent:str];
            if (![self isDirectory:path]) {
                AVAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:path] options:nil];
                NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
                if ([tracks count] > 0) {
                    [list addObject:str];
                }
            }
            NSLog(@"path=%@",path);
        }
        _list=list;
        [_table reloadData];
//
//        dispatch_sync(dispatch_get_main_queue(), ^{
//        });
        NSLog(@"%@", fileArray);
    }
}
-(BOOL)isDirectory:(NSString *)filePath{
    
    BOOL isDirectory = NO;
    [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
    return isDirectory;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _list.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"mymovecell"];
    if (!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"mymovecell"];
    }
    cell.textLabel.text=[_list objectAtIndex:indexPath.row];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *path=[_filePath stringByAppendingPathComponent:[_list objectAtIndex:indexPath.row]];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
// 监听指定目录的文件改动
- (void)startMonitoringDirectory:(NSString *)directoryPath
{
    // 创建 file descriptor (需要将NSString转换成C语言的字符串)
    // open() 函数会建立 file 与 file descriptor 之间的连接
    int filedes = open([directoryPath cStringUsingEncoding:NSASCIIStringEncoding], O_EVTONLY);
    
    // 创建 dispatch queue, 当文件改变事件发生时会发送到该 queue
    _zDispatchQueue = dispatch_queue_create("ZFileMonitorQueue", 0);
    
    // 创建 GCD source. 将用于监听 file descriptor 来判断是否有文件写入操作
    _zSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, filedes, DISPATCH_VNODE_WRITE, _zDispatchQueue);
    
    // 当文件发生改变时会调用该 block
    dispatch_source_set_event_handler(_zSource, ^{
        // 在文件发生改变时发出通知
        // 在子线程发送通知, 这个通知触发的方法会在子线程当中执行
        [[NSNotificationCenter defaultCenter] postNotificationName:ZFileChangedNotification object:nil userInfo:nil];
    });
    
    // 当文件监听停止时会调用该 block
    dispatch_source_set_cancel_handler(_zSource, ^{
        // 关闭文件监听时, 关闭该 file descriptor
        close(filedes);
    });
    
    // 开始监听文件
    dispatch_resume(_zSource);
}
// 停止监听指定目录的文件改动
- (void)stopMonitoringDocument{
    
    dispatch_cancel(_zSource);
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
