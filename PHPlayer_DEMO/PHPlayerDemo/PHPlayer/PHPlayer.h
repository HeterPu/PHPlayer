//  PHPlayer
//  Created by Peter Hu on 2018/2/24.
//  Copyright © 2018年 Peter Hu. All rights reserved.
//  Github:https://github.com/HeterPu/PHPlayer , like it,star it.


#import <UIKit/UIKit.h>
#import <IJKMediaFramework/IJKMediaFramework.h>


// 基类控制器提供最核心的播放逻辑及事件回调，需要自定义的需要继承PHPlayer，见"PHControlPlayer"


/* Attentions:
  1.将播放器放在IOS根视图控制器viewdidload前初始化会造成有声音,没有画面的情况,APP进入后台再进入恢复显示的情况,其它控制器没有这个问题。
  2.使用AVPlayer和MPPlayer在播放系统视频时倘若加载http开头的资源网络视频时，会播放不成功，而FFPlayer无影响，必须将NSAllowsArbitraryLoads 设置为YES 来禁用ATS。
  3.在初始化时MPPlayer调用 prepareToPlay 和 play 都会播放，AVPlayer必须先调用prepareToplay再调用play才会播放，而FFPlayer调用prepareToplay就会播放，无需play，内部已经处理，外部不用管。
  4.在播放直播流时使用AVPlayer，MPPlayer播放推流时会导致进入后台会导致流停止，需要重新设置播放器
 
 */

/**
 播放器的播放器选项
 - PHPlayer_Type_MPPlayer: 播放器的播放器选项主要有三种:基于IOS系统的MediaPlayer,AVPlayer和基于FFMPeg的FFPlayer.
 */
typedef NS_ENUM(NSInteger, PHPlayer_Type) {
    PHPlayer_Type_AVPlayer = 0,                //调节IOS AVPlayer播放器
    PHPlayer_Type_MPPlayer,                    //基于IOS MediaPlayer播放器
    PHPlayer_Type_FFPlayer,                    //基于FFMPEG 的播放器
};


#pragma mark -- PHPlayerPlayOptions

@interface PHPlayerPlayOptions : NSObject

/**
 Is AutoPlay, default isAutoPlay = TRUE.
 */
@property(nonatomic,assign) BOOL isAutoPlay;

/**
 Is CirclePlay,Play end,  Play start again. default isCirclePlay = TRUE.
 */
@property(nonatomic,assign) BOOL isCirclePlay;

/**
 For Player Type ,default playerType = PHPlayer_Type_AVPlayer.
 */
@property(nonatomic,assign) PHPlayer_Type playerType;

/**
 ScaleMode ,default scaleMode = IJKMPMovieScalingModeAspectFit
 */
@property(nonatomic,assign) IJKMPMovieScalingMode scaleMode;

/**
 For FFMPegPlayer Type
 */
@property(nonatomic,strong) IJKFFOptions *ffPlayerOptions;

@end;


#pragma mark -- PHPlayerPlayStateDelegate


/**
 Basic Player state delegate ,light wight ,more informatoin see
 */
@protocol PHPlayerPlayStateDelegate <NSObject>

@optional
/**
 Player Will play
 */
- (void)ph_PlayerWillPlay;

/**
 Player Will pause
 */
- (void)ph_PlayerWillPause;

/**
 Player Will stop
 */
-(void)ph_PlayerWillStop;

/**
 Player Will destory
 */
-(void)ph_PlayerWillDestory;

@end



#pragma mark -- PHPlayerMainStateDelegate

/**
 MainState Protocal About Going to play, App state , network
 */
@protocol PHPlayerMainStateDelegate <NSObject>

@optional

-(void)player_isPreparedToPlayDidChange_event:(NSNotification*)notification;


-(void)player_netWorkStateChange_event:(NSNotification*)notification;


-(void)player_resignActive_event:(NSNotification*)notification;


-(void)player_becomeActive_event:(NSNotification*)notification;

@end


#pragma mark -- PHPlayerPlayBackFinishDelegate

/**
 MainState Protocal About Going to play, App state , network
 */
@protocol PHPlayerPlayBackFinishDelegate <NSObject>

@optional
-(void)player_finishReasonPlaybackEnded;

-(void)player_finishReasonUserExited;

-(void)player_finishReasonPlaybackError;

@end


#pragma mark -- PHPlayerPlayAllStateDelegate


/**
 AllPlayState Protocal incuding each play state.
 */
@protocol PHPlayerPlayAllStateDelegate <NSObject>

@optional

-(void)player_playbackStatePlaying;

-(void)player_playbackStateStopped;

-(void)player_playbackStatePaused;

-(void)player_playbackStateInterrupted;

-(void)player_playbackStateSeekingForward;

-(void)player_playbackStateSeekingBackward;

@end




#pragma mark -- PHPlayer


@interface PHPlayer : UIView


/**
(init Method)初始化播放器的类方法
 @param frame frame size
 @param url local url use (file:var...)
 @param options Play Configuratoin
 @return instance
 */
+(instancetype)playerWithFrame:(CGRect)frame contentOfUrl:(NSString *)url playOptions:(PHPlayerPlayOptions *)options allStateDelegate:(id<PHPlayerPlayAllStateDelegate>) allStateDelegate;


/**
 Player Options
 */
@property(nonatomic,readonly)PHPlayerPlayOptions *playOptions;

/**
 Real Player
 */
@property(nonatomic,readonly)id <IJKMediaPlayback> player;


/**
 当前的Url;
 */
@property(nonatomic,strong)NSString * playUrl;

#pragma mark -- All Delegate
/**
 Play light state delegate.
 */
@property(weak,nonatomic)id<PHPlayerPlayStateDelegate> stateDelegate;

/**
 Play light state delegate.
 */
@property(weak,nonatomic)id<PHPlayerPlayAllStateDelegate> allStateDelegate;

/**
 Play light state delegate.
 */
@property(weak,nonatomic)id<PHPlayerPlayBackFinishDelegate> finishDelegate;

/**
 Play light state delegate.
 */
@property(weak,nonatomic)id<PHPlayerMainStateDelegate> mainStateDelegate;


/**
 Play
 */
-(void)play;


/**
 Pause
 */
-(void)pause;


/**
 destotyPlayer,
 */
-(void)destoryPlayer;


/**
 Reload Player
 */
-(void)reloadPlayer;


/**
 Video is LoadFromNet or local.
 */
@property(nonatomic,readonly) BOOL isLoadFromLocal;


#pragma mark -- Private For Subclassing


/**
 Configure Other Logic BUT Player,
 */
-(void)configuration;

// ---- Noticification For SubClass Overriding Start

// Main State

-(void)player_isPreparedToPlayDidChange_event:(NSNotification*)notification;

-(void)player_netWorkStateChange_event:(NSNotification*)notification;

-(void)player_resignActive_event:(NSNotification*)notification;

-(void)player_becomeActive_event:(NSNotification*)notification;


// StateDidChange sub state

-(void)player_loadStatePlaythroughOK;

-(void)player_loadStatePlaystalled;

-(void)player_loadStatePlayable;

-(void)player_loadStateUnknown;


// PlayBackFinish sub state

/**
 Deal with circle play logic, Subclassing must call " [super player_finishReasonPlaybackEnded];"
 */
-(void)player_finishReasonPlaybackEnded;

-(void)player_finishReasonUserExited;

-(void)player_finishReasonPlaybackError;


// PlayBackStateChanged sub state

/**
 When Player start play from a new startpoint,this method call,
 */
-(void)player_playbackStatePlaying;

-(void)player_playbackStateStopped;

-(void)player_playbackStatePaused;

-(void)player_playbackStateInterrupted;

-(void)player_playbackStateSeekingForward;

-(void)player_playbackStateSeekingBackward;


// ----- Noticification For SubClass Overriding End


/**
 Set Default FFPlayer Options
 @return Default Options
 */
-(IJKFFOptions *)getDefaultFFPlayerOptions;

/**
 Get Network change noticification name;

 @return Noticification Name
 */
-(NSString *)getNetChangeNoticificationName;


/**
 Decide Player isPlayer final Valve
 @return Defalut is true
 */
-(BOOL)becomeAlivePlayBossValve;

@end
