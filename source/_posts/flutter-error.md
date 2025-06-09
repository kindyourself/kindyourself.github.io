---
layout: '[layout]'
title: Flutter遇到的问题
date: 2025-05-23 15:17:44
tags: [“Flutter”, “Error”]
categories: "Flutter"
---


>**1.Flutter In ios 14+,debug mode Flutter apps can only be launched from Flutter tooling。
原因：Debug模式下，Flutter也实现了热重载，默认编译方式为JIT而iOS 14+系统对这种编译模式做了限制，导致无法启动。**

解决办法如下：用 [Xcode] 打开Flutter里面Runner工程项目，在 Build Settings 的最下方找到 User-Defined，点击 + 按钮，添加一个键为 FLUTTER_BUILD_MODE ，debug设置profile模式，release设置release 模式：![截屏2024-03-14 11.27.00.png](https://i-blog.csdnimg.cn/img_convert/7f789a7b66202aa3d5d577d4ff7a4b51.webp?x-oss-process=image/format,png){target="_blank"}

>**2.将 flutter 模块 嵌入iOS工程中，编译时报错：Failed to package 。。。。flutter代码路径。。。。。Command PhaseScriptExecution failed with a nonzero exit code**
![截屏2024-03-14 11.28.18.png](https://i-blog.csdnimg.cn/img_convert/ad21f4b3e2a82eb701e1e9363f00d885.webp?x-oss-process=image/format,png){target="_blank"}

解决办法如下：
**1.确保flutter项目代码中没有错误**
**2.重新构建项目：**
**flutter clean** 
**2.flutter pub get（获取远程库,确定当前应用所依赖的包，并将它们保存到中央系统缓存（central system cache）中）** 
**3.flutter run**


>**3.升级flutter：flutter upgrade --force 报错**
![截屏2024-09-12 15.23.05.png](https://i-blog.csdnimg.cn/img_convert/ed59f544c4becaac4c167e3128af66ca.webp?x-oss-process=image/format,png){target="_blank"}

Flutter Channel版本选择
Flutter提供了Stable、Beta、Dev和Master四种版本，每种版本都有其特定的用途和稳定性：
Stable：最稳定的版本，推荐用于生产环境。
Beta：相对较稳定，但仍可能存在一些已知问题。
Dev：经过Google测试后的最新版本，包含新功能和改进。
Master：最新的代码主分支，更新速度非常快，几乎每天都有提交，新功能多但可能不稳定。
开发Flutter项目时，一般推荐使用Stable版本，以确保项目的稳定性和可靠性。如需使用某些尚未在Stable版本中支持的功能，可以考虑使用Beta或Dev版本。Master版本则更适合于那些希望尝试最新功能并愿意承受潜在不稳定性的开发者。