//
//  XQWechatHeader.h
//  JiongZhi
//
//  Created by WXQ on 2019/8/28.
//  Copyright © 2019 cn.test.www. All rights reserved.
//

#ifndef XQWechatHeader_h
#define XQWechatHeader_h

#import <Foundation/Foundation.h>


/**
 请求发送场景

 - XQWXSceneSession: 聊天界面
 - XQWXSceneTimeline: 朋友圈
 - XQWXSceneFavorite: 收藏
 - XQWXSceneSpecifiedSession: 指定联系人
 */
typedef NS_ENUM(NSUInteger, XQWXScene) {
    XQWXSceneSession          = 0,
    XQWXSceneTimeline         = 1,
    XQWXSceneFavorite         = 2,
    XQWXSceneSpecifiedSession = 3,
};



#endif /* XQWechatHeader_h */
