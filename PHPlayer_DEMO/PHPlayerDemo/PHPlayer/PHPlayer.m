//  PHPlayer
//  Created by Peter Hu on 2018/2/24.
//  Copyright © 2018年 Peter Hu. All rights reserved.
//  Github:https://github.com/HeterPu/PHPlayer , like it,star it.


#import "PHPlayer.h"

@implementation PHPlayerPlayOptions

-(instancetype)init{
    self = [super init];
    // 设置配置项默认值
    self.isAutoPlay = true;
    self.isCirclePlay = true;
    self.scaleMode = IJKMPMovieScalingModeAspectFit;
    self.playerType = PHPlayer_Type_AVPlayer;
    return self;
}

@end;


@interface PHPlayer()

/*
 IJKplayer播放器
 */
@property(nonatomic,retain)id <IJKMediaPlayback> player;
@property(nonatomic,strong)PHPlayerPlayOptions *playOptions;

@property(nonatomic,assign) BOOL isLoadFromLocal;


/**
 Stop player state in backGround
 */
@property(nonatomic,assign) BOOL playerIsPlayingBeforeEnterforeground;

@end

@implementation PHPlayer

+(instancetype)playerWithFrame:(CGRect)frame contentOfUrl:(NSString *)url playOptions:(PHPlayerPlayOptions *)options allStateDelegate:(id<PHPlayerPlayAllStateDelegate>) allStateDelegate{
    PHPlayer *instance = [[[self class] alloc]initWithFrame:frame];
    if (instance) {
        if (!url) {
            NSLog(@"Invalid Playurl,url is nil");
        }
        instance.isLoadFromLocal = !([url hasPrefix:@"http"]||[url hasPrefix:@"rtmp"]);
        instance.playUrl = url;
        instance.playOptions = options;
        instance.allStateDelegate = allStateDelegate;
        [instance configuration];
    }
    return instance;
}




#pragma mark -- Initailization Player

-(void)configuration{
    [self reloadPlayer];
}

-(void)setUpMPPlayer{
    self.player = [[IJKMPMoviePlayerController alloc]initWithContentURLString:self.playUrl];
    [self insertSubview:self.player.view atIndex:0];
}


-(void)setUpAVPlayer{
    self.player = [[IJKAVMoviePlayerController alloc]initWithContentURL:[NSURL URLWithString:self.playUrl]];
    [self insertSubview:self.player.view atIndex:0];
}



-(void)setUpFFPlayer{
    IJKFFOptions *options = self.playOptions.ffPlayerOptions;
    if (!options)options = [self getDefaultFFPlayerOptions];
    self.player = [[IJKFFMoviePlayerController alloc]initWithContentURLString:self.playUrl withOptions:options];
    [self insertSubview:self.player.view atIndex:0];
}

-(void)reloadPlayer{
    
    //播放器已存在说明未调用destory销毁,再创建，不执行播放器创建
    if(self.player)return;
    [self installNoticification];
    // 初始化三种播放器属性
    if (self.playOptions.playerType == PHPlayer_Type_AVPlayer) {
        [self setUpAVPlayer];
    }else if (self.playOptions.playerType == PHPlayer_Type_MPPlayer){
        [self setUpMPPlayer];
    }else if (self.playOptions.playerType == PHPlayer_Type_FFPlayer){
        [self setUpFFPlayer];
    }else{
        // None
    }
    
    //设置播放器其它属性
    [self.player setScalingMode:self.playOptions.scaleMode];
    
    // 设置自动播放选项，并且缓存准备播放
    self.player.shouldAutoplay = self.playOptions.isAutoPlay;
    [self.player setPauseInBackground:true];
    [self.player prepareToPlay];
    
}

#pragma mark ----------- Noticification  START

-(void)installNoticification{
    
    // IOS 9 以下不能添加此监听，否则播放会炸
    if (@available(iOS 9, *)) {
    // 加载状态改变
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(player_loadStateDidChange_event:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object:nil];
    }
    
    //播放进度改变完成
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(player_playBackFinish_event:)
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
    
    //准备播放状态改变
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(player_isPreparedToPlayDidChange_event:)
                                                 name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:nil];
    //播放状态改变的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(player_playBackStateDidChange_event:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                               object:nil];
    
    //指定播放到区域结束
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(player_seekCompleted_event) name:IJKMPMoviePlayerDidSeekCompleteNotification object:nil];
    
    //网络监听
    [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(player_netWorkStateChange_event:) name:[self getNetChangeNoticificationName]
     
                                              object:nil];
    
    
    
    //应用进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(player_resignActive_event:) name:UIApplicationWillResignActiveNotification
                                                   object:nil];
    
    //应用进入后台
    [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(player_becomeActive_event:) name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
}




-(void)uninstallNoticification{
    // IOS 9 以下不能添加此监听，否则播放会炸
    if (@available(iOS 9, *)) {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                                  object:nil];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:IJKMPMoviePlayerDidSeekCompleteNotification
                                                 object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[self getNetChangeNoticificationName]
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillResignActiveNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
}


#pragma mark -- Detail Player State


-(void)player_loadStateDidChange_event:(NSNotification*)notification{
    IJKMPMovieLoadState loadState = _player.loadState;
    
    switch (loadState) {
        case IJKMPMovieLoadStatePlaythroughOK:
            {
                NSLog(@"加载状态变成了已经缓存完成，如果设置了自动播放，这时会自动播放");
                [self player_loadStatePlaythroughOK];
            }
            break;
        case IJKMPMovieLoadStateStalled:
        {
            NSLog(@"加载状态变成了数据缓存已经停止，播放将暂停");
            [self player_loadStatePlaystalled];
        }
            break;
        case IJKMPMovieLoadStatePlayable:
        {
            NSLog(@"加载状态变成了缓存数据足够开始播放，但是视频并没有缓存完全");
            //播放器加载状态可能会调几次这个方法,采用技术手段来避免重复调用
            [self player_loadStatePlayable];
        }
            break;
        case IJKMPMovieLoadStateUnknown:
        {
            NSLog(@"加载状态变成了未知状态");
            [self player_loadStateUnknown];
        }
            break;
            
        default:
            break;
    }
}

-(void)player_playBackFinish_event:(NSNotification*)notification{
    NSLog(@"player_playBackFinish_event");
    int reason = [[[notification userInfo]valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    
    switch (reason) {
        case IJKMPMovieFinishReasonPlaybackEnded:
        {
            [self player_finishReasonPlaybackEnded];
        }
            break;
        case IJKMPMovieFinishReasonUserExited:
            NSLog(@"播放状态改变了：现在是用户退出状态：%d",reason);
             [self player_finishReasonUserExited];
            break;
        case IJKMPMovieFinishReasonPlaybackError:
            NSLog(@"播放状态改变了：现在是播放错误状态：%d",reason);
            [self player_finishReasonPlaybackError];            
            break;
        default:
            
            break;
    }
}

-(void)player_isPreparedToPlayDidChange_event:(NSNotification*)notification{
    NSLog(@"player_isPreparedToPlayDidChange_event");
    if (self.mainStateDelegate&&[self.mainStateDelegate respondsToSelector:@selector(player_isPreparedToPlayDidChange_event:)]) {
        [self.mainStateDelegate player_isPreparedToPlayDidChange_event:notification];
    }
}

-(void)player_playBackStateDidChange_event:(NSNotification*)notification{
    switch (_player.playbackState) {
        case IJKMPMoviePlaybackStateStopped:
             NSLog(@"播放器的播放状态变了，现在是停止状态:%d",(int)_player.playbackState);
            [self player_playbackStateStopped];
            break;
        case IJKMPMoviePlaybackStatePlaying:
            NSLog(@"播放器的播放状态变了，现在是播放状态:%d",(int)_player.playbackState);
            
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(player_playbackStatePlaying) object:nil];
            [self performSelector:@selector(player_playbackStatePlaying) withObject:nil afterDelay:0.3];
            break;
        case IJKMPMoviePlaybackStatePaused:
            NSLog(@"播放器的播放状态变了，现在是暂停状态:%d",(int)self.player.playbackState);
            [self player_playbackStatePaused];
           
            break;
        case IJKMPMoviePlaybackStateInterrupted:
            NSLog(@"播放器的播放状态变了，现在是中断状态:%d",(int)self.player.playbackState);
            [self player_playbackStateInterrupted];
            break;
        case IJKMPMoviePlaybackStateSeekingForward:
            NSLog(@"播放器的播放状态变了，现在是向前拖动状态:%d",(int)self.player.playbackState);
            [self player_playbackStateSeekingForward];
            break;
        case IJKMPMoviePlaybackStateSeekingBackward:
            NSLog(@"播放器的播放状态变了，现在是向后拖动状态：%d",(int)self.player.playbackState);
            [self player_playbackStateSeekingBackward];
            break;
        default:
            NSLog(@"播放器的播放状态变了，现在是未知状态：%d",(int)self.player.playbackState);
            break;
    }
}

-(void)player_seekCompleted_event{
    NSLog(@"player_seekCompleted_event");
}

-(void)player_netWorkStateChange_event:(NSNotification*)notification{
    NSLog(@"player_netWorkStateChange_event");
    if (self.mainStateDelegate&&[self.mainStateDelegate respondsToSelector:@selector(player_netWorkStateChange_event:)]) {
        [self.mainStateDelegate player_netWorkStateChange_event:notification];
    }
}

-(void)player_resignActive_event:(NSNotification*)notification{
    NSLog(@"player_resignActive_event");
    if (self.mainStateDelegate&&[self.mainStateDelegate respondsToSelector:@selector(player_resignActive_event:)]) {
        [self.mainStateDelegate player_resignActive_event:notification];
    }
    if (self.player)if([self.player isPlaying])_playerIsPlayingBeforeEnterforeground = true;
}

-(void)player_becomeActive_event:(NSNotification*)notification{
    NSLog(@"player_becomeActive_event");
    if (self.mainStateDelegate&&[self.mainStateDelegate respondsToSelector:@selector(player_becomeActive_event:)]) {
        [self.mainStateDelegate player_becomeActive_event:notification];
    }
    if (self.player)if(![self.player isPlaying]&&_playerIsPlayingBeforeEnterforeground){
        _playerIsPlayingBeforeEnterforeground = false;
        if ([self becomeAlivePlayBossValve]) {
            [self.player play];
        }
    }
}


-(BOOL)becomeAlivePlayBossValve{
    return true;
}

#pragma mark -- StateDidChange sub state

-(void)player_loadStatePlaythroughOK{
    NSLog(@"player_loadStatePlaythroughOK");
}

-(void)player_loadStatePlaystalled{
    NSLog(@"player_loadStatePlaystalled");
}

//在playable来执行判断

-(void)player_loadStatePlayable{
    NSLog(@"player_loadStatePlayable");
}

-(void)player_loadStateUnknown{
    NSLog(@"player_loadStatePlayable");
}


#pragma mark -- PlayBackFinish sub state

-(void)player_finishReasonPlaybackEnded{
    NSLog(@"player_finishReasonPlaybackEnded");
    if (self.finishDelegate&&[self.finishDelegate respondsToSelector:@selector(player_finishReasonPlaybackEnded)]) {
        [self.finishDelegate player_finishReasonPlaybackEnded];
    }
    if (self.playOptions.isCirclePlay) {
        [self.player play];
    }
}

-(void)player_finishReasonUserExited{
    NSLog(@"player_finishReasonUserExited");
    if (self.finishDelegate&&[self.finishDelegate respondsToSelector:@selector(player_finishReasonUserExited)]) {
        [self.finishDelegate player_finishReasonUserExited];
    }
}

-(void)player_finishReasonPlaybackError{
    NSLog(@"player_finishReasonPlaybackError");
    if (self.finishDelegate&&[self.finishDelegate respondsToSelector:@selector(player_finishReasonPlaybackError)]) {
        [self.finishDelegate player_finishReasonPlaybackError];
    }
}


#pragma mark -- PlayBackStateChanged sub state


-(void)player_playbackStateStopped{
    NSLog(@"player_playbackStateStopped");
    if (self.stateDelegate&&[self.stateDelegate respondsToSelector:@selector(ph_PlayerWillStop)]) {
        [self.stateDelegate ph_PlayerWillStop];
    }
    if (self.allStateDelegate&&[self.allStateDelegate respondsToSelector:@selector(player_playbackStateStopped)]) {
        [self.allStateDelegate player_playbackStateStopped];
    }
}

-(void)player_playbackStatePlaying{
    NSLog(@"player_playbackStatePlaying");
    if (self.stateDelegate&&[self.stateDelegate respondsToSelector:@selector(ph_PlayerWillPlay)]) {
        [self.stateDelegate ph_PlayerWillPlay];
    }
    if (self.allStateDelegate&&[self.allStateDelegate respondsToSelector:@selector(player_playbackStatePlaying)]) {
        [self.allStateDelegate player_playbackStatePlaying];
    }
}
-(void)player_playbackStatePaused{
    NSLog(@"player_playbackStatePaused");
    if (self.stateDelegate&&[self.stateDelegate respondsToSelector:@selector(ph_PlayerWillPause)]) {
        [self.stateDelegate ph_PlayerWillPause];
    }
    if (self.allStateDelegate&&[self.allStateDelegate respondsToSelector:@selector(player_playbackStatePaused)]) {
        [self.allStateDelegate player_playbackStatePaused];
    }
}
-(void)player_playbackStateInterrupted{
    NSLog(@"player_playbackStateInterrupted");
    if (self.allStateDelegate&&[self.allStateDelegate respondsToSelector:@selector(player_playbackStateInterrupted)]) {
        [self.allStateDelegate player_playbackStateInterrupted];
    }
}
-(void)player_playbackStateSeekingForward{
    NSLog(@"player_playbackStateSeekingForward");
    if (self.allStateDelegate&&[self.allStateDelegate respondsToSelector:@selector(player_playbackStateSeekingForward)]) {
        [self.allStateDelegate player_playbackStateSeekingForward];
    }
}
-(void)player_playbackStateSeekingBackward{
    NSLog(@"player_playbackStateSeekingBackward");
    if (self.allStateDelegate&&[self.allStateDelegate respondsToSelector:@selector(player_playbackStateSeekingBackward)]) {
        [self.allStateDelegate player_playbackStateSeekingBackward];
    }
}

#pragma mark ----------- Noticification  END



#pragma mark -- Play state



-(void)play{
    if (self.player&&![self.player isPlaying]) {
         [self.player play];
    }
}



-(void)pause{
    if (self.player&&[self.player isPlaying]) {
        _playerIsPlayingBeforeEnterforeground = false;
        [self.player pause];
    }
}

-(void)destoryPlayer{
    if (self.player) {
        if (self.stateDelegate&&[self.stateDelegate respondsToSelector:@selector(ph_PlayerWillDestory)]) {
            [self.stateDelegate ph_PlayerWillDestory];
        }
        [self uninstallNoticification];
        [self.player shutdown];
        [self.player.view removeFromSuperview];
        self.player = nil;
    }
}


-(void)layoutSubviews{
    [super layoutSubviews];
    self.player.view.frame = self.bounds;
}



/**
 Set Default FFPlayer Options
 @return 返回默认的Options
 */
-(IJKFFOptions *)getDefaultFFPlayerOptions{
    //IJKplayer属性参数设置
    IJKFFOptions *options = [IJKFFOptions optionsByDefault];
    [options setOptionIntValue:IJK_AVDISCARD_DEFAULT forKey:@"skip_frame" ofCategory:kIJKFFOptionCategoryCodec];
    [options setOptionIntValue:IJK_AVDISCARD_DEFAULT forKey:@"skip_loop_filter" ofCategory:kIJKFFOptionCategoryCodec];
    [options setOptionIntValue:0 forKey:@"videotoolbox" ofCategory:kIJKFFOptionCategoryPlayer];
    [options setOptionIntValue:60 forKey:@"max-fps" ofCategory:kIJKFFOptionCategoryPlayer];
    [options setPlayerOptionIntValue:256 forKey:@"vol"];
    return options;
}


-(NSString *)getNetChangeNoticificationName{
    return @"netWorkChangeEventNotification";
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
