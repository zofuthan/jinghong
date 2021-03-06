//
//  JHAppDelegate.h
//  精弘论坛
//
//  Created by Dikey on 8/27/14.
//  Copyright (c) 2014 dikey. All rights reserved.
//
//
//


#import <UIKit/UIKit.h>

@interface JHAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end


/*
 Going On:
 缓存的具体实现
 1 用NSMutableDicionary 负责保存路径名字（key）和缓存（value）
   保存至内存
 2 当内存不足或者有新数据的时候保存内存缓存至闪存
 3 用NSFileManager管理路径
 
 
 
 1.1 下拉刷新，有网络的时候测试 上拉加载更多：
 1.2 用固化实现缓存（固化所有论坛列表），后续缓存帖子列表

 
 Todo：
 
 1.3 发新帖子，发回复，是怎么传的数据？更复杂的语音，图片功能如何实现？
 1.4 左边和右边界面
*/