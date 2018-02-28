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

@property(nonatomic,strong)PHPlayer *player1;
@property(nonatomic,strong)PH_Control_Player *player2;
@property(nonatomic,strong)PH_Control_Custom_Player *player3;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:@"dismiss" forState:UIControlStateNormal];
    btn.frame = CGRectMake(20, 20, 60, 40);
    [btn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    // Do any additional setup after loading the view, typically from a nib.
}


-(void)click:(id)sender{
     [self dismissViewControllerAnimated:true completion:nil];
}




-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (_index == 1) {
        [self play1];
    }else if (_index == 2){
         [self play2];
    }else{
         [self play3];
    }
}


-(void)play1{
    PHPlayerPlayOptions *options = [[PHPlayerPlayOptions alloc]init];
    options.playerType = PHPlayer_Type_FFPlayer;
    
    NSString *PATH = [[NSBundle mainBundle] pathForResource:@"miaobiao_h.MOV" ofType:nil];
    NSURL *urll = [NSURL fileURLWithPath:PATH];
    _player1 = [PHPlayer playerWithFrame:CGRectMake(0, 100, 350, 280) contentOfUrl:urll.absoluteString playOptions:options];
    _player1.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:_player1];
}


-(void)play2{
    PHPlayerPlayOptions *options = [[PHPlayerPlayOptions alloc]init];
    options.playerType = PHPlayer_Type_FFPlayer;
    
    NSString *PATH = [[NSBundle mainBundle] pathForResource:@"miaobiao_h.MOV" ofType:nil];
    NSURL *urll = [NSURL fileURLWithPath:PATH];
    _player2 = [PH_Control_Player playerWithFrame:CGRectMake(0, 100, 350, 280) contentOfUrl:urll.absoluteString playOptions:options];
    _player2.backgroundColor = [UIColor blackColor];
    _player2.startPlayTime = @(3);
    _player2.endPlayTime = @(10);
    
    [self.view addSubview:_player2];
}


-(void)play3{
    PHPlayerPlayOptions *options = [[PHPlayerPlayOptions alloc]init];
    options.playerType = PHPlayer_Type_FFPlayer;
    
    NSString *PATH = [[NSBundle mainBundle] pathForResource:@"miaobiao_h.MOV" ofType:nil];
    NSURL *urll = [NSURL fileURLWithPath:PATH];
    _player3 = [PH_Control_Custom_Player playerWithFrame:CGRectMake(0, 100, 350, 280) contentOfUrl:urll.absoluteString playOptions:options];
    _player3.backgroundColor = [UIColor blackColor];
    _player3.startPlayTime = @(3);
    _player3.endPlayTime = @(10);
    
    [self.view addSubview:_player3];
}


-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (_index == 1) {
        [_player1 destoryPlayer];
    }else if (_index == 2){
        [_player2 destoryPlayer];
    }else{
        [_player3 destoryPlayer];
    }
}


- (void)dealloc
{
    NSLog(@"Freeeeee");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
