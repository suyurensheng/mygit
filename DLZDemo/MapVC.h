//
//  MapVC.h
//  DLZDemo
//
//  Created by 董力祯 on 2016/11/21.
//  Copyright © 2016年 董力祯. All rights reserved.
//

#import "BaseVC.h"
#import <AMap3DMap/MAMapKit/MAMapKit.h>

@interface MapVC : BaseVC{

    MAMapView *_mapView;
    NSMutableArray *_annotations;
}

@end
