---
layout: '[layout]'
title: iOS-webView上加载HTML视频不显示缩略图
date: 2016-08-08 01:06:48
tags: [“iOS”, “webView”, “视频不显示缩略图”]
categories: "iOS"
---

>最近在项目中遇到了一个比较棘手的问题：在原生的iOS的webView上面加载HTML视频发现没有缩略图，在网上查了资料发现在HTML里面有个poster属性（添加一个图片）可以设置缩略图，但是我们的后台告诉我视频资源本来就是来自网络的，没有缩略图只能自己解决了。于是开始是Google模式。终于功夫不负有心人，在一个[国外的网站](https://www.sitepoint.com/html5-video-fragments-captions-dynamic-thumbnails/)上面发现了一个折中的解决办法。

###办法
其实结局的办法很简单，但是对我这个不是太懂前端的人来说还是……。

![方法2016-08-08 00.29.36.png](https://i-blog.csdnimg.cn/blog_migrate/4207318919c8a9ed74e9a03b62d18e6c.webp?x-image-process=image/format,png)

这个方法就是在资源URL的后面（视频格式后面，有的时候视频格式后面还有其他的字符串，我是直接把.mp4后面的直接删除了，但是视频还是可以播放）加上#t=xxx,其中的xxx代表的是时间（秒）。大概的思路是这样的：就是在加载视频的时候设置视频的起始时间让视频跳转到你设置的时间上，但是时间一定要足够的小，因为大了前面的视频就看不了了。

这个方法其实还有一个用法：

![用法 2016-08-08 00.50.52.png](https://i-blog.csdnimg.cn/blog_migrate/406035d5b21ac7d6e4ba0edbf0414389.webp?x-image-process=image/format,png)

视频会在0：06开始播放直到0：20停止播放。但是这不是自动播放，自动播放需要设置：autoplay="autoplay"。
###声明
NOTE：对于web端我是一个菜鸟，也不知道用这个方法解决这个问题是不是太蠢了，希望谁有其他更好的解决办法可以不吝赐教，谢谢。