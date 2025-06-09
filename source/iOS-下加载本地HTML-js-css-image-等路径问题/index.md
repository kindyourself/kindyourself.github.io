---
layout: '[layout]'
title: iOS 下加载本地HTML/js/css/image 等路径问题
date: 2016-07-25 11:29:55
tags: [“iOS”, “本地”, “路径问题”]
categories: "iOS"
---

今天在项目中遇到一个问题：我将H5的文件拖入项目中，在webView上添加H5,运行时发现H5的样式与图片等都没有了。经过多种测试后发现：是路径的问题。

在ios项目下添加本地HTML/js/css/image  当拖入项目时有两种选择：

  一个是  Create groups for any added folders （创建虚拟结构-包结构）
 
  一个是 Create folder references for any added folders （创建实体结构）
 
- 如果选择前者，当APP编译过后引入的文件会被放在同一个文件夹下面会忽略你原本的文件夹。因此在HTML文件中的路径就会出现问题。如果你选择了前者那么HTML文件中引入CSS，js，图片等就不需要添加前缀路径了，直接写文件名就行。
引入文件方式：
 
 ```
 NSString * htmlPath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
 NSString * htmlString = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
  NSURL *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath]];
 [self.webView loadHTMLString:htmlString baseURL:baseURL];
 ```
 - 如果选择后者，当APP编译过后引入的文件会按照原本的目录结构存放，这个时候就需要添加相对路径。
 引入文件方式：
 
 ```
[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"huaiha/index.html" relativeToURL:[[NSBundle mainBundle] bundleURL]]]];
```