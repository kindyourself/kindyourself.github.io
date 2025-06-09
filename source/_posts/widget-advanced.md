---
layout: '[layout]'
title: Widget进阶
date: 2025-06-07 20:17:56
tags: [“Flutter”, “Widget”]
categories: "Flutter"
---

## 1.Widget 介绍

> Everything is a widget 这是你学习 flutter 会听到的最多的一句话。因为在 Flutter 中几乎所有的对象都是一个 widget，在 flutter 中 UI 的构建和事件的处理基本都是通过 widget 的组合及嵌套来完成的。在 iOS 中我们经常提及的“组件”、“控件”在 flutter 中就是 widget，当然 widget 的范围比之更加广泛。如：手势检测 GestureDetector、主题 Theme 和动画容器 AnimatedContainer 等也是 widget。

**Flutter 默认支持的两种设计风格：**

> **1.Material components Design：** 谷歌（android）的 UI 风格，主要为 Android 设计，但也支持跨平台使用。

> **2.Cupertino Design：** 苹果（iOS）的 UI 风格，模仿苹果原生 UIKit 风格。高度还原 iOS 原生体验，适合需要与苹果生态一致的应用。

## 2.Widget 分类

**_1.按状态管理_**

###### 一、StatelessWidget：

无状态组件，通过 build 方法返回静态 UI。不可变，属性（final）在创建后无法修改，适用于不需要内部状态变化的场景（如文本显示、图标），不依赖用户交互或数据变化的 UI 部分。

```
class IconTextButton extends StatelessWidget {
  final String iconName;
  final String label;
  final VoidCallback onPressed;

  const IconTextButton({
    super.key,
    required this.iconName,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            "assets/images/$iconName.png",
            width: 40,
            height: 40,
          ),
          const SizedBox(
            height: 10,
          ), // 图标
          Text(
            label,
            style: const TextStyle(color: ColorConstant.color33, fontSize: 10),
          ), // 文字
        ],
      ),
    );
  }
}

```

###### 二、StatefulWidget：

有状态组件，通过 State 对象管理动态数据。当状态变化时调用 setState 触发 UI 更新，需要用户交互（如按钮点击、表单输入）和依赖实时数据变化（如计数器、动态列表）。

```
// 上下滚动的消息轮播
class MarqueeWidget extends StatefulWidget {
  /// 子视图数量
  final int count;

  ///子视图构建器
  final IndexedWidgetBuilder itemBuilder;

  ///轮播的时间间隔
  final int loopSeconds;

  const MarqueeWidget({
    super.key,
    required this.count,
    required this.itemBuilder,
    this.loopSeconds = 5,
  });

  @override
  _MarqueeWidgetState createState() => _MarqueeWidgetState();
}

class _MarqueeWidgetState extends State<MarqueeWidget> {
  late PageController _controller;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _timer = Timer.periodic(Duration(seconds: widget.loopSeconds), (timer) {
      if (_controller.page != null) {
        // 如果当前位于最后一页，则直接跳转到第一页，两者内容相同，跳转时视觉上无感知
        if (_controller.page!.round() >= widget.count) {
          _controller.jumpToPage(0);
        }
        _controller.nextPage(
            duration: const Duration(seconds: 1), curve: Curves.linear);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      controller: _controller,
      itemBuilder: (buildContext, index) {
        if (index < widget.count) {
          return widget.itemBuilder(buildContext, index);
        } else {
          return widget.itemBuilder(buildContext, 0);
        }
      },
      itemCount: widget.count + 1,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _timer.cancel();
  }
}

```

**_2.按功能分类_**

> **1.布局类 Widget：** 控制子 Widget 的排列方式。

```
常见有：
Row/Column：水平/垂直排列子项（基于 Flexbox）。
Stack：子 Widget 堆叠（类似 CSS 的绝对定位）。
Expanded/Flexible：在 Row 或 Column 中分配剩余空间。
Container：结合布局、装饰、边距等功能

```

> **2.基础组件 Widget：** 构成 UI 的基本元素。

```
常见有：
Text：显示文本。
Image：加载本地或网络图片。
Icon：显示图标（需引入 cupertino_icons 或自定义图标库）

```

> **3.滚动类 Widget：** 处理内容超出屏幕时的滚动行为。

```
常见有：
ListView：垂直/水平滚动列表。
GridView：网格布局滚动视图。
SingleChildScrollView：包裹单个可滚动子组件。

```

> **4.交互类 Widget：** 响应用户输入事件。

```
常见有：
ElevatedButton/TextButton：按钮交互。
TextField：文本输入框。
Checkbox/Switch：选择控件。
GestureDetector：自定义手势检测（点击、长按、拖动）。

```

> **5.平台风格类 Widget：** 适配不同操作系统的视觉风格。

```
常见有：
Material Design：MaterialApp、AppBar、FloatingActionButton。
Cupertino（iOS 风格）：CupertinoApp、CupertinoNavigationBar、CupertinoPicker。

```

> **6.动画类 Widget：** 实现动态视觉效果。

```
常见有：
AnimatedContainer：自动过渡的容器（大小、颜色等属性变化）。
Hero：页面切换共享元素的过渡动画。
AnimatedBuilder：自定义复杂动画。

```

> **7. 导航与路由类 Widget：** 管理页面跳转和导航结构。

```
常见有：
Navigator：管理页面堆栈（push/pop）。
PageView：实现滑动切换页面。
BottomNavigationBar：底部导航栏。

```

> 通过简单 Widget 组合实现复杂 UI（例如用 Row + Expanded 替代自定义布局）(优先组合而非继承)
> 局部状态使用 StatefulWidget
> 全局状态使用状态管理工具（如 Provider、Riverpod）
> 对频繁更新的部分使用 const 构造函数
> 长列表使用 ListView.builder 懒加载

## 3.Widget 生命周期

**StatelessWidget 的生命周期**

> StatelessWidget 仅有一个 build() 方法，无状态管理逻辑，其生命周期完全由父组件控制。

**StatefulWidget 主要生命周期方法**

> 创建阶段
> createState()

> 初始化阶段
> initState()
> didChangeDependencies()

> 更新阶段
> didUpdateWidget(oldWidget)
> build()

> 销毁阶段
> deactivate()
> dispose()

![2025-05-22 18.38.22.png](https://i-blog.csdnimg.cn/img_convert/a33469c55f94b5278f698d8605d8e0cc.webp?x-oss-process=image/format,png)

**1.createState()**
当 StatefulWidget 被插入 Widget 树时调用，而且只执行一次。

> 主要用于创建与之关联的 State 对象（每个 Widget 对应一个 State 实例）。

```
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

```

**2.initState()**
在 State 对象创建后，首次调用 build() 之前触发该方法，而且只执行一次。

> 主要用于初始化依赖数据（如订阅事件、加载本地配置）和 创建动画控制器（AnimationController）等需与 dispose() 配对的资源。

```
@override
void initState() {
  super.initState();
  _controller = AnimationController(vsync: this);
  _fetchData(); // 初始化数据
}

```

需要注意的是：
`必须调用 super.initState()。`
`在这里 View 并没有渲染，只是 StatefulWidget 被加载到渲染树里了。`
`避免在此处触发 setState（可能导致渲染未完成）。`
`StatefulWidget的 mount 的值变为了true（调用dispose()才会变为 false）。`

**3.didChangeDependencies()**
initState() 后立即调用 didChangeDependencies()。
当 State 依赖的 InheritedWidget 发生变化时（如主题、本地化）也会调用 didChangeDependencies()。

> 主要用于处理依赖变化后的逻辑（如重新请求网络数据）。

```
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  if (Provider.of<Data>(context).hasChanged) {
    _updateData();
  }
}

```

**4. didUpdateWidget(oldWidget)**
在父组件重建时，若新旧 Widget 的 runtimeType 和 key 相同触发 didUpdateWidget（didUpdateWidget 我们一般不会用到）。

> 主要是：
> 对比新旧 Widget 的配置（如属性变化）。
> 根据变化调整状态（如重置动画、更新监听）。

```
@override
void didUpdateWidget(MyWidget oldWidget) {
  super.didUpdateWidget(oldWidget);
  if (oldWidget.color != widget.color) {
    _updateColor(); // 颜色变化时执行逻辑
  }
}

```

**5. build()**
初始化后、依赖变化后、setState() 调用后调用 build()。
父组件或祖先组件触发重建时调用 build()。

> 主要是根据当前状态构建 UI（不要在这里做除了创建 Widget 之外的操作）

```
@override
Widget build(BuildContext context) {
  return Container(
    color: widget.color,
    child: Text('Count: $_count'),
  );
}

```

需要注意的是：
`必须返回一个 Widget`
`避免在此处修改状态或执行耗时操作`

**6. deactivate()**
当 State 从树中暂时移除（如页面切换、组件被移除）触发 deactivate()。

> 清理临时资源或保存临时状态.

需要注意的是：
`可能被重新插入树中（如页面返回时），需与 dispose() 区分`

**7. dispose()**
State 被永久移除时调用 dispose()。

> 释放资源（如取消网络请求、销毁动画控制器）

```
@override
void dispose() {
  _controller.dispose(); // 销毁动画控制器
  _subscription.cancel(); // 取消事件订阅
  super.dispose();
}

```

需要注意的是：
`如果在 dispose() 中未释放资源（如动画控制器、Stream 订阅）可能造成内存泄漏`
`如果在 dispose() 后调用 setState 会导致异常`

## 4.Widget 的渲染

**渲染流程：**
Flutter 的渲染系统基于三棵核心树结构，通过高度优化的管线（Pipeline）实现高效的 UI 更新。

> **Widget 重建 → Diff 新旧 Widget 树 → 更新 Element 树 → 更新 RenderObject 树 → 触发 Layer 合成 → 屏幕刷新**

**1.Widget 树的构建：**

> 描述 UI 的不可变配置，由开发者创建，频繁重建，需轻量化。
> 开发者编写的 Widget 代码被转化为嵌套的 Widget 树（应用的入口是根 Widget，一般是 MaterialApp 或 CupertinoApp。根 Widget 会递归地构建其子 Widget，形成一棵树。）。
> 具有不可变性，每次重建生成全新的 Widget 树，但通过 Diff 算法可以优化实际更新范围。

**2. Element 树的 Diff 与更新**

> 根据 Widget 树生成一个 Element 树，Element 树中的节点都继承自 Element 类。
> Element 是 Widget 的实例化对象，负责管理 状态（State） 和 子节点引用。
> 每个 Widget 都会有一个对应的 Element 对象，用于管理其生命周期。

> Diff 算法：Flutter 对比新旧 Widget 树，仅更新变化的 Element 和 RenderObject，类似 React 的虚拟 DOM。
> 当 Widget 树重建时，Flutter 通过 Diff 算法 对比新旧 Widget 树，决定 Element 树的更新策略
> Reuse：若新旧 Widget 的 runtimeType 和 key 相同，复用现有 Element。
> Update：更新 Element 的配置（调用 Element.update(newWidget)）。
> Replace：类型或 Key 不同时，销毁旧 Element，创建新 Element。

```
// 旧 Widget 树
Container(color: Colors.red)

// 新 Widget 树
Container(color: Colors.blue)

// Diff 结果：Container 类型相同且无 Key → 复用 Element，更新 RenderObject 颜色

```

```
// Element 更新逻辑
Element.updateChild()

Element updateChild(Element child, Widget newWidget, dynamic newSlot) {
  if (newWidget == null) {
    // 移除子节点
    return null;
  }
  if (child != null) {
    if (child.widget == newWidget) {
      // Widget 未变化 → 复用 Element
      return child;
    }
    if (Widget.canUpdate(child.widget, newWidget)) {
      // 更新 Element 配置
      child.update(newWidget);
      return child;
    }
    // 销毁旧 Element，创建新 Element
    deactivateChild(child);
  }
  return inflateWidget(newWidget, newSlot);
}

```

**3. RenderObject 树的更新**

更新 RenderObject 树，计算布局和生成绘制指令。
运行在 UI Thread。

> 根据 Element 树生成 Render 树（渲染树），渲染树中的节点都继承自 RenderObject 类。
> 每个 Element 对应一个 RenderObject（通过 Element.createRenderObject() 创建）。

> 根据父 RenderObject 传递的 约束（Constraints），计算自身尺寸和位置。
> 递归调用子节点的 layout() 方法（深度优先遍历）。

**布局（Layout）核心方法：**

```
// RenderObject 布局流程
RenderObject.layout()

void layout(Constraints constraints, { bool parentUsesSize = false }) {
  _constraints = constraints;
  if (_relayoutBoundary != this) {
    markNeedsLayout();
    return;
  }
  performLayout();  // 1. 计算自身尺寸（调用 performLayout） 由子类实现具体布局逻辑
  _needsLayout = false;
  markNeedsPaint(); // 标记需要重绘
}

```

> 生成绘制指令（如形状、颜色、文本），写入 Layer（合成层）。

**绘制（Paint）核心方法:**

```
void paint(PaintingContext context, Offset offset) {
  // 绘制逻辑，如画矩形
  context.canvas.drawRect(rect, paint);
}

```

**4. 合成与光栅化（Composition & Rasterization）**

生成 Layer 树并光栅化。
运行在 Raster Thread（与 UI Thread 并行）

> 根据渲染树生成 Layer 树，然后上屏显示，Layer 树中的节点都继承自 Layer 类。
> RenderObject 的绘制结果被组织为 Layer 树，每个 Layer 对应一个 GPU 纹理（Texture）。自此 Layer 树生成。
> 类型包括：PictureLayer（矢量绘制）、TextureLayer（图像纹理）、TransformLayer（变换效果）等。

> 将 Layer 树中的绘制指令转换为 GPU 可识别的位图数据。
> 通过 Skia 图形库（或 Impeller）完成，最终提交给 GPU 渲染。（完成光栅化（Raster Thread））。

```
void paintChild(RenderObject child, Offset offset) {
  if (child.isRepaintBoundary) {
    // 创建独立 Layer
    stopRecordingIfNeeded();
    child._layer = OffsetLayer();
    appendLayer(child._layer);
  } else {
    child._paintWithContext(this, offset);
  }
}

```

**5. GPU 渲染与屏幕刷新**

> **垂直同步（VSync）：**
> 由系统定时触发的信号，控制帧率（如 60Hz → 16.6ms/帧）。
> Flutter 引擎在 VSync 信号到来时，提交光栅化后的帧数据到 GPU。

> **屏幕显示：**
> GPU 将帧数据写入帧缓冲区（Frame Buffer），屏幕硬件按刷新率读取并显示。

## 5.Widget 优化

`高性能渲染 = 最小化 Widget Diff + 高效布局/绘制 + GPU 线程优化`

> Flutter 优化的本质是 减少无效计算 和 降低 GPU 负载
> 一般围绕四个方向： 1.最小化 Widget 树 Diff 范围 2.减少布局（Layout）和绘制（Paint）计算 3.优化 GPU 合成与光栅化（Rasterization） 4.高效管理状态与资源

> **性能分析工具**
> Flutter DevTools：
> Performance 面板：分析 UI/Raster 线程的帧耗时。
> Layer 查看器：检测 Layer 合成是否合理。
> debugProfileBuildsEnabled：追踪 Widget 构建耗时
> 调试标记：
> debugPrintMarkNeedsLayoutStacks：打印触发布局的堆栈信息。
> debugPaintLayerBordersEnabled：可视化 Layer 边界。

**1.Widget 树 Diff 优化**

> **Diff 算法机制：** 当父组件更新时，Flutter 递归对比新旧 Widget 树，判断是否需要更新 Element 和 RenderObject。

```
static bool canUpdate(Widget oldWidget, Widget newWidget) {
  return oldWidget.runtimeType == newWidget.runtimeType
      && oldWidget.key == newWidget.key;
}

```

> **复用条件：** runtimeType 和 key 相同 → 复用 Element，仅更新配置。
> **替换条件：** 类型或 Key 不同 → 销毁旧 Element，创建新 Element。

**优化策略：**
**1.使用 const 构造函数：** const Widget 在多次重建中引用同一内存地址，Widget.canUpdate 直接返回 true，跳过 Diff 计算。

```
const MyWidget(text: 'Hello'); // ✅ 优化
MyWidget(text: 'Hello');      // ❌ 非 const

```

**2.合理使用 Key：** ValueKey：在列表项中标识唯一性，避免错误复用导致状态混乱。
GlobalKey：跨组件访问状态（谨慎使用，破坏局部性）。

```
ListView.builder(
  itemBuilder: (_, index) => ItemWidget(
    key: ValueKey(items[index].id), // 唯一标识
    data: items[index],
  ),
)

```

**3.拆分细粒度 Widget：** 将频繁变化的部分拆分为独立 Widget，缩小 setState 触发的 Diff 范围。

```
// 父组件（仅传递静态数据）
class ParentWidget extends StatelessWidget {
  const ParentWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const StaticHeader(), // 静态部分
        DynamicContent(data: _data), // 动态部分
      ],
    );
  }
}

```

**2.布局（Layout）阶段优化**

> **布局计算机制：** 当某个 RenderObject 的尺寸变化不影响父节点布局时，可标记为布局边界，阻断布局计算向上传播。通过 RenderObject.isRepaintBoundary = true 设置（布局边界（Relayout Boundary））

> 父节点传递 约束（Constraints） 给子节点
> 子节点根据约束计算自身尺寸，并递归布局子节点(布局过程)

**优化策略**

> **1.避免过度嵌套：** 多层 Row/Column 会导致布局计算复杂度呈指数增长。
> 我们可以使用 Flex、Wrap 或自定义布局逻辑替代嵌套。

> **2.预计算尺寸：** 通过固定尺寸（SizedBox）或 LayoutBuilder 提前确定布局约束，减少计算量。

```
SizedBox(
  width: 100,
  height: 50,
  child: Text('Fixed Size'),
)

```

> **3.使用 IntrinsicWidth/IntrinsicHeight 的替代方案：** IntrinsicWidth 会触发多次子节点布局计算，性能低下。
> 我们可以手动计算子节点最大宽度，使用 ConstrainedBox 限制尺寸。

**3.绘制（Paint）阶段优化**

> **绘制机制：** 当 RenderObject 的视觉属性（如颜色、位置）变化时，调用 markNeedsPaint() 标记需要重绘。

> **合成层（Layer）：** 每个 RenderObject 的绘制结果被组织为 Layer 树，最终由 GPU 光栅化。（PictureLayer（矢量绘制）、TextureLayer（图像）、TransformLayer（变换））。

**优化策略**

> **1.使用 RepaintBoundary：** 将独立变化的 UI 部分包裹 RepaintBoundary，生成独立 Layer，减少重绘区域。
> 通过 RenderObject.isRepaintBoundary = true 标记。

```
RepaintBoundary(
  child: MyAnimatedWidget(), // 独立重绘区域
)

```

> **2.避免高开销绘制操作：** 使用 AnimatedOpacity 或直接设置颜色透明度（Color.withOpacity）替代 Opacity 。
> 优先使用 ClipRect 或 ClipRRect，减少路径裁剪的计算量。

> **3.自定义绘制优化：** 在 CustomPainter 中精确控制重绘条件。

```
class MyPainter extends CustomPainter {
  @override
  bool shouldRepaint(MyPainter old) {
    return old.color != color; // 仅颜色变化时重绘
  }
}

```

**4.GPU 合成与光栅化优化**

> **1.光栅化机制：** 通过上面的合成与光栅化可知道：光栅化运行在独立的 Raster Thread，与 UI Thread 并行。
> Flutter 自动复用未变化的 Layer 对应的 GPU 纹理，减少数据传输。（纹理（Texture）复用）

**优化策略**

> **1.减少 Layer 数量：** 过多的 Layer 会增加 GPU 合成开销，我们需要尽可能的合并相邻的 PictureLayer，避免不必要的 Opacity 或 Transform 嵌套。

> **2.使用硬件加速操作：** 利用 GPU 的矩阵变换硬件加速（Transform 替代手动矩阵计算）。
> 对重复使用的图片提前解码（precacheImage） （Image 预加载）。

> **3.启用 Impeller 引擎：** Flutter 3.0+ 引入的 Impeller 引擎针对 GPU 负载优化，减少光栅化抖动。

**5.状态管理与资源优化**

> **1.状态管理：**
> 局部状态：使用 StatefulWidget 管理，确保 dispose() 释放资源。
> 全局状态：采用 Provider、Riverpod 或 Bloc，避免状态穿透和冗余重建。

> **2.资源释放：**
> 必须释放动画控制器（AnimationController.dispose()）、Stream 订阅（Subscription.cancel()）等资源。

```
@override
void dispose() {
  _controller.dispose();
  _streamSubscription.cancel();
  super.dispose();
}

```

![2025-05-23 14.45.52.png](https://i-blog.csdnimg.cn/img_convert/58ae194fbfc28292a73f2130d949f78a.webp?x-oss-process=image/format,png)
