//
//  main.m
//  TestBlock
//
//  Created by 赵铭 on 2018/4/10.
//  Copyright © 2018年 zm. All rights reserved.
//

#import <Foundation/Foundation.h>

int main(int argc, char * argv[]) {
    __block NSObject *obj = [[NSObject alloc] init];
    NSLog(@"%@, %p", obj, &obj);
    void (^aBlock)(void) = ^{
        obj = [[NSObject alloc] init];
        NSLog(@"%@, %p", obj, &obj);
    };
    aBlock();
    NSLog(@"%@, %p", obj, &obj);
    return 0;
}
