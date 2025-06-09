---
layout: '[layout]'
title: iOS-高德地图
date: 2016-07-09 20:19:07
tags: [“iOS”, “高德地图”]
categories: "iOS"
---

     一直以来在简书上学习了不少的知识，自己也想分享一些知识供大家指点，最近正好在研究高德地图API，所以分享一下自己最近捣鼓的。
    要使用高德API，首先要去高德API官网注册开发者账号，创建应用，获得key值。然后在本地创建自己的项目pod高德SDK，在pod时要提前思考清楚是否需要导航，我在这里就被坑过，因为导航的SDK包含搜索的SDK，如果将搜索SDK与导航SDK都pod了会报链接错误，所以如果需要导航就可以不用pod搜索SDK了。最后就是本地导入相应头文件，然后配置key。
  
```
const static NSString *APIKey = @"你申请的key";

// 配置用户Key

[MAMapServices sharedServices].apiKey = (NSString *)APIKey;

// 搜索

[AMapSearchServices sharedServices].apiKey = (NSString *)APIKey;

// 导航

[AMapNaviServices sharedServices].apiKey = (NSString *)APIKey;
```

    后面的就可以按照它的开发指南写，要注意的是路径规划是建立在路径搜索之上的，要路径规划先得完成路径搜索。导航的语音合成，我是用的讯飞的在线语音合成，离线的好像要收费，在下穷猿一名。高德导航的demo好像也是用的讯飞的。去讯飞API官网注册账号，创建应用，获取key，然后配置语音。


```
//设置sdk的log等级，log保存在下面设置的工作路径中

[IFlySetting setLogFile:LVL_ALL];

//打开输出在console的log开关

[IFlySetting showLogcat:YES];
//设置sdk的工作路径
NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);

NSString *cachePath = [paths objectAtIndex:0];

[IFlySetting setLogFilePath:cachePath];
// 配置相关参数
- (void)configIFlySpeech
{
[IFlySpeechUtility createUtility:[NSString stringWithFormat:@"appid=%@,timeout=%@",@"5733feca",@"20000"]];

[IFlySetting setLogFile:LVL_NONE];

[IFlySetting showLogcat:NO];

// 设置语音合成的参数

[[IFlySpeechSynthesizer sharedInstance] setParameter:@"50" forKey:[IFlySpeechConstant SPEED]];//合成的语速,取值范围 0~100

[[IFlySpeechSynthesizer sharedInstance] setParameter:@"50" forKey:[IFlySpeechConstant VOLUME]];//合成的音量;取值范围 0~100

// 发音人,默认为”xiaoyan”;可以设置的参数列表可参考个 性化发音人列表;

[[IFlySpeechSynthesizer sharedInstance] setParameter:@"xiaowang" forKey:[IFlySpeechConstant VOICE_NAME]];

// 音频采样率,目前支持的采样率有 16000 和 8000;

[[IFlySpeechSynthesizer sharedInstance] setParameter:@"8000" forKey:[IFlySpeechConstant SAMPLE_RATE]];

// 当你再不需要保存音频时，请在必要的地方加上这行。

[[IFlySpeechSynthesizer sharedInstance] setParameter:nil forKey:[IFlySpeechConstant TTS_AUDIO_PATH]];

}
然后初始化和设置代理。
- (void)initIFlySpeech {

if (self.iFlySpeechSynthesizer == nil)

{

_iFlySpeechSynthesizer = [IFlySpeechSynthesizer sharedInstance];

}

_iFlySpeechSynthesizer.delegate = self;

}

// 语音失败回调代理函数

- (void)onCompleted:(IFlySpeechError *)error {

NSLog(@"Speak Error:{%d:%@}", error.errorCode, error.errorDesc);

}
```

    高德导航有一个回调函数，会传回导航语音的字符串，在回调函数里面创建异步线程，将字符串合成语音，并且播放，在高德导航点击关闭按钮的回调函数里面关闭播放并且关闭导航。

####pragma mark -- 语音调用（导航回调）

```

- (void)naviManager:(AMapNaviManager *)naviManager playNaviSoundString:(NSString *)soundString soundStringType:(AMapNaviSoundType)soundStringType {

if (soundStringType == AMapNaviSoundTypePassedReminder) {

// 系统语音

AudioServicesPlaySystemSound(1009);

}else {

// 开启异步线程（全局）

dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

[_iFlySpeechSynthesizer startSpeaking:soundString];

});

}

}

// 这是点击关闭按钮的回调函数（就是导航界面的叉叉）

- (void)naviViewControllerCloseButtonClicked:(AMapNaviViewController *)naviViewController {

dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

[self.iFlySpeechSynthesizer stopSpeaking];

});

[self.naviManager stopNavi];

[self.naviManager dismissNaviViewControllerAnimated:YES];

}
```

     以上就是我最近研究的高德API，一是对最近学习的总结，二是希望帮助刚刚接触高德的人，希望对你们有帮助，文章写得有点乱，第一次啊，以后肯定会越来越好。如有错误欢迎各位指出。谢谢。
