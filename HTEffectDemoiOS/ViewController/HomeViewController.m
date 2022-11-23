//
//  HomeViewController.m
//  HTEffectDemoiOS
//
//  Created by N17 on 2022/5/6.
//  Copyright © 2022 Tillusory Tech. All rights reserved.
//

#import "HomeViewController.h"
#import "CameraViewController.h"
#import <Masonry/Masonry.h>

@interface HomeViewController ()

@property(nonatomic,strong)UIButton *startBtn;

@end

@implementation HomeViewController

- (UIButton *)startBtn{
    if (!_startBtn) {
        _startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_startBtn setBackgroundImage:[UIImage imageNamed:@"btn_kuaimen.png"] forState:UIControlStateNormal];
        [_startBtn setTitle:@"进入" forState:UIControlStateNormal];
        [_startBtn addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startBtn;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:233.0/255 green:240.0/255 blue:240.0/255 alpha:1.0];
    [self.view addSubview:self.startBtn];
    [self.startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-100);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(80);
    }];
    
}

- (void)onClick:(UIButton *)sender{
    CameraViewController *CVC = [[CameraViewController alloc] init];
    CVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:CVC animated:YES completion:nil];
}

@end
