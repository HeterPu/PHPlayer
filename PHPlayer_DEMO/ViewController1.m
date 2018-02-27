//
//  ViewController1.m
//  PHPlayerDemo
//
//  Created by pidi on 2018/2/28.
//  Copyright © 2018年 Peter Hu. All rights reserved.
//

#import "ViewController1.h"
#import "ViewController.h"

@interface ViewController1 ()

@end

@implementation ViewController1


- (IBAction)PLAY1:(id)sender {
    ViewController *con = [[ViewController alloc]init];
    con.index = 1;
    [self presentViewController:con animated:true completion:nil];
}


- (IBAction)PLAY2:(id)sender {
    ViewController *con = [[ViewController alloc]init];
    con.index = 2;
    [self presentViewController:con animated:true completion:nil];
}


- (IBAction)PLAY3:(id)sender {
    ViewController *con = [[ViewController alloc]init];
    con.index = 3;
    [self presentViewController:con animated:true completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
