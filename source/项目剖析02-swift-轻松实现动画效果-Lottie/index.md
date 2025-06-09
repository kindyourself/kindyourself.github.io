---
layout: '[layout]'
title: 项目剖析02-swift 轻松实现动画效果-Lottie
date: 2019-12-23 12:34:37
tags: [“iOS”, “动画”, “Lottie”]
categories: "iOS"
---

>[Lottie](https://github.com/airbnb/lottie-ios) 是 [Airbnb](https://lottiefiles.com/?lang=zh_CN)开源的一套跨平台的动画效果解决方案,它能够同时支持`iOS`、`Android`、`Web` 和 `React Native`的开发，设计师只需要用 [AdobeAfterEffects](https://www.adobe.com/cn/products/aftereffects.html)(AE) 设计出需要的的动画之后，使用 `Lottie` 提供的 [Bodymovin](https://github.com/bodymovin/bodymovin) 插件将设计好的动画导出成JSON格式(文件很小不会象GIF那么庞大)给你即可，可以让设计师实现所见即所得的动画再也不用和设计师争论动画设计了。本文只是展示在swift中如何简单使用`Lottie` ，详细的使用方法请参考[官方文档](https://airbnb.io/lottie/#/)

![github例图](https://i-blog.csdnimg.cn/blog_migrate/9435d33b4f8d95e2fbaed37fa0c418ba.gif)

### 1 用法举例
```
lazy var lottieAnimationView: AnimationView = {
        // 加载本地资源
        let path : String = Bundle.main.path(forResource: "data", ofType: "json")!
        let lottieAnimationView = AnimationView.init(filePath: path)
        WTNavigationManger.Nav?.view.addSubview(lottieAnimationView)
        lottieAnimationView.constrain(toSuperviewEdges: nil)
        lottieAnimationView.isUserInteractionEnabled = true
        lottieAnimationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(removeLottieAnimationViewFromParent)))
        return lottieAnimationView
    }()

// 调用
lottieAnimationView.play {[weak self] (complete) in
       guard let mySelf = self else {return}
       mySelf.removeLottieAnimationViewFromParent()
    }

@objc func removeLottieAnimationViewFromParent() {
        lottieAnimationView.removeFromSuperview()
    }
```
将设计师给你的文件导入项目，然后通过Bundle.main.path(forResource:找到json文件，然后将AnimationView添加到视图，在需要展示动画的地方调用play() 方法，这样动画就可以加载了。

### 2 引入json的方式
/// json所在的文件，默认为Bundle.main
let animation = Animation.named("StarAnimation") 
/// 默认为Bundle.main
let animation = Animation.named("StarAnimation", bundle: myBundle)
/// subdirectory 为动画所在的包中的子目录(可选的)
let animation = Animation.named("StarAnimation", subdirectory: "Animations")
/// animationCache 为保存加载动画的缓存(可选的)
let animation = Animation.named("StarAnimation", animationCache: LRUAnimationCache.sharedCache)

### 3 指定加载路径
```
Animation.filepath(_ filepath: String, animationCache: AnimationCacheProvider?) -> Animation?
```
从绝对文件路径加载动画模型。如果没有找到动画，则返回nil
filepath:要加载的动画的绝对文件路径
animationCache:用于保存加载的动画的缓存(可选的)

### 4 播放动画
1. 基本播放(Basic Playing)
```
// 播放动画从它的当前状态到它的时间轴结束。在动画停止时调用completion代码块
// 如果动画完成，则completion返回true。如果动画被中断，则返回false
AnimationView.play(completion: LottieCompletionBlock?)
```
2. 利用进度时间(Play with Progress Time)
```
// 指定一个时间到另一个时间的播放
AnimationView.play(fromProgress: AnimationProgressTime?, toProgress: AnimationProgressTime, loopMode: LottieLoopMode?, completion: LottieCompletionBlock?)
```
3. 时间帧播放(Play with Marker Names)
```
// 动画播放从一个时间帧到另一个时间帧
AnimationView.play(fromFrame: AnimationProgressTime?, toFrame: AnimationFrameTime, loopMode: LottieLoopMode?, completion: LottieCompletionBlock?)
```
4. 时间帧播放(Play with Marker Names)
```
// 将动画从命名标记播放到另一个标记。标记是编码到动画数据中并指定名称的时间点
AnimationView.play(fromMarker: String?, toMarker: String, loopMode: LottieLoopMode?, completion: LottieCompletionBlock?)
```
### 5 其它操作
1. AnimationView.pause() // 暂停

2. AnimationView.stop()  // 停止

3. var AnimationView.backgroundBehavior: LottieBackgroundBehavior { get set} // app进入后台

4. var AnimationView.contentMode: UIViewContentMode { get set } // 循环播放模式。默认是playOnce，还有autoReverse无限循环

5. var AnimationView.isAnimationPlaying: Bool { get set } // 判断动画是否在播放

6. var AnimationView.animationSpeed: CGFloat { get set } // 动画速度

7. func AnimationView.forceDisplayUpdate() // 强制重绘动画视图

### 6 以上就是我在项目中使用`Lottie`的方法，如果有错误或者不足之处还望指正，谢谢

