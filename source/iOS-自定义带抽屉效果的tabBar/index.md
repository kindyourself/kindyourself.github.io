---
layout: '[layout]'
title: iOS-自定义带抽屉效果的tabBar
date: 2016-07-15 23:50:50
tags: [“iOS”, “抽屉”, “tabBar”]
categories: "iOS"
---

demo地址：[gitHub](https://github.com/GavinCarter1991/-tarBar)
###一、先来个效果

![tabBar.gif](https://i-blog.csdnimg.cn/blog_migrate/05244727e176525fc66016280b6309d6.webp?x-image-process=image/format,png)

###二、代码示例
1.抽屉页作为根视图：

```
@interface DrawerViewController ()
{
    UITapGestureRecognizer *tapGesture;
}

//创建左边的抽屉
@property (nonatomic, strong) LeftViewController *leftViewController;

//创建右边的标签控制器
@property (nonatomic, strong) MTabBarViewController *mainViewController;
//抽屉是否显示的标示

@property (nonatomic, assign) BOOL isOpen;
@end

@implementation DrawerViewController

- (void)dealloc
{
    //移除通知
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"buttonTap" object:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createTabBarController];
    [self createLeftVc];
    
    self.view.backgroundColor = [UIColor grayColor];
    
    //添加通知，监听TabBar的点击事件 隐藏左边抽屉
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(buttonTap) name:@"buttonTap" object:nil];
    
}
- (void)buttonTap
{
    //抽屉展开时则隐藏
    if (self.isOpen == YES) {
        [self openOrHidden];
    }
    
}
//创建左边抽屉
- (void)createLeftVc
{
    self.leftViewController = [[LeftViewController alloc]init];
    
    //抽屉控制器添加到父控制器中
    [self addChildViewController:self.leftViewController];
    self.leftViewController.view.frame = LeftViewStartFrame();
    [self.view addSubview:self.leftViewController.view];
    [self.leftViewController didMoveToParentViewController:self];
    
}
//创建右边的标签控制器
- (void)createTabBarController{
    //
    NSArray *classNames = @[@"ProductViewController",@"MessageViewController",@"OrderViewController"];
    
    //保存viewControllers
    NSMutableArray *viewControllers = [NSMutableArray array];
    [classNames enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //先把字符串转化为类名
        Class class = NSClassFromString(obj);
        
        //创建ViewController
        UIViewController *vc = [[class alloc]init];
        UINavigationController *aNav = [[UINavigationController alloc]initWithRootViewController:vc];
        
        [viewControllers addObject:aNav];
        
    }];
    //TabBarController 创建
    _mainViewController = [[MTabBarViewController alloc]initWithViewControllers:viewControllers];
    _mainViewController.view.backgroundColor = [UIColor brownColor];
    
    //添加标签控制器到父控制器
    [self addChildViewController:self.mainViewController];
    self.mainViewController.view.frame = BOUNDS;
    [self.view addSubview:self.mainViewController.view];
    [self.mainViewController didMoveToParentViewController:self];
}

//标签控制器显示的vc的根控制器的view往右边移动
//tabBar -> Nav (ViewControllers[selectedIndex]) -> Nav.rootViewController.view
- (void)tabBar_Nav_RootViewController_viewMoveRight
{
    //标签控制器当中 当前显示的控制器
    UINavigationController *nav = self.mainViewController.viewControllers[self.mainViewController.selectedIndex];
    //取出导航控制器的根控制器
    UIViewController *rootVc = nav.childViewControllers[0];
    rootVc.view.frame = RightContentEndFrame();
}
- (void)tabBar_Nav_RootViewController_viewMoveLeft
{
    //标签控制器当中 当前显示的控制器
    UINavigationController *nav = self.mainViewController.viewControllers[self.mainViewController.selectedIndex];
    //取出导航控制器的根控制器
    UIViewController *rootVc = nav.childViewControllers[0];
    rootVc.view.frame = RigntContentStartFrame();
}


//显示左边抽屉
- (void)open
{
    [UIView animateWithDuration:0.48 animations:^{
        self.leftViewController.view.frame = LeftViewEndFrame();
        [self tabBar_Nav_RootViewController_viewMoveRight];
    } completion:nil];
    
    //添加点击手势，点击某些区域的隐藏抽屉
    tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:tapGesture];
}
- (void)tap:(UITapGestureRecognizer *)gesturer
{
    //获取点击的位置
    CGPoint point = [gesturer locationInView:self.view];
    if (CGRectContainsPoint(self.leftViewController.view.frame, point) == YES) {
        return;
    }
    
    [self hidden];
    self.isOpen = NO;
    //移除手势
    [self.view removeGestureRecognizer:tapGesture];
}
//隐藏左边抽屉
- (void)hidden
{
    [UIView animateWithDuration:0.48 animations:^{
        self.leftViewController.view.frame = LeftViewStartFrame();
        [self tabBar_Nav_RootViewController_viewMoveLeft];
    } completion:nil];
    
}

- (void)openOrHidden
{
    //当前如果是隐藏，则显示
    if (self.isOpen == NO) {
        [self open];
    }
    
    //当前如果是显示的，则隐藏
    if (self.isOpen == YES) {
        [self hidden];
    }
    
    //改变隐藏标记
    self.isOpen = !self.isOpen;
}
@end

```

2.标签视图 修改方法 ```- (void)selectBtn:(UIButton *)sender```中的切换效果可以实现不同的切换动画与效果。


```
@implementation MTabBar
- (instancetype)initWithTitles:(NSArray *)titles imageNames:(NSArray *)imageNames
{
    self = [super initWithFrame:TabBarFrame()];
    if (self) {
        
        //标题数组不为空，图片名字个数 ＝ 标题个数
        self.buttonBack = [[UIView alloc]initWithFrame:CGRM(0, 0, BUTTON_W, 64)];
        self.buttonBack.backgroundColor = BUTTON_BACK_COLOR;
        [self addSubview:self.buttonBack];
        
        self.backgroundColor = TABBAR_BACK_COLOR;
        
        if ([titles count] && [titles count] == [imageNames count]) {
            [titles enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                UIButton *button = [[UIButton alloc]initWithFrame:CGRM(BUTTON_W*idx, 0, BUTTON_W, 64)];
                button.tag = 1000 + idx;
                [self addSubview:button];
                //默认选中第一个
                if (idx == 0) {
                    button.selected = YES;
                    self.selectedButton = button;
                }
                
                [button addSubview:MakeLabel(CGRM(0, 30, BUTTON_W, 34), obj)];
//                // 图片宽 高分别为 44 24
                CGFloat x = (BUTTON_W - 44)/2;
                [button addSubview:MakeImageView(CGRM(x, 5, 44, 24),[imageNames objectAtIndex:idx])];
                //添加点击方法
                [button addTarget:self action:@selector(selectBtn:) forControlEvents:UIControlEventTouchUpInside];
            }];
        }
    }
    return self;
}
//button 点击方法
- (void)selectBtn:(UIButton *)sender
{
    //让抽屉隐藏，发出通知
    [[NSNotificationCenter defaultCenter]postNotificationName:@"buttonTap" object:nil];
    
    //选中的button 已经是选中状态 不用处理
    if (self.selectedButton == sender) {
        return;
    }
    //改变之前选中button的状态  为非选中状态
    self.selectedButton.selected = NO;
    
    //改变当前选中button的状态
    sender.selected = YES;
    self.selectedButton = sender;
    //通知标签控制器显示当前button对应的viewController
    if (self.callBack) {
        self.callBack(sender.tag - 1000);
    }
    [UIView animateWithDuration:0.5 animations:^{
        self.buttonBack.center = CGPointMake(BUTTON_W/2+(sender.tag - 1000) * BUTTON_W, 32);
    } completion:nil];
}
UILabel *MakeLabel(CGRect frame, NSString *title)
{
    UILabel *label = [[UILabel alloc]initWithFrame:frame];
//    label.userInteractionEnabled = YES;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = title;
    return label;
}
//根据 frame和 imageName 创建UIImageView
UIImageView *MakeImageView(CGRect frame, NSString *imageName)
{
    UIImageView *imageV = [[UIImageView alloc]initWithFrame:frame];
//    imageV.userInteractionEnabled = YES;
    imageV.backgroundColor = [UIColor clearColor];
    imageV.image = [UIImage imageNamed:imageName];
    return imageV;
}
@end
```

3.标签控制器


```
@interface MTabBarViewController ()

@end

@implementation MTabBarViewController

- (instancetype)initWithViewControllers:(NSArray *)viewControllers
{
    self = [super init];
    if (self) {
        
        _viewControllers = viewControllers;
        //遍历数组，添加子控制器
        [_viewControllers enumerateObjectsUsingBlock:^(UIViewController *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self addChild:obj];
        }];
        /*
         @[@"商品.png",@"消息.png",@"订单.png"]
         @[@"商品浏览",@"我的消息",@"我的订单"]
         */
        _tabBar = [[MTabBar alloc]initWithTitles:@[@"商品浏览",@"我的消息",@"我的订单"] imageNames:@[@"商品.png",@"消息.png",@"订单.png"]];
        [self.view addSubview:self.tabBar];
        __weak typeof(self) weakSelf = self;
        self.tabBar.callBack = ^(NSInteger index){
            weakSelf.selectedIndex = index;
        };
        //默认选中第0个
        self.selectedIndex = 0;
    }
    return self;
}
- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    //取出当前控制器 oldVc
    UIViewController *oldVc = self.viewControllers[self.selectedIndex];
    //取出将要显示的 控制器 newVc
    UIViewController *newVc = self.viewControllers[selectedIndex];
    //动画 向左边移动
    newVc.view.frame = CGRectMake(S_W, 0, S_W, S_H);
    //改变 newVc 的视图层次
    
    //把newVc.view 的视图放在 self.tabBar 的下面
    [self.view insertSubview:newVc.view belowSubview:self.tabBar];
    [UIView animateWithDuration:0.5 animations:^{
        oldVc.view.frame = CGRectMake(-S_W, 0, S_W, S_H);
        newVc.view.frame = BOUNDS;
    }];
    _selectedIndex = selectedIndex;
}

//添加子控制器具体步骤
- (void)addChild:(UIViewController *)viewController
{
    [self addChildViewController:viewController];
    viewController.view.frame = BOUNDS;
    //将viewContoller.view 放在最底层
    [self.view insertSubview:viewController.view atIndex:0];
    [viewController didMoveToParentViewController:self];
    
//    self.view.subviews 数组 下标越小，视图层次越在下面，下标越大，视图层次越在上面
}
@end
```

4.视图位置控制 修改对应的视图的frame可以实现不同的视图效果


```
CGRect TabBarFrame()
{
    return CGRectMake(0, S_H-64, S_W, 64);
}

//左边抽屉隐藏（开始）的位置
CGRect LeftViewStartFrame()
{
    return CGRectMake(-S_W*0.75, 67,S_W*0.75 , S_H-64-64-6);
}
//左边抽屉显示（结束）的位置
CGRect LeftViewEndFrame()
{
    return CGRectMake(0, 67, S_W*0.75, S_H-64-64-6);
}

//右边内容开始（抽屉隐藏时）的位置
CGRect RigntContentStartFrame()
{
    return CGRectMake(0, 0, S_W, S_H);
}

//右边内容结束（抽屉显示时）的位置
CGRect RightContentEndFrame()
{
    return CGRectMake(S_W*0.75, 0, S_W, S_H);
}

CGRect CGRM(CGFloat x, CGFloat y,CGFloat w,CGFloat h)
{
    return CGRectMake(x, y, w, h);
}
@end

```


欢迎下载