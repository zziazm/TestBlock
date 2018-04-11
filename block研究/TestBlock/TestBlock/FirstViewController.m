//
//  FirstViewController.m
//  TestBlock
//
//  Created by 赵铭 on 2018/4/10.
//  Copyright © 2018年 zm. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    __block int num = 1;
    printf("输出前 num == %p\n", &num);
    void (^aBlock) (void) = ^{
        num ++;
        printf("输出中 num == %p\n", &num);
    };
    aBlock();
    printf("输出后 num == %p\n", &num);
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
