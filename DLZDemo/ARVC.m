//
//  ARVC.m
//  DLZDemo
//
//  Created by 董力祯 on 2018/4/20.
//  Copyright © 2018年 董力祯. All rights reserved.
//

#import "ARVC.h"
#import <ARKit/ARKit.h>

@interface ARVC ()<ARSCNViewDelegate>{
    
    ARSCNView *_showView;
}

@end

@implementation ARVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _showView=[[ARSCNView alloc]initWithFrame:CGRectMake((MAIN_SCREAM_WIDTH-300)/2, (MAIN_SCREAM_HEIGHT-300-64)/2, 300, 300)];
    _showView.delegate=self;
    [self.view addSubview:_showView];
    
    // Show statistics such as fps and timing information
    _showView.showsStatistics = YES;
    
    // Create a new scene
    SCNScene *scene = [SCNScene sceneNamed:@"art.scnassets/ship.scn"];
    
    // Set the scene to the view
    _showView.scene = scene;
    
}
- (void)renderer:(id)renderer didAddNode:(SCNNode*)node forAnchor:(ARAnchor*)anchor{
    
    ARPlaneAnchor *planeAnchor =(ARPlaneAnchor*)anchor;
    
    SCNPlane*plane =[SCNPlane planeWithWidth:planeAnchor.extent.x height:planeAnchor.extent.z];
    
    SCNNode*planeNode = [SCNNode nodeWithGeometry:plane];
    
    planeNode.position=SCNVector3Make(planeAnchor.center.x,0, planeAnchor.center.z);
    
    planeNode.transform=SCNMatrix4MakeRotation(-M_PI/2,1,0,0);
    
    [node addChildNode:planeNode];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (@available(iOS 11.0, *)) {
        ARWorldTrackingConfiguration*configuration = [ARWorldTrackingConfiguration new];
        configuration.worldAlignment=ARWorldAlignmentGravity;
        configuration.planeDetection=ARPlaneDetectionHorizontal;
        
        // Run the view's session
        
        [_showView.session runWithConfiguration:configuration];
    } else {
        // Fallback on earlier versions
    }
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
