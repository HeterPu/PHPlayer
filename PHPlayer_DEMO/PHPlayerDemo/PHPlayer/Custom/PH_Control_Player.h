//
//  PH_Control_Player.h
//  PHPlayerDemo
//
//  Created by Peter Hu on 2018/2/27.
//  Copyright © 2018年 Peter Hu. All rights reserved.
//

#import "PHPlayer.h"


/**
 Player Function Control(播放器功能控制)

 - PHControlPlayer_function_None: Remove all functions (禁用所有功能)
 - PHControlPlayer_function_BrightChange: Brightness changes (亮度调节)
 - PHControlPlayer_function_VolumnChange: Volumn changes(音量调节)
 - PHControlPlayer_function_Seek_Back_Forward_Change:Seek back or forward changes (快进和快推功能)
 - PHControlPlayer_function_Pan_function_All: Remove Pan functions (包含所有PAN手势功能)
 */
typedef NS_OPTIONS(NSUInteger, PHControlPlayer_function){
    PHControlPlayer_function_None = 0,
    PHControlPlayer_function_BrightChange = 1,
    PHControlPlayer_function_VolumnChange = 1 << 1,
    PHControlPlayer_function_Seek_back_forward_Change = 1 << 2,
    PHControlPlayer_function_Pan_function_All = PHControlPlayer_function_BrightChange|PHControlPlayer_function_VolumnChange |PHControlPlayer_function_Seek_back_forward_Change
};

/**
 Subclassing PHPlayer, Including ControlBar and other Custom interface.
 */
@interface PH_Control_Player : PHPlayer


/**
 Default is  controlFunction = PHControlPlayer_function_Pan_function_All
 */
@property(nonatomic,assign)PHControlPlayer_function controlFunction;



#pragma mark -- 播放器区间播放的控制
/**
   Start  play time (对于区间播放的控制,不设置那么就全时长播放),从头播放设置startPlayTime = -1
 */
@property(nonatomic,strong)NSNumber *startPlayTime;

/**
 End  play time (对于区间播放的控制,不设置那么就全时长播放),若播放到结尾设置endPlayTime = -1
 */
@property(nonatomic,strong)NSNumber *endPlayTime;


#pragma mark -- For Private

/**
 界面的点击事件
 @param sender 点击的gesture
 */
-(void)player_tapClick:(id)sender;


@end
