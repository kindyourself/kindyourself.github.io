---
layout: '[layout]'
title: UISearchBar详解
date: 2017-03-11 00:27:34
tags: [“iOS”, “swift”, “UISearchBar”]
categories: "swift"
---

>今天公司的项目测试的差不多了，基本可以上架了，又有时间来分享一下最近遇到的一些问题了，公司的项目进行了大改版（应该是全改了，基本是一个新的项目了），老大决定用swift重写。之前一直在自学swift，终于这一次可以实战了。项目中搜索用的比较多，但是搜索框的样式与默认的差别太大了，所以只能自定义了。

<p>The UISearchBar class implements a text field control for text-based searches. The control provides a text field for entering text, a search button, a bookmark button, and a cancel button. The UISearchBar object does not actually perform any searches. You use a delegate, an object conforming to the UISearchBarDelegate protocol, to implement the actions when text is entered and buttons are clicked.<p>

	以上是苹果对UISearchBar的解释，可以看见UISearchBar提供了类似UITextField的输入（其实它的组成中就有UITextField，下面会讲到），右边有搜索按钮、标签按钮、关闭按钮可供选择，搜索都是在协议UISearchBarDelegate中进行。

1.自定义外观
![默认搜索外观](https://i-blog.csdnimg.cn/blog_migrate/7efbcef7e9cb93c4383fe6794bdbefdf.webp?x-image-process=image/format,png)

![项目搜索外观](https://i-blog.csdnimg.cn/blog_migrate/226c294545fe64cc3f3f91cd71df0146.webp?x-image-process=image/format,png)

UISearchBar的层级很是复杂主要由UISearchBarBackgroud、UISearchBarTextField、
UINavigationButton组成，其中UISearchBarTextField就是输入框，主要是由——UISearchBarSearchFieldBackgroundView、UIButton（❌）、UIImageView（?）等组成，获取TextField方法：

```
let searchFiled:UITextField = self.searchBar.value(forKey: "_searchField") as! UITextField
```
这样就可以通过修改	searchFiled来修改输入样式（圆角、字体等）。

UISearchBar的直接子控件是UIVIew，其上的子控件UISearchBarBackgroud的frame与UISearchBar的bounds相等，UISearchBarTextField的高度默认为28与UISearchBar左右有8像素的固定间距，上下间距为直接子控件UIView的高度 - UISearchBarTextField的默认高度28 再除以2。因此UISearchBar的输入框始终与设置的frame不一样，不便于布局，我们可以添加一个子类继承UISearchBar，可以更改其内边距。

```
class MySearchBar: UISearchBar {
    
    // 监听是否添加了该属性
    var contentInset: UIEdgeInsets? {
        didSet {
            self.layoutSubviews()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 便利寻找
        for view in self.subviews {
            for subview in view.subviews {
                // 判定是否是UISearchBarTextField
                if subview.isKind(of: UITextField.classForCoder()) {
                    if let textFieldContentInset = contentInset {
                        // 修改UISearchBarTextField的布局
                        subview.frame = CGRect(x: textFieldContentInset.left, y: textFieldContentInset.top, width: self.bounds.width - textFieldContentInset.left - textFieldContentInset.right, height: self.bounds.height - textFieldContentInset.top - textFieldContentInset.bottom)
                    } else {
                        // 设置UISearchBar中UISearchBarTextField的默认边距
                        let top: CGFloat = (self.bounds.height - 28.0) / 2.0
                        let bottom: CGFloat = top
                        let left: CGFloat = 8.0
                        let right: CGFloat = left
                        contentInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
                    }
                }
            }
        }
    }

}
```

让实例化的UISearchBar继承MySearchBar，然后就可以很方便的直接控制内边距了

```
self.searchBar.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
```
接下来就是处理placeholder靠左，这个就比较麻烦了，查询了一大堆办法都挺麻烦的，最后找到了一个很投机的办法：先判定手机宽度，然后在placeholder右边加上空格做成靠左的假象。

```
 if SCREEN.WIDTH == 320 {
            self.searchBar.placeholder = "搜索位置       "
        }else if SCREEN.WIDTH == 373\5 {
            self.searchBar.placeholder = "搜索位置                  "
        }else if SCREEN.WIDTH == 414 {
            self.searchBar.placeholder = "搜索位置                                 "
        }

```

然后在storyboard中设置searchBar的BarStyle为Minimal就可以很方便的控制UISearchBar的外观了。
到这里就剩一个问题了：UISearchBar上下的两根黑线了，去除方法：

```
self.searchBar.setBackgroundImage(UIImage.init(), for: .any, barMetrics: .default)
```

2.搜索的使用
	如苹果官方文档所说，与搜索相关的都是在其代理方法中完成。UISearchBar有很多的代理方法，感兴趣的可以点击进入查看[UISearchBarDelegate](https://developer.apple.com/reference/uikit/uisearchbardelegate)我就介绍几个常用的：
	
当搜索内容变化时，执行该方法,可以实时监听输入框的变化,可以实现时实搜索。
	
```
- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)textNS_AVAILABLE_IOS(3_0);                 // called before text changes
```

也行你想把搜索事件放在点击搜索以后再触发，那就选用这个方法，它就是点击搜索后的代理方法

```
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar;
```

3.结束

当然如果你觉得这样太麻烦了，你还可以选择用UITextField来实现UISearchBar的功能，但是最终哪一个更加的麻烦还需要试一试才知道。