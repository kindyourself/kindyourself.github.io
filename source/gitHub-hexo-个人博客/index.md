---
layout: '[layout]'
title: gitHub hexo 个人博客
date: 2016-07-16 04:11:37
tags: [“hexo”, “个人博客”, “gitHub”]
categories: "其他"
---

> 一直以来就想搭建一个自己的博客，不想其它网站那么杂乱，需要一个纯粹的记录成长之路的地方。查了很多资料，最后决定用hexo 搭建一个静态网页，托管在gitHub上。下面我就介绍一下我的搭建之路，[我的搭建网页](https://gavincarter1991.github.io/)。

### 1. gitHub
gitHub 的注册及配置我就不介绍了，这个哪里都可以查到，我介绍一下注册过后远程仓库的创建。
首先创建远程仓库：
![屏幕快照 2016-07-16 02.49.16.png](https://i-blog.csdnimg.cn/blog_migrate/ea1e5de3d83fcb9ca8c0eb0e11086ab3.webp?x-image-process=image/format,png)
在后面的Respository name 里面输入：gavincarter1991.github.io 这个格式是定的（gavincarter1991 需要填写你的用户名）我没有测试过如果不填写自己用户名的后果，不过查了很多资料都推荐这样填写，有的还是不以这样的方式会报错，没有实践，我没有发言权。
![屏幕快照 2016-07-16 02.49.37.png](https://i-blog.csdnimg.cn/blog_migrate/c44f6c8a7f4544c550f966f205dd7848.webp?x-image-process=image/format,png)

### 2. homebrew安装

```
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

```

```
brew install node
```
查看安装是否成功：

```
npm -v

```

```
node -v

```
安装成功会显示版本号：
![屏幕快照 2016-07-16 03.09.16.png](https://i-blog.csdnimg.cn/blog_migrate/257560df666479d7a2171dd37c11a68b.webp?x-image-process=image/format,png)

### 3. 开始安装hexo
首先进入你需要存放博客的文件夹，然后：

```
npm install hexo -g
```

查看版本号：

```
hexo version
```
初始化项目：(类似于git)

```
hexo init
```

### 4. 开始使用
创建页面：

```
hexo new post "My First Blog"
```
生成静态文件(会在当前目录下生成一个新的叫做public的文件夹)

```
hexo g # 或者hexo generate
```
开启本地服务 用于在本地浏览 Ctrl+C退出查看

```
hexo s # 或者hexo server，可以在输入http://localhost:4000/ 查看 或者 按住Command 双击命令行下的网址（http://localhost:4000/）
```
这时网页已经成型了。

接下来就是要部署到gitHub上 只需要在配置文件_config.xml中作如下修改：

```
deploy:
  type: git
  repo: git@github.com:gavincarter1991/gavincarter1991.github.io
  branch: master
```
当然gavincarter1991位置还是填你的信息

然后安装一个自动工具，方便以后页面的部署：

```
npm install hexo-deployer-git --save
```
部署去gitHub：

```
hexo d
```
以后每一次部署的一般步骤：

```
hexo clean
hexo g
hexo d
```
### 5.写文章
首先；

```
hexo new post "My First Blog"
```
然后去目录：source\_posts下找到My First Blog.md（markdown文件）开始编辑文章了。我Mac用的是Mou编辑器，你可以自由选择适合自己的markdown编辑器。[这里有markdown使用技巧](https://wizardforcel.gitbooks.io/markdown-simple-world/content/0.html)
写好以后就可以按照前面的部署常用步骤进行部署了。
### 6. 其他
1.主题：hexo有很多[第三方主题](https://github.com/hexojs/hexo/wiki/Themes)可以选择，通过git clone
2.配置修改参数[详见](http://div.io/topic/1691) 我写几个常用的：
头像：把图片放在主题内 source/images/，图片链接地址可以填 /images/avatar.png  然后在当前主题的_config.yml 不是根目录的_config.yml（如果你换了主题，需要根据自己选择的主题进入里面去设置）

```
# Sidebar Avatar
# in theme directory(source/images): /images/avatar.jpg
# in site  directory(source/uploads): /uploads/avatar.jpg
avatar: /images/avatar.jpg
```
个人中心配置：（根目录的_config.yml）

```
# Site
title: Gavin
subtitle: 记录成长过程中的点点滴滴
description: 我爱敏敏
author: kindyourself@163.com
language: zh-Hans
timezone:
```
显示标签与分类：取消对应注释

```
# When running the site in a subdirectory (e.g. domain.tld/blog), remove the leading slash (/archives -> archives)
menu:
  home: /
  categories: /categories
  #about: /about
  archives: /archives
  tags: /tags
  #commonweal: /404.html
```
然后创建分类

```
hexo new page "categories"
```
在/source/categories下有个index.md 按照如下填写：

```
---
title: categories
date: 2016-07-16 02:21:37
type: "categories"
comments: false
---
```

以后在写文章的时候加上分类就会自动创建分类了

```
layout: '[layout]'
title: iOS-自定义带抽屉效果的tabBar
date: 2016-07-12 23:19:35
tags: [自定义，抽屉，tabBar]
categories: "iOS" // 分类
---
```

创建标签

```
hexo new page "tags"
```
在/source/tags下有个index.md 按照如下填写：

```
---
title: All tags
date: 2016-07-16 02:11:12
type: "tags"
comments: false
---
```
以后在写文章的时候加上标签就会自动计入

```
layout: '[layout]'
title: iOS-自定义带抽屉效果的tabBar
date: 2016-07-12 23:19:35
tags: [自定义，抽屉，tabBar] // 标签
categories: "iOS"
---
```
下载主题：

```
git clone https://github.com/iissnan/hexo-theme-next themes/next
```

### 7. 总结
> 这个在网上还有很多很详细的教程，这是我的大致操作流程。感觉这个可以很简单，就是少去动原生的。如果你想要去捣鼓会发现还是有很多可以捣鼓的，因为他有很多的参数可以配置。我只是配置了一下我觉得在我看来重要的。有兴趣的朋友可以去捣鼓捣鼓。-太晚了，都4点了，睡觉去