---
layout: '[layout]'
title: iOS-js与iOS的交互（基于WKWebViewJavascriptBridge第三方）
date: 2016-07-09 20:30:21
tags: [“js”, “iOS”, “WKWebViewJavascriptBridge”]
categories: "iOS"
---

>后天就要去北京出差了，据说那边的项目主要是与网页交互，所以就简单的研究了一下js与iOS的交互。
其交互方式有很多种


- 一、native（app）通过UIWebView的代理方法拦截url scheme判断是否是我们需要拦截处理的url及其所对应的要处理的逻辑（可以实现对网页的返回、前景、刷新），比较通用和简单。



```
self.webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];

self.webView.delegate = self;

[self.webView setUserInteractionEnabled:YES];//是否支持交互

[self.webView setOpaque:NO];//opaque是不透明的意思

[self.webView setScalesPageToFit:YES];//自动缩放以适应屏幕

[self.view addSubview:self.webView];

if (sender.tag == 101) {

// 返回（点击页面才会有返回）

[self.mWebView goBack];

}else if (sender.tag == 102) {

// 前进（点击过的页面）

[self.mWebView goForward];

}else {

// 刷新页面

[self.mWebView reload];

}
```

- 二、iOS7之后出了JavaScriptCore.framework用于与JS交互，通过JSContext调用JS代码的方法：

1、直接调用JS代码

2、在ObjC中通过JSContext注入模型，然后调用模型的方法

通过evaluateScript:方法就可以执行JS代码

- 三、React Native （不是很了解，只知道是Facebook的，能编译很多的语音，兼容性很强，可移植也很强，有很多很好的原生控件，有兴趣的朋友可以了解一下）

- 四、WebViewJavascriptBridge（第三方）是基于方式一封装的（主要是两个回调函数）。

在iOS端：1.self.bridge = [WebViewJavascriptBridge bridgeForWebView:self.webView];

链接iOS与js,self.webView就是展示你用来显示需要交换页面的UIWebView

```
2.[self.bridge registerHandler:@"testJavascriptHandler" handler:^(id data, WVJBResponseCallback responseCallback) {

NSLog(@"ObjC Echo called with: %@", data);

// 反馈给JS

responseCallback(data);

}];

// 在JS中如果调用了bridge.send()，那么将触发OC端_bridge初始化方法中的回调。

// 在JS中调用了bridge.callHandler('testJavascriptHandler')，它将触发OC端注册的同名方法

// oc 同理

// JS主动调用OjbC的方法

// 这是JS会调用ObjC Echo方法，这是OC注册给JS调用的

// JS需要回调，当然JS也可以传参数过来。data就是JS所传的参数，不一定需要传

// OC端通过responseCallback回调JS端，JS就可以得到所需要的数据

3.[self.bridge callHandler:@"sayHello" data:@{@"hello": @"你好"} responseCallback:^(id responseData) {

NSLog(@"回调结果: %@", responseData);

}];
```


直接调用JS端注册的HandleName，一定注意此次的名字一定要与js端的相同。
js调用时也一样
在JS端：

```
1.Copy and paste setupWebViewJavascriptBridge into your JS:

（此段代码为固定格式，直接放在js端就行）

function setupWebViewJavascriptBridge(callback) {

if (window.WebViewJavascriptBridge) { return callback(WebViewJavascriptBridge); }

if (window.WVJBCallbacks) { return window.WVJBCallbacks.push(callback); }

window.WVJBCallbacks = [callback];

var WVJBIframe = document.createElement('iframe');

WVJBIframe.style.display = 'none';

WVJBIframe.src = 'wvjbscheme://__BRIDGE_LOADED__';

document.documentElement.appendChild(WVJBIframe);

setTimeout(function() { document.documentElement.removeChild(WVJBIframe) }, 0)

}
```
后面几步与iOS端一样

如有错误，望请指出。