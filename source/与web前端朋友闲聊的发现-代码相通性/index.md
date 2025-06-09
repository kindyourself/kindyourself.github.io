---
layout: '[layout]'
title: 与web前端朋友闲聊的发现-代码相通性
date: 2016-07-15 23:50:50
tags: [“iOS”, “web”, “代码相通性”]
categories: "其他"
---

###缘起
>   今天与一个做web前端的哥们闲聊了一会，他今天遇到了一个问题：就是在做一个混合开发的APP时候，他们H5端有一个页面需要做搜索，就是在搜索框内输入能够实时的展示搜索结果。

###想法与问题
> 他想监听了搜索框并且实时的进行数据的请求。后来发现输入的过程一直在进行远程数据的请求，他觉得这样消耗太大了。于是想做一个延时的操作，就是等用户稍微停止输入的时候才去远程请求数据。可是没有理清这个逻辑，于是他的方法相当的复杂，好像是要将每一实时输入的数据存入数组，然后进行对比，当延时完成进行对比决定请求的数据。

###插曲
> 但是他在这个过程中发现了一个问题，就是延时操作并没有减少网络请求的次数。这个问题在前段时间的项目中我也遇到了，就是延时操作并不是重复了，就不执行了，延时操作只是延缓操作时间，每一次的延时都会被执行。所以想要减少执行次就必须在延时操作未执行 前取消延时操作。取消的延时操作如果还没有执行，就不会执行了而不是取消后就立即执行。

###讨论
> 这时候我想起几天前在简书上看见一个哥们写了一篇[关于如何防止button被重复点击](http://www.jianshu.com/p/7bca987976bd)的文章，他一共介绍了三种方法，他的第二种方法：
```
[button addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside]
- (void)click:(UIButton *)sender
 { 
      [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(btnClicke) object:nil]; 
      [self performSelector:@selector(btnClicke) withObject:nil afterDelay:1];
  }
```
> 就是用的延时操作他的是在button的方法里面先取消延时方法，再添加延时方法，这个对于防止button重复点击来说并不是好的方法，因为这样会影响用户的体验，每次点击button不能及时的进行响应。但是对于我朋友的这个问题却是一个很好的选择。他原本就想减缓请求次数。

###结论
> 我发现编程语言是相通的，虽然各有各的语法，但是实现思路是一样的，特此记录。