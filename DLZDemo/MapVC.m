//
//  MapVC.m
//  DLZDemo
//
//  Created by 董力祯 on 2016/11/21.
//  Copyright © 2016年 董力祯. All rights reserved.
//

#import "MapVC.h"

@interface MapVC ()<MAMapViewDelegate>

@end

@implementation MapVC

- (void)viewDidLoad {
    [super viewDidLoad];
    ///初始化地图
    _mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    ///把地图添加至view
    [self.view addSubview:_mapView];
    [self loadData];
}
-(void)loadData{
    _annotations = [NSMutableArray array];
    CLLocationCoordinate2D coordinates[10] = {
        {39.992520, 116.336170},
        {39.992520, 116.336170},
        {39.998293, 116.352343},
        {40.004087, 116.348904},
        {40.001442, 116.353915},
        {39.989105, 116.353915},
        {39.989098, 116.360200},
        {39.998439, 116.360201},
        {39.979590, 116.324219},
        {39.978234, 116.352792}};
    for (int i = 0; i < 10; ++i){
        MAPointAnnotation *a1 = [[MAPointAnnotation alloc] init];
        a1.coordinate = coordinates[i];
        a1.title      = [NSString stringWithFormat:@"anno: %d", i];
        [_annotations addObject:a1];
    }
}
- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    [_mapView addAnnotations:_annotations];
    [_mapView showAnnotations:_annotations edgePadding:UIEdgeInsetsMake(20, 20, 20, 80) animated:YES];
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation{
    
    if ([annotation isKindOfClass:[MAPointAnnotation class]]){
        
        static NSString *pointReuseIndetifier = @"pointReuseIndetifier";
        MAPinAnnotationView *annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        if (annotationView == nil){
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation                                                 reuseIdentifier:pointReuseIndetifier];
        }
        annotationView.canShowCallout = YES;
        annotationView.animatesDrop = YES;
        annotationView.draggable = YES;
        annotationView.rightCalloutAccessoryView  = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        annotationView.pinColor  = [_annotations indexOfObject:annotation] % 3;
        return annotationView;
    }
    return nil;
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

@end
