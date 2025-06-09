---
layout: '[layout]'
title: 项目总结系列 一 位置实时共享
date: 2016-11-17 00:13:34
tags: [“iOS”, “百度地图”, “位置实时共享”]
categories: "iOS"
---


> 从北京回来到今天已经整整三个月了，三个月没有更新简书了。回来找了一家新的公司上班，正好今天新项目打包测试了，找了点时间来总结一下最近项目中遇到的一些问题与心得。今天主要分享*位置实时共享*，其实之前也有时间，因为在新的公司很少加班。但是自己太懒了，所以……。

1.谈谈新公司    

> 进入公司才发现公司有个iOS大神和我是一个大学的 还是一个系的 还是同一级的，还有两个Android与我是一个专业的，这个行业真的小啊😄。公司不大，老板是个美籍华人（这应该是我们加班少的原因吧）。     
    
2.谈谈项目    

> 项目内容保密（签了协议的）……，还是谈技术吧。
1>即时通讯：我们用的是环信的，因为这不是主要的功能，使用就直接用的是环信的UI，就是官方demo里面的EaseUI，导入SDK就不用说了，我主要分享一下我们在里面添加的一个新的功能：*实时位置共享* 我们将这个功能添加在群聊里面的。主要逻辑：是通过环信群聊的透传消息实现的用的是百度地图。

* 通过百度地图定位 将自己的位置的经纬度放在透传消息的扩展信息中传出去

```
// 更新发送
- (void)sendCmdMessageWithType:(NSString *)type {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMCmdMessageBody *body = [[EMCmdMessageBody alloc] initWithAction:@"shareLocation"];
        _currentUserId = [[NSUserDefaults standardUserDefaults] objectForKey:@"eid"];
        NSDictionary *ext = @{@"latitude":@(_userStartLocation.location.coordinate.latitude),@"longitude":@(_userStartLocation.location.coordinate.longitude),@"type":type,_currentUserId:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_nickname"]};
        
        EMMessage *message = [[EMMessage alloc] initWithConversationID:self.conversationID
                                                                  from:_currentUserId
                                                                    to:self.conversationID
                                                                  body:body
                                                                   ext:ext];
        message.chatType = EMChatTypeGroupChat;
        [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:^(EMMessage *message, EMError *error) {
            if (error) {
                [CTHUD showText:@"位置更新失败"];
                // 去请求token
            }
        }];
    });
}
```
* 然后在解析透彻信息的解析位置信息

```
// 收到解析
- (void)didReceiveCmdMessages:(NSArray *)aCmdMessages {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (EMMessage *cmdMessage in aCmdMessages) {
            EMCmdMessageBody *body = (EMCmdMessageBody *)cmdMessage.body;
            // 判断是否是位置共享消息
            if ([body.action isEqualToString:@"shareLocation"]) {
                CLLocationCoordinate2D coordinate;
                coordinate.latitude = [[cmdMessage.ext objectForKey:@"latitude"] doubleValue];
                coordinate.longitude = [[cmdMessage.ext objectForKey:@"longitude"] doubleValue];
                NSString *nickName = [cmdMessage.ext objectForKey:cmdMessage.from];
                if ([[cmdMessage.ext objectForKey:@"type"] isEqualToString:@"update"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self updateOtherAnnotationWithLocation:coordinate UserNickName:nickName];
                    });
                }else if ([[cmdMessage.ext objectForKey:@"type"] isEqualToString:@"remove"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self removeOtherAnnotationWithUserNickName:nickName];
                    });
                }else if ([[cmdMessage.ext objectForKey:@"type"] isEqualToString:@"join"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self addMyAnnotationWithLocation:coordinate UserNickName:nickName];
                        [self sendCmdMessageWithType:@"feedback"];
                    });
                }else if ([[cmdMessage.ext objectForKey:@"type"] isEqualToString:@"feedback"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self addMyAnnotationWithLocation:coordinate UserNickName:nickName];
                    });
                }
            }
        }
    });
}
```
* 将所有收到的透传消的位置信息标识在地图上。

```
// 添加新的用户标注
- (void)addMyAnnotationWithLocation:(CLLocationCoordinate2D)coordinate UserNickName:(NSString *)nickName{
    BMKPointAnnotation *annotation = [[BMKPointAnnotation alloc]init];
    annotation.coordinate = coordinate;
    annotation.title = nickName;
    [_mapView addAnnotation:annotation];
    [_mapView selectAnnotation:annotation animated:YES];
    [_otherUserAnnotation addObject:annotation];
    [_otherUserNickName addObject:nickName];
    [_mapView showAnnotations:_otherUserAnnotation animated:YES];
    [_mapView setCenterCoordinate:coordinate animated:YES];
    while (!_mapView.zoomOut) {
    }
}
```
* 还需要通过传递者的传递的类型定该位置是新加入用户还是已经存在的用户

```
if ([[cmdMessage.ext objectForKey:@"type"] isEqualToString:@"update"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self updateOtherAnnotationWithLocation:coordinate UserNickName:nickName];
                    });
                }else if ([[cmdMessage.ext objectForKey:@"type"] isEqualToString:@"remove"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self removeOtherAnnotationWithUserNickName:nickName];
                    });
                }else if ([[cmdMessage.ext objectForKey:@"type"] isEqualToString:@"join"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self addMyAnnotationWithLocation:coordinate UserNickName:nickName];
                        [self sendCmdMessageWithType:@"feedback"];
                    });
                }else if ([[cmdMessage.ext objectForKey:@"type"] isEqualToString:@"feedback"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self addMyAnnotationWithLocation:coordinate UserNickName:nickName];
                    });
                }
```
* 新用户需要添加大头针，已经存在的用户只需要更新位置。

```
// 更新用户标注
- (void)updateOtherAnnotationWithLocation:(CLLocationCoordinate2D)coordinate UserNickName:(NSString *)nickName{
    for (BMKPointAnnotation *annotation in _otherUserAnnotation) {
        if ([annotation.title isEqualToString:nickName]) {
            annotation.coordinate = coordinate;
        }
    }
}
```

* 通过百度地图获得自己移动的距离 
      
```
BMKMapPoint point1 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(_userStartLocation.location.coordinate.latitude,_userStartLocation.location.coordinate.latitude));

BMKMapPoint point2 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(userLocation.location.coordinate.latitude,userLocation.location.coordinate.latitude));

 CLLocationDistance distance = BMKMetersBetweenMapPoints(point1,point2);
 ```
* 自己定义一个移动的精度，我们当时定的移动距离大于20米（distance>20）就发送一次位置更新。
* 最后当需要离开位置共享是也需要再发送一次信息，透传解析出，然后移除标识

```
// 删除用户标注
- (void)removeOtherAnnotationWithUserNickName:(NSString *)nickName{
    for (BMKPointAnnotation *annotation in _otherUserAnnotation) {
        if ([annotation.title isEqualToString:nickName]) {
            [_otherUserAnnotation removeObject:annotation];
            [_otherUserNickName removeObject:nickName];
            [_mapView removeAnnotation:annotation];
        }
    }
}
```

3.结束语 
> 实时共享 其实与群聊差不多，就是我的位置移动距离达到了精度要求，我就发送一次群消息，让每一个参加共享的人都知道，然后在自己的地图上更新一次。以上就是我们的位置实时共享的逻辑与部分代码，欢迎各位的指正，谢谢。