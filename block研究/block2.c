//
//  block2.c
//  TestBlock
//
//  Created by 赵铭 on 2018/4/10.
//  Copyright © 2018年 zm. All rights reserved.
//

#include <stdio.h>

int main () {
    __block int num = 1;
    printf("输出前 num == %p", &num);
    void (^aBlock) (void) = ^{
        num ++;
        printf("输出中 num == %p", &num);
    };
    aBlock();
    printf("输出后 num == %p", &num);
    return 0;
}
