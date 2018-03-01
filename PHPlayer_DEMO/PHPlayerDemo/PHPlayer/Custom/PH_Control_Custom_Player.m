//  PHPlayer
//  Created by Peter Hu on 2018/2/24.
//  Copyright © 2018年 Peter Hu. All rights reserved.
//  Github:https://github.com/HeterPu/PHPlayer , like it,star it.


#import "PH_Control_Custom_Player.h"
#import "PHPlayerControl.h"

@interface PH_Control_Custom_Player()

@property(nonatomic,strong)PHPlayerControl *playerControl;

@end

@implementation PH_Control_Custom_Player


-(void)configuration{
    [super configuration];
    _playerControl = (PHPlayerControl *)[[[NSBundle mainBundle]loadNibNamed:@"PHPlayerControl" owner:nil options:nil]lastObject];
    // 当播放器类型为MPPlayer 不使用自定义视图 因为无法修改系统样式，索性不修改
    if (self.playOptions.playerType != PHPlayer_Type_MPPlayer) {
        [self addSubview:_playerControl];
    }
}

-(void)player_tapClick:(id)sender{
    [super player_tapClick:sender];
     self.playerControl.hidden = !self.playerControl.isHidden;
}


-(void)layoutSubviews{
    [super layoutSubviews];
     _playerControl.frame = self.bounds;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
