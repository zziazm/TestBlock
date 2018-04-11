//
//  block1.c
//  TestBlock
//
//  Created by 赵铭 on 2018/4/10.
//  Copyright © 2018年 zm. All rights reserved.
//

//终端命令 下面的filename表示的是你要操作的文件名字
// $ gcc filename ：编译文件，可以在终端看下是否有编译错误
// $ ./a.out filename ：执行这个文件，可以在控制台看到有打印输出
// $ clang -rewrite-objc filename
#include <stdio.h>

int main () {
    int num = 1;
    void (^aBlock) (void) = ^{
        printf(" 输出 num == %d", num);
    };
    aBlock();
    return 0;
}
