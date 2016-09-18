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
//拖动进度时显示的时间
@property(nonatomic,strong)UIImageView *timeimg;
@property(nonatomic,strong)UILabel *timelab;
//控件的隐现
//@property(nonatomic,assign)BOOL btnshow;
//@property(nonatomic,assign)BOOL isshow;
@end
@implementation ZSPlayer

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self createMoviePlayer];
        [self setupUI];
        [self addNotification];
    }
    NSURLCache *urlcache = [[NSURLCache alloc]initWithMemoryCapacity:4*1024*1024 diskCapacity:20*1024*1024 diskPath:nil];
    [NSURLCache setSharedURLCache:urlcache];
    return self;
}

-(void)setPlayurl:(NSURL *)playurl{
    _playurl = playurl;
    self.movieplayer.contentURL = playurl;
}


//添加播放器
-(void)createMoviePlayer{
    self.movieplayer = [[MPMoviePlayerController alloc]initWithContentURL:[NSURL URLWithString:@""]];
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
    
    UIButton *fullbtn = [[UIButton alloc]initWithFrame:CGRectMake(myW - 40, myH - 30, 30, 30)];
    [fullbtn setTitle:@"全屏" forState:UIControlStateNormal];
    fullbtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [fullbtn addTarget:self action:@selector(fullClick) forControlEvents:UIControlEventTouchUpInside];
    self.fullbtn = fullbtn;
    [self.coverView addSubview:fullbtn];
    
    self.playbtn = [[UIButton alloc]initWithFrame:CGRectMake(10, myH - 30, 30, 30)];
    [_playbtn setTitle:@"暂停" forState:UIControlStateNormal];
    _playbtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [_playbtn addTarget:self action:@selector(playorpauseBtnclick) forControlEvents:UIControlEventTouchUpInside];
    [self.coverView addSubview:_playbtn];
    
    self.timedurtion = [[UILabel alloc]initWithFrame:CGRectMake(myW - 80, myH - 30, 40, 30)];
    self.timedurtion.font = [UIFont systemFontOfSize:12];
    self.timedurtion.textColor = [UIColor whiteColor];
    self.timedurtion.text = @"00:00";
    [self.coverView addSubview:_timedurtion];
    self.currenttime.textAlignment = NSTextAlignmentRight;
    self.currenttime = [[UILabel alloc]initWithFrame:CGRectMake(40, myH - 30, 40, 30)];
    self.currenttime.font = [UIFont systemFontOfSize:12];
    self.currenttime.text = @"00:00";
    self.currenttime.textColor = [UIColor whiteColor];
    [self.coverView addSubview:_currenttime];
    
    self.playableProgress = [[UISlider alloc]initWithFrame:CGRectMake(90, myH - 30, myW - 180, 30)];
    self.playableProgress.minimumTrackTintColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1];
    self.playableProgress.maximumTrackTintColor = [UIColor colorWithRed:241/255.0 green:241/255.0 blue:241/255.0 alpha:0.5];
    UIImage *thumbImageEmp = [[UIImage alloc]init];
    [self.playableProgress setThumbImage:thumbImageEmp forState:UIControlStateNormal];
    [self.playableProgress setThumbImage:thumbImageEmp forState:UIControlStateSelected];
    self.playableProgress.userInteractionEnabled = NO;
    [self.coverView addSubview:self.playableProgress];

    self.progress =[[UISlider alloc]initWithFrame:CGRectMake(90, myH - 30, myW - 180, 30)];
    self.progress.minimumTrackTintColor = [UIColor whiteColor];
    self.progress.maximumTrackTintColor = [UIColor clearColor];
    UIImage *thumbImage0 = [UIImage imageNamed:@"Oval 1"];
    [self.progress setThumbImage:thumbImage0 forState:UIControlStateNormal];
    [self.progress setThumbImage:thumbImage0 forState:UIControlStateSelected];
    [self.progress addTarget:self action:@selector(valueChange:other:) forControlEvents:UIControlEventValueChanged];
    [self.coverView addSubview:self.progress];
    
    //  timeImage
    self.timeimg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"silder"]];
    self.timeimg.frame = CGRectMake(0, 0, 30, 12);
    self.timeimg.hidden = YES;
    [self.coverView addSubview:self.timeimg];
    
    self.timelab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 30, 12)];
    self.timelab.font = [UIFont systemFontOfSize:8];
    self.timelab.textAlignment = NSTextAlignmentCenter;
    [self.timeimg addSubview:self.timelab];

}


//拖动控件
- (void)valueChange:(UISlider *)progress other:(UIEvent *)event {
    NSTimeInterval currenttime;
    NSInteger minit;
    NSInteger second;
    UITouch *touch = [[event allTouches] anyObject];
    switch (touch.phase) {
        case UITouchPhaseBegan:
            [self.timer invalidate];
            break;
        case UITouchPhaseMoved:
            currenttime = self.progress.value * self.movieplayer.duration;
            minit = currenttime / 60;
            second = currenttime - 60 * minit;
            self.currenttime.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)minit, (long)second];
            self.timeimg.hidden = NO;
            self.timeimg.center = CGPointMake((myW - 190)* self.progress.value + 96, self.progress.frame.origin.y - 15) ;
            self.timelab.text = self.currenttime.text;
            break;
        case UITouchPhaseEnded:
            self.timeimg.hidden = YES;
            self.movieplayer.currentPlaybackTime = self.progress.value * self.movieplayer.duration;
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(refreshCurrentTime) userInfo:nil repeats:YES];
            break;
        default:
            break;
    }
}

//播放暂停
-(void)playorpauseBtnclick{
    if (_movieplayer.playbackState == MPMoviePlaybackStatePlaying) {
        [_movieplayer pause];
        [_playbtn setTitle:@"播放" forState:UIControlStateNormal];
        return;
    }
    if (_movieplayer.playbackState == MPMoviePlaybackStatePaused || _movieplayer.playbackState == MPMoviePlaybackStateStopped) {
        [_movieplayer play];
        [_playbtn setTitle:@"暂停" forState:UIControlStateNormal];
        return;
    }
}

//全屏
-(void)fullClick{
    NSLog(@"全屏");
//    if ([UIDevice currentDevice].orientation != UIDeviceOrientationPortrait) {
//        NSNumber *num = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
//        [[UIDevice currentDevice] setValue:num forKey:@"orientation"];
//    }else{
//        NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
//        [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
//    }
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
    self.timedurtion.frame = CGRectMake(myW - 80, myH - 30, 40, 30);
    self.currenttime.frame = CGRectMake(40, myH - 30, 40, 30);
    self.progress.frame = CGRectMake(90, myH - 23, myW - 180, 15);
    self.playableProgress.frame = CGRectMake(90, myH - 23, myW - 180, 15);
    self.fullbtn.frame = CGRectMake(myW - 40, myH - 30, 30, 30);
    self.playbtn.frame = CGRectMake(10, myH - 30, 30, 30);
    [self.coverView layoutSubviews];
    [self layoutSubviews];
}

//添加通知
-(void)addNotification{
    NSNotificationCenter *notificationCenter=[NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(DurationAvailable) name:MPMovieDurationAvailableNotification object:self.movieplayer];
    [notificationCenter addObserver:self selector:@selector(mediaPlayerPlaybackFinished) name:MPMoviePlayerPlaybackDidFinishNotification object:self.movieplayer];
}

//获取总时长
- (void)DurationAvailable {
    NSInteger minit = self.movieplayer.duration / 60;
    NSInteger second = self.movieplayer.duration - 60 * minit;
    self.timedurtion.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)minit, (long)second];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(refreshCurrentTime) userInfo:nil repeats:YES];
}

//获取当前时间及下载播放进度
- (void)refreshCurrentTime {
    NSInteger minit = self.movieplayer.currentPlaybackTime / 60;
    NSInteger second = self.movieplayer.currentPlaybackTime - 60 * minit;
    self.currenttime.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)minit, (long)second];
    self.progress.value = self.movieplayer.currentPlaybackTime / self.movieplayer.duration;
    self.playableProgress.value = self.movieplayer.playableDuration / self.movieplayer.duration;
    
}

//播放完
-(void)mediaPlayerPlaybackFinished{
    [self.timer invalidate];
    if (self.finishBlock) {
        self.finishBlock();
    }
}

//响应超出控件的按钮点击事件
-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView *view = [super hitTest:point withEvent:event];
    if (view == nil) {
        CGPoint tempoint = [self.fullbtn convertPoint:point fromView:self];
        CGPoint sliderpoint = [self.progress convertPoint:point fromView:self];
        if (CGRectContainsPoint(self.fullbtn.bounds, tempoint)) {
            view = self.fullbtn;
        }
        if (CGRectContainsPoint(self.progress.bounds, sliderpoint)) {
            view = self.progress;
        }
    }
    return view;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
