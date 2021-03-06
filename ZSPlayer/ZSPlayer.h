//
//  ZSPlayer.h
//  ZSVideoPlayer
//
//  Created by Tony on 16/8/31.
//  Copyright © 2016年 Tony. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZSPlayer : UIView
//视屏播放地址
@property(nonatomic,copy)NSURL *playurl;
//播放暂停按钮
@property(nonatomic,strong)UIButton *playbtn;
//视屏播放完回调的block
@property(nonatomic,copy)void(^finishBlock)();
@end
