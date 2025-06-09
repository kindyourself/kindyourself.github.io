---
layout: '[layout]'
title: iOS-widget-Today 扩展
date: 2016-07-25 11:23:58
tags: [“iOS”, “widget”, “扩展”]
categories: "iOS"
---
> 今天要分享的是通知中心扩展中的-[Today](https://developer.apple.com/library/ios/documentation/General/Conceptual/ExtensibilityPG/)扩展（ios8推出），ios目前可以使用的扩展有：today扩展（widget-即通知栏的今天一栏）、键盘自定义、文件管理、照片编辑扩展、通知扩展（推送）、分享扩展等。扩展与拥有这个扩展主应用的生命周期是独立的。他们是两个独立的进程。



###一、目标：
      我项目是希望在widget中添加一个H5的页面方便以后的自定义。点击对应按钮去到相应界面，我也不知道这样算不算滥用widget，因为之前看见过有人的应用被苹果拒绝就是因为滥用widget导致的。
###二、实现：
1.因为widget是一个单独的进程所以需要创建一个target：
![首先 2016-07-24 23.01.34.png](https://i-blog.csdnimg.cn/blog_migrate/0b583421a35083363bf56d91148192dd.webp?x-image-process=image/format,png)



![然后 2016-07-24 23.01.13.png](https://i-blog.csdnimg.cn/blog_migrate/217a9594befa8d064b3f479abf1d92db.webp?x-image-process=image/format,png)

2.代码

```
- (void)viewDidLoad {
    [super viewDidLoad];
    // 调整Widget的高度
    self.preferredContentSize = CGSizeMake(0, 200);
    // 1、创建UIWebView：
    UIWebView *mWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
    // 2、设置属性：
    mWebView.scalesPageToFit = YES;// 自动对页面进行缩放以适应屏幕
    // 检测所有数据类型  设定电话号码、网址、电子邮件和日期等文字变为链接文字
    [mWebView setDataDetectorTypes:UIDataDetectorTypeAll];
    mWebView.delegate = self;
    // 打开URL
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]];
    [mWebView loadRequest:request];
    [self.view addSubview:mWebView];
    
    [self makeButtonWithTitle:@"返回" frame:CGRectMake(0, 0, 80, 64) button:_backBtn];
    [self makeButtonWithTitle:@"前进" frame:CGRectMake(self.view.frame.size.width - 80, 0, 80, 64) button:_forWardBtn];
    [self makeButtonWithTitle:@"刷新" frame:CGRectMake(100, 0, 80, 64) button:_refreshBtn];
    
}
// 取消widget默认的inset，让应用靠左
- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
    return UIEdgeInsetsZero;
}
- (void)makeButtonWithTitle:(NSString *)title frame:(CGRect)frame button:(UIButton *)btn {
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(skip:) forControlEvents:UIControlEventTouchUpInside];
    [btn setFrame:frame];
    
    if ([title isEqualToString:@"返回"]) {
        btn.tag = 101;
    } else if([title isEqualToString:@"前进"]) {
        btn.tag = 102;
    }else {
        btn.tag = 103;
    }
    [self.view addSubview:btn];
}
- (void)skip:(UIButton *)button
{
    if (button.tag == 101) {
        [self.extensionContext openURL:[NSURL URLWithString:@"iOSWidgetApp://action=GotoHomePage"] completionHandler:^(BOOL success) {
            NSLog(@"101   open url result:%d",success);
        }];
    }
    else if(button.tag == 102) {
        [self.extensionContext openURL:[NSURL URLWithString:@"iOSWidgetApp://action=GotoOtherPage"] completionHandler:^(BOOL success) {
            NSLog(@"102    open url result:%d",success);
        }];
    }else {
        [self.extensionContext openURL:[NSURL URLWithString:@"iOSWidgetApp://action=GotoOtherPages"] completionHandler:^(BOOL success) {
            NSLog(@"102    open url result:%d",success);
        }];
    }
}

```
运行与结果展示：
![运行 2016-07-24 23.02.28.png](https://i-blog.csdnimg.cn/blog_migrate/d2078c3e20a8126af877649cb755bce1.webp?x-image-process=image/format,png)

![效果图 2016-07-25 09.55.44.png](https://i-blog.csdnimg.cn/blog_migrate/d8e9254bab90d77597bda99215fded4b.webp?x-image-process=image/format,png)

###扩展与主程序的交互-数据共享
这就要涉及扩展与应用之间的数据共享了-App Groups.

1. 首先在主应用的target > Capabilities下 打开App Groups 点击+ 在group.后面输入标识符，
![Snip20160725_1.png](https://i-blog.csdnimg.cn/blog_migrate/62f1aa6e7f4adbc919d563ca0a21bda6.webp?x-image-process=image/format,png)
再去扩展的target下进行相同的操作，记得group.后的标识符要一致。

2. 代码：
在上面的扩展代码里面已经定义了点击事件，这里主要是主应用接收到信息后进行判断和处理。
在这之前还需要先配置URL schems,在主程序的plist里面：
![plist 2016-07-25 10.40.15.png](https://i-blog.csdnimg.cn/blog_migrate/b36fb85f5f7ece4451b9e5c8b160d604.webp?x-image-process=image/format,png)

```
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    NSString* prefix = @"iOSWidgetApp://action=";
    
    UIWebView *webView = [[UIWebView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    webView.backgroundColor = [UIColor clearColor];
    webView.delegate = self;
    [webView setUserInteractionEnabled:YES];//是否支持交互
    [webView setOpaque:NO];//opaque是不透明的意思
    [webView setScalesPageToFit:YES];//自动缩放以适应屏幕
    webView .scrollView.bounces = NO;// 禁止UIWebView下拉拖动效果
    NSString *path;
    if ([[url absoluteString] rangeOfString:prefix].location != NSNotFound) {
        NSString* action = [[url absoluteString] substringFromIndex:prefix.length];
        if ([action isEqualToString:@"GotoHomePage"]) {
            path = [[NSBundle mainBundle] pathForResource:@"help" ofType:@"html"];
        }
        else if([action isEqualToString:@"GotoOtherPage"]) {
            path = [[NSBundle mainBundle] pathForResource:@"setting" ofType:@"html"];
        }else {
            path = [[NSBundle mainBundle] pathForResource:@"healthyArticle" ofType:@"html"];
        }
        NSURL *urll = [NSURL fileURLWithPath:path];
        NSURLRequest* request = [NSURLRequest requestWithURL:urll] ;
        [webView loadRequest:request];
        [self.rootView.view addSubview:webView];
        self.rootView.view.backgroundColor = [UIColor whiteColor];
    }
    return  YES;
}
```
因为我是需要到对应的H5页面所以是添加的H5页面。
#
###注意：
1.当程序内存不足时，苹果优先会杀死扩展，因此需要注意内存的管理。

2.在配置team是账号需要一致（我测试的时候免费账号好像还不行，需要付费的账号）

3.在iOS10上面还可以从左滑主页面和锁屏进入widget。

4.today只有在下拉的时候才会更新，通知栏两边的更新机制是不一样的。

5.一般更新路径：viewDidLoad->viewWillAppear，但是如果你下拉过于频繁就只会执行viewWillAppear里面的，因此更新代码最好放在viewWillAppear里面。
######如有错误地方，万望指出，谢谢！