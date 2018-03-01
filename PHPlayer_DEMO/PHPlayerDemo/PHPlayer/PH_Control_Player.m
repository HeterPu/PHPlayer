//  PHPlayer
//  Created by Peter Hu on 2018/2/24.
//  Copyright © 2018年 Peter Hu. All rights reserved.
//  Github:https://github.com/HeterPu/PHPlayer , like it,star it.


#import "PH_Control_Player.h"

#define K_PHPLAYER_ENDTIME_OFFSET  0.3


typedef NS_ENUM(NSUInteger, PHPlayer_Gesture_Direction) {
    PHPlayer_Gesture_DirectionLeftOrRight,
    PHPlayer_Gesture_DirectionUpOrDown,
    PHPlayer_Gesture_DirectionNone
};



@interface PH_Control_Player()

@property (assign, nonatomic) PHPlayer_Gesture_Direction direction;

@property (assign, nonatomic) CGPoint startPoint;

@property (assign, nonatomic) CGFloat startVB;

@property (strong, nonatomic) MPVolumeView *volumeView;//控制音量的view

@property (strong, nonatomic) UISlider* volumeViewSlider;//控制音量

@property (assign, nonatomic) CGFloat currentRate;//当期视频播放的进度

@property (assign, nonatomic) CGFloat startVideoRate;

@property(nonatomic,strong) UITapGestureRecognizer *tapGesture;


/**
 第一次设置播放器区间开始时间
 */
@property(nonatomic,assign)BOOL isNotFirstSetCurrentTime;

/**
 是否从开始播放的标记
 */
@property(nonatomic,assign)BOOL isPlayFromStart;

/**
 设置播放器区间时,是否播放器暂停
 */
@property(nonatomic,assign)BOOL isStopGCDTimer;


/**
 区间定时器
 */
@property(nonatomic,strong)NSTimer *mQvJianTimer;

@end

@implementation PH_Control_Player


-(void)configuration{
    [super configuration];
    _controlFunction = PHControlPlayer_function_Pan_function_All;
    
    // 安装点击手势
    [self installGesture];
}


-(void)installGesture{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(player_tapClick:)];
    tap.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tap];
    _tapGesture = tap;
}

-(void)player_tapClick:(id)sender{

}


-(void)layoutSubviews{
    [super layoutSubviews];
    self.volumeView.frame = self.bounds;
}


//触摸开始
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    //获取触摸开始的坐标
    UITouch *touch = [touches anyObject];
    CGPoint currentP = [touch locationInView:self];
    [self touchesBeganWithPoint:currentP];
}

//触摸结束
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint currentP = [touch locationInView:self];
    [self touchesEndWithPoint:currentP];
    _tapGesture.enabled = true;
}

//移动
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint currentP = [touch locationInView:self];
    [self touchesMoveWithPoint:currentP];
}




/*************************************************************************/
- (void)touchesBeganWithPoint:(CGPoint)point {
    //记录首次触摸坐标
    self.startPoint = point;
    //检测用户是触摸屏幕的左边还是右边，以此判断用户是要调节音量还是亮度，左边是亮度，右边是音量
    if (self.startPoint.x <= self.frame.size.width / 2.0) {
        //亮度
        self.startVB = [UIScreen mainScreen].brightness;
    } else {
        //音/量
        self.startVB = self.volumeViewSlider.value;
    }
    //方向置为无
    self.direction = PHPlayer_Gesture_DirectionNone ;
    //记录当前视频播放的进度
    
    // 通过self.player.duration来判断是普通视频还是直播流，直播不支持前进后退
    if (!isnan(self.player.duration)) {
        self.startVideoRate = self.player.currentPlaybackTime / self.player.duration;
    }else{
         self.controlFunction = self.controlFunction & (~PHControlPlayer_function_Seek_back_forward_Change);
    }
   
}

#pragma mark - 结束触摸
- (void)touchesEndWithPoint:(CGPoint)point {
    if (self.direction == PHPlayer_Gesture_DirectionLeftOrRight) {
        if (self.controlFunction & PHControlPlayer_function_Seek_back_forward_Change) {
            NSTimeInterval currentTime = self.player.duration * self.currentRate;
            self.player.currentPlaybackTime = currentTime;
            NSLog(@" START From %f , GO TO %f",self.startVideoRate * self.player.duration,currentTime);
        }
    }
}



#pragma mark - 拖动
- (void)touchesMoveWithPoint:(CGPoint)point {
    
    
    //得出手指在Button上移动的距离
    CGPoint panPoint = CGPointMake(point.x - self.startPoint.x, point.y - self.startPoint.y);
    
    // 解决点击和滑动的手势冲突
    if ((fabs(panPoint.x) > 30) || (fabs(panPoint.y) > 30)) {
        self.tapGesture.enabled = false;
    }
    
    //分析出用户滑动的方向
    if (self.direction == PHPlayer_Gesture_DirectionNone) {
        if (panPoint.x >= 30 || panPoint.x <= -30) {
            //进度
            self.direction = PHPlayer_Gesture_DirectionLeftOrRight;
        } else if (panPoint.y >= 30 || panPoint.y <= -30) {
            //音量和亮度
            self.direction = PHPlayer_Gesture_DirectionUpOrDown;
        }
    }
    
    if (self.direction == PHPlayer_Gesture_DirectionNone) {
        return;
    } else if (self.direction == PHPlayer_Gesture_DirectionUpOrDown) {
        //音量和亮度
        if (self.startPoint.x <= self.frame.size.width / 2.0) {
            //调节亮度
            // 支不支持亮度调节
             if (self.controlFunction & PHControlPlayer_function_BrightChange){
            if (panPoint.y < 0) {
                //增加亮度
                [[UIScreen mainScreen] setBrightness:self.startVB + (-panPoint.y / 30.0 / 10)];
            } else {
                //减少亮度
                [[UIScreen mainScreen] setBrightness:self.startVB - (panPoint.y / 30.0 / 10)];
            }
        }
            
        } else {
            //音量
            // 支不支持音量调节
            if (self.controlFunction & PHControlPlayer_function_VolumnChange){
            if (panPoint.y < 0) {
                //增大音量
                [self.volumeViewSlider setValue:self.startVB + (-panPoint.y / 30.0 / 10) animated:YES];
                if (self.startVB + (-panPoint.y / 30 / 10) - self.volumeViewSlider.value >= 0.1) {
                    [self.volumeViewSlider setValue:0.1 animated:NO];
                    [self.volumeViewSlider setValue:self.startVB + (-panPoint.y / 30.0 / 10) animated:YES];
                }
                
            } else {
                //减少音量
                [self.volumeViewSlider setValue:self.startVB - (panPoint.y / 30.0 / 10) animated:YES];
            }
          }
        }
    } else if (self.direction == PHPlayer_Gesture_DirectionLeftOrRight ) {
        //进度
        CGFloat rate = self.startVideoRate + (panPoint.x / 30.0 / 20.0);
        if (rate > 1) {
            rate = 1;
        } else if (rate < 0) {
            rate = 0;
        }
        self.currentRate = rate;
    }
}



- (MPVolumeView *)volumeView {
    if (_volumeView == nil) {
        _volumeView  = [[MPVolumeView alloc] init];
        [_volumeView sizeToFit];
        for (UIView *view in [_volumeView subviews]){
            if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
                self.volumeViewSlider = (UISlider*)view;
                break;
            }
        }
    }
    return _volumeView;
}


-(void)player_playbackStatePlaying{
    [super player_playbackStatePlaying];
    if (self.startPlayTime) {
        CGFloat startTime = self.startPlayTime.floatValue;
        CGFloat endTime = self.endPlayTime.floatValue;
        
        
        if (startTime > 0) {
            
            if (((self.player.currentPlaybackTime < startTime)&&(!_isNotFirstSetCurrentTime))||_isPlayFromStart){
                _isNotFirstSetCurrentTime = true;
                _isPlayFromStart = false;
                self.player.currentPlaybackTime = startTime;
                return;
            }
            
            // 结束时间不可超过视频总时长，留0.3时间防止视频播放完,完成后会重新播放，逻辑会变化
            if (((endTime + K_PHPLAYER_ENDTIME_OFFSET) > self.player.duration)||(endTime < 0))endTime = self.player.duration - K_PHPLAYER_ENDTIME_OFFSET;
            CGFloat offsetTime = endTime - startTime + (startTime - self.player.currentPlaybackTime);
            if(_mQvJianTimer){
                [_mQvJianTimer invalidate];
                _mQvJianTimer = nil;
            }
            _mQvJianTimer = [NSTimer scheduledTimerWithTimeInterval:offsetTime target:self selector:@selector(startSeekPlayer) userInfo:nil repeats:NO];
        }else{
            
            if (_isPlayFromStart) {
                _isPlayFromStart = false;
                self.player.currentPlaybackTime = 0.0;
                return;
            }
            // 结束时间不可超过视频总时长，留0.3时间防止视频播放完,完成后会重新播放，逻辑会变化
            if (((endTime + K_PHPLAYER_ENDTIME_OFFSET) > self.player.duration)||(endTime < 0))endTime = self.player.duration - K_PHPLAYER_ENDTIME_OFFSET;
            CGFloat offsetTime = endTime - startTime + (startTime - self.player.currentPlaybackTime);
            if(_mQvJianTimer){
                [_mQvJianTimer invalidate];
                _mQvJianTimer = nil;
            }
            _mQvJianTimer = [NSTimer scheduledTimerWithTimeInterval:offsetTime target:self selector:@selector(startSeekPlayer) userInfo:nil repeats:NO];
        }
    }
}


-(void)player_playbackStatePaused{
    [super player_playbackStatePaused];
    [_mQvJianTimer invalidate];
    _mQvJianTimer = nil;
}


-(void)startSeekPlayer{
     CGFloat startTime = self.startPlayTime.floatValue;
     self.player.currentPlaybackTime = startTime;
}


-(void)destoryPlayer{
    [super destoryPlayer];
    if (_mQvJianTimer) {
        [_mQvJianTimer invalidate];
        _mQvJianTimer = nil;
    }
}

-(void)playFromStart{
    _isPlayFromStart = true;
}


@end
