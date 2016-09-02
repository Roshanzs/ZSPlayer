//
//  ViewController.m
//  ZSPlayer
//
//  Created by Tony on 16/8/31.
//  Copyright © 2016年 Tony. All rights reserved.
//

#import "ViewController.h"
#import "ZSPlayer.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    ZSPlayer *play = [[ZSPlayer alloc]initWithFrame:CGRectMake(0, 0, 375, 180)];
    play.playurl = [NSURL URLWithString:@"http://devimages.apple.com/iphone/samples/bipbop/gear1/prog_index.m3u8"];
    play.finishBlock = ^{
        NSLog(@"播放完毕");
    };
    [self.view addSubview:play];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
