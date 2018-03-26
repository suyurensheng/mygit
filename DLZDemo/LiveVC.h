//
//  LiveVC.h
//  DLZDemo
//
//  Created by 董力祯 on 2017/6/1.
//  Copyright © 2017年 董力祯. All rights reserved.
//

#import "BaseVC.h"
#import <MediaPlayer/MediaPlayer.h>
@interface LiveVC : BaseVC{

    MPMoviePlayerController *_playView;
}
@property (weak, nonatomic) IBOutlet UIView *playBack;

- (IBAction)cancel:(id)sender;
- (IBAction)full:(id)sender;
@end
