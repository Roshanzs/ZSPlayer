//
//  ZSPlayer.m
//  ZSVideoPlayer
//
//  Created by Tony on 16/8/31.
//  Copyright © 2016年 Tony. All rights reserved.
//

#import "ZSPlayer.h"
#import <MediaPlayer/MediaPlayer.h>

#define myH self.movieplayer.view.bounds.size.height
#define myW self.movieplayer.view.bounds.size.width
@interface ZSPlayer()
@property(nonatomic,strong)MPMoviePlayerController *movieplayer;
@property(nonatomic,strong)UIView *coverView;
@property(nonatomic,assign)BOOL isfull;
//全屏按钮
@property(nonatomic,strong)UIButton *fullbtn;
//播放暂停按钮
@property(nonatomic,strong)UIButton *playbtn;
//播放时长
@property(nonatomic,strong)UILabel *timedurtion;
//当前播放时间
@property(nonatomic,strong)UILabel *currenttime;
//定时器
@property(nonatomic,strong)NSTimer *timer;
//播放的进度
@property(nonatomic,strong)UISlider *progress;
//已下载的进度
@property(nonatomic,strong)UISlider *playableProgress;
@end
@implementation ZSPlayer

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self createMoviePlayer];
        [self setupUI];
        [self addNotification];
    }
    return self;
}

//添加播放器
-(void)createMoviePlayer{
    self.movieplayer = [[MPMoviePlayerController alloc]initWithContentURL:[NSURL URLWithString:@"http://devimages.apple.com/iphone/samples/bipbop/gear1/prog_index.m3u8"]];
    self.movieplayer.view.frame = self.bounds;
    self.movieplayer.controlStyle = MPMovieControlStyleNone;
    self.movieplayer.scalingMode = MPMovieScalingModeFill;
    [self addSubview:self.movieplayer.view];
    self.movieplayer.view.userInteractionEnabled = NO;
    [self.movieplayer prepareToPlay];
}


//设置UI
-(void)setupUI{
    UIView *coverView = [[UIView alloc]initWithFrame:self.bounds];
    coverView.backgroundColor = [UIColor clearColor];
    self.coverView = coverView;
    [self addSubview:coverView];
    
    UIButton *fullbtn = [[UIButton alloc]initWithFrame:CGRectMake(myW - 60, myH - 40, 50, 30)];
    [fullbtn setTitle:@"全屏" forState:UIControlStateNormal];
    [fullbtn addTarget:self action:@selector(fullClick) forControlEvents:UIControlEventTouchUpInside];
    self.fullbtn = fullbtn;
    [self.coverView addSubview:fullbtn];
    
    self.playbtn = [[UIButton alloc]initWithFrame:CGRectMake(10, myH - 40, 50, 30)];
    [_playbtn setTitle:@"暂停" forState:UIControlStateNormal];
    [_playbtn addTarget:self action:@selector(playorpauseBtnclick) forControlEvents:UIControlEventTouchUpInside];
    [self.coverView addSubview:_playbtn];
    
    self.timedurtion = [[UILabel alloc]initWithFrame:CGRectMake(myW - 140, myH - 40, 80, 30)];
    self.timedurtion.textColor = [UIColor whiteColor];
    [self.coverView addSubview:_timedurtion];
    
    self.currenttime = [[UILabel alloc]initWithFrame:CGRectMake(myW - 200, myH - 40, 60, 30)];
    self.currenttime.textColor = [UIColor whiteColor];
    [self.coverView addSubview:_currenttime];

}

//播放暂停
-(void)playorpauseBtnclick{
    if (_movieplayer.playbackState == MPMoviePlaybackStatePlaying) {
        [_movieplayer pause];
        [_playbtn setTitle:@"播放" forState:UIControlStateNormal];
        return;
    }
    if (_movieplayer.playbackState == MPMoviePlaybackStatePaused) {
        [_movieplayer play];
        [_playbtn setTitle:@"暂停" forState:UIControlStateNormal];
        return;
    }
}

//全屏
-(void)fullClick{
    NSLog(@"全屏");
    if (!self.isfull) {
        self.movieplayer.view.transform = CGAffineTransformRotate(self.movieplayer.view.transform, M_PI_2);
        self.coverView.transform =  CGAffineTransformRotate(self.coverView.transform, M_PI_2);
        CGRect rect =  [UIApplication sharedApplication].keyWindow.frame;
        self.movieplayer.view.frame = rect;
        self.coverView.frame = rect;
        self.isfull = YES;
    }else{
        self.movieplayer.view.transform = CGAffineTransformRotate(self.movieplayer.view.transform, -M_PI_2);
        self.coverView.transform = CGAffineTransformRotate(self.coverView.transform, -M_PI_2);
        self.movieplayer.view.frame = self.bounds;
        self.coverView.frame = self.bounds;
        self.isfull = NO;
    }
    self.fullbtn.frame = CGRectMake(myW - 60, myH - 40, 50, 30);
    self.playbtn.frame = CGRectMake(10, myH - 40, 50, 30);
    [self.coverView layoutSubviews];
    [self layoutSubviews];
}

//添加通知
-(void)addNotification{
    NSNotificationCenter *notificationCenter=[NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(DurationAvailable) name:MPMovieDurationAvailableNotification object:self.movieplayer];
    [notificationCenter addObserver:self selector:@selector(mediaPlayerPlaybackFinished) name:MPMoviePlayerPlaybackDidFinishNotification object:self.movieplayer];
}

- (void)DurationAvailable {
    NSInteger minit = self.movieplayer.duration / 60;
    NSInteger second = self.movieplayer.duration - 60 * minit;
    self.timedurtion.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)minit, (long)second];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(refreshCurrentTime) userInfo:nil repeats:YES];
}

- (void)refreshCurrentTime {
    NSInteger minit = self.movieplayer.currentPlaybackTime / 60;
    NSInteger second = self.movieplayer.currentPlaybackTime - 60 * minit;
    self.currenttime.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)minit, (long)second];
    self.progress.value = self.movieplayer.currentPlaybackTime / self.movieplayer.duration;
    self.playableProgress.value = self.movieplayer.playableDuration / self.movieplayer.duration;
}



//响应超出控件的按钮点击事件
-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView *view = [super hitTest:point withEvent:event];
    if (view == nil) {
        CGPoint tempoint = [self.fullbtn convertPoint:point fromView:self];
        if (CGRectContainsPoint(self.fullbtn.bounds, tempoint)) {
            view = self.fullbtn;
        }
    }
    return view;
}




@end
