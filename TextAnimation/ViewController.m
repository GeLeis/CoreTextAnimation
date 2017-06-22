//
//  ViewController.m
//  TextAnimation
//
//  Created by pz on 2017/6/22.
//  Copyright © 2017年 anve. All rights reserved.
//

#import "ViewController.h"
#import "UIView+Common.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view addText:@"青青河边草" frame:CGRectMake(30, 30, 0, 0)];
}

@end
