//
//  ViewController.m
//  PHPlayerDemo
//
//  Created by pidi on 2018/2/24.
//  Copyright © 2018年 Peter Hu. All rights reserved.
//

#import "ViewController.h"

#import "PH_Control_Custom_Player.h"

@interface ViewController ()

@property(nonatomic,strong)PH_Control_Custom_Player *player;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    // Do any additional setup after loading the view, typically from a nib.
}



-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    
    PHPlayerPlayOptions *options = [[PHPlayerPlayOptions alloc]init];
    options.playerType = PHPlayer_Type_FFPlayer;
    
    NSString *PATH = [[NSBundle mainBundle] pathForResource:@"miaobiao_h.MOV" ofType:nil];
    NSURL *urll = [NSURL fileURLWithPath:PATH];
    _player = [PH_Control_Custom_Player playerWithFrame:CGRectMake(0, 50, 350, 280) contentOfUrl:urll.absoluteString playOptions:options];
    _player.backgroundColor = [UIColor blackColor];
    _player.startPlayTime = @(-1);
    _player.endPlayTime = @(-1);
    
    [self.view addSubview:_player];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(12.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_player pause];
//
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_player play];
        //
    });
    
    
    
    
    
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        
//        //
//        [_player destoryPlayer];
//        
//    });
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        
//        //
//        [_player reloadPlayer];
//        
//    });
   
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
