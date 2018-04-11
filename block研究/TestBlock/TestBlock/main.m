//
//  main.m
//  TestBlock
//
//  Created by 赵铭 on 2018/4/10.
//  Copyright © 2018年 zm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
int main(int argc, char * argv[]) {
    @autoreleasepool {
        AVDepthData *d = nil;
        AVPlayer *p = [[AVPlayer alloc] init];
        
       __block NSObject *obj = [[NSObject alloc] init];
        NSLog(@"%@, %p", obj, &obj);
        void (^aBlock)(void) = ^{
            obj = nil;
            NSLog(@"%@, %p", obj, &obj);
        };
        aBlock();
        NSLog(@"%@, %p", obj, &obj);

        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
