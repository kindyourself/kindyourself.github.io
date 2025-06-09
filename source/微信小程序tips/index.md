---
layout: '[layout]'
title: 微信小程序tips
date: 2017-02-22 01:19:52
tags: [“微信小程序”]
categories: "微信小程序"
---

>最近公司项目改版，趁产品修改与UI出图的间歇用公司商户端UI图撸了一把微信小程序。因为刚刚实习那一会接触过前端开发，所以上手还比较快，当然也遇到了很多的问题，不过好在基本按图完成。趁此总结一下我遇到的问题,奉上一些可行的解决方案，希望可以帮助与我遇到相同问题的朋友。[demo](https://github.com/GavinCarter1991/wx-onePro) 

#####1、先上图
![微信小程序](https://i-blog.csdnimg.cn/blog_migrate/b6d605c3b3e52fc14fcf8b758b6c4b33.webp?x-image-process=image/format,png)

#####2、tips
1.背景图片不能使用本地的

这个问题坑了我很久，因为在模拟器上跑时，将本地图片作为View的背景图片是可以的，但是一到真机测试就不显示背景图片了，一开始还以为是路径错了，经过测试发现路径是没有问题的，最后在网上找到了原因：微信小程序的背景图片不能是本地图片，必须是是网络图片，于是我就找了一个网站将图片传了上去，将网址作为背景图片链接，就奇迹般的显示了，很是无语。

2.不能加载网页

微信小程序是不能跳转到网页的，也许是因为微信小程序本身就如同网页吧，也可能是微信不想有人越过它的审核，反正他是不允许直接加载网页的。

3.不能隐藏导航栏

我的登陆页面本来是不应该有导航栏的，可是就是隐藏不了，也许有方法，但是我找了很久也没有发现。

4.只支持HTTPS的网络协议并且一个月只能修改5次

在微信小程序中网络请求只能是https类型的。在添加URL的时候都已经限制死了。并且一个月只能修改5次，网络请求必须先进行服务器域名配置。
![添加URL](https://i-blog.csdnimg.cn/blog_migrate/48f1eaa31d6ea1dd09c872920e359dee.webp?x-image-process=image/format,png)
)


5.所有的页面都必须在app.json中配置路径


我之前新建一个页面然后跳转过去一直报路径错误，去网上查询才知道，每一个页面路径都需要提前配置。
![页面路径配置](https://i-blog.csdnimg.cn/blog_migrate/2cb2cfa23e160b24cec566232710f644.webp?x-image-process=image/format,png)

6.网络请求的最大并发数为5、页面层级最多5层


就是说同时最多5个网络请求，页面的子页面最多4个。我在想要是一个页面是一个视频列表展示怎么办，每一个视频都需要网络请求啊。

以上就是这次遇到的一些比较变态的问题。

#####3、谈谈我的一些代码实现

1.配置tabBar(app.json)

```
  "tabBar": {
    "color": "#888888",
    "selectedColor": "#09BB07",
    "backgroundColor": "",
    "borderStyle": "white",
    "list": [
      {
        "pagePath": "pages/orderManage/orderManage",
        "text": "订单管理",
        "iconPath": "pages/images/order.png",
        "selectedIconPath": "pages/images/order_r.png"
      },
      {
        "pagePath": "pages/moneyManage/moneyManage",
        "text": "财务管理",
        "iconPath": "pages/images/money.png",
        "selectedIconPath": "pages/images/money_r.png"
      },
      {
        "pagePath": "pages/myself/myself",
        "text": "我的商户",
        "iconPath": "pages/images/people.png",
        "selectedIconPath": "pages/images/people_r.png"
      }
      ]
  }
  ```
  2.订单管理页的菜单栏
  点击菜单栏切换View简单，直接将将点击的菜单的值赋给View让其偏移对应的百分比就好。
  手势切换：通过触摸的起点与终点计算出滑动方向，然后偏移并且切换菜单栏。
  
  ```
    catchtouchstart:function(e){
    var that = this;
    that.setData({
      startPoint: [e.touches[0].clientX,e.touches[0].clientY]
    })
  },
  catchtouchend:function(e){
    var that = this;
    var currentNum = parseInt(this.data.currentNavtab);
    var endPoint = [e.changedTouches[0].clientX,e.changedTouches[0].clientY];
    var startPoint = that.data.startPoint
    if(endPoint[0] <= startPoint[0]) {
      if(Math.abs(endPoint[0] - startPoint[0]) >= Math.abs(endPoint[1] - startPoint[1]) && currentNum< this.data.navTab.length -1) {
         currentNum=currentNum + 1;  
      }
    }else {
      if(Math.abs(endPoint[0] - startPoint[0]) >= Math.abs(endPoint[1] - startPoint[1]) && currentNum > 0) {
          currentNum -= 1;
      }
    }
    this.setData({
      currentNavtab: currentNum
    });
  },
// 点击菜单栏切换View
  switchTab: function(e){
    this.setData({
      currentNavtab: e.currentTarget.dataset.idx
    });
  }
  ```
###4、结束
整个程序还是很简单的，就是初次写还是有些不适应。尤其是把div改为了View，不能使用window对象和document对象，很不适应。再次奉上[demo](https://github.com/GavinCarter1991/wx-onePro)