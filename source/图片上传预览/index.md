---
layout: '[layout]'
title: 图片上传预览
date: 2016-08-01 01:06:42
tags: [“web”, “图片上传”, “预览”]
categories: "web"
---

>本周帮一哥们写了一个页面遇到了一些问题，特此记录一下。主要遇到的问题是图片上传预览（多个上传控件）、多个颜色选择，遇到了冲突。

![来个效果一撇 2016-08-01 00.13.22.png](https://i-blog.csdnimg.cn/blog_migrate/236f8ed15fd552d48cf2c3287edd9c53.webp?x-image-process=image/format,png)

一、这是代码上传的HTML部分代码

```
<div id="home11" class="tab-pane in active lowerContent ">
									<div class="tool floatLeft">
										<span class="spanStylef floatLeft">名称</span>
										<input type="text" name="appName">
									</div>

									<div class="upImage floatLeft">
										<div class="tool floatLeft">
											<span class="spanStylef floatLeft">默认图标</span>
											<a href="javascript:;" class="file" onchange="javascript:setImagePreview(2);">上传图片
												<input type="file" name="imagereview2" class ="inputImages">
											</a>
										</div>

										<div class="tool floatLeft">
											<span class="spanStylef floatLeft">&nbsp</span>
											<img class="imagereview2" width="100" height="100" />
										</div>
									</div>

									<div class="upImage floatLeft">
										<div class="tool floatLeft">
											<span class="spanStylef floatLeft">触及图标</span>
											<a href="javascript:;" class="file" onchange="javascript:setImagePreview(3);">上传图片
												<input type="file" name="imagereview3" class ="inputImages">
											</a>
										</div>

										<div class="tool floatLeft">
											<span class="spanStylef floatLeft">&nbsp</span>
											<img class="imagereview3" width="100" height="100" />
										</div>
									</div>
								</div>
```
二、修改上传按钮的部分css代码
 ```
.file {
    position: relative;
    display: inline-block;
    background: #D0EEFF;
    border: 1px solid #99D3F5;
    border-radius: 4px;
    padding: 4px 12px;
    overflow: hidden;
    color: #1E88C7;
    text-decoration: none;
    text-indent: 0;
    line-height: 20px;
}
.file input {
    position: absolute;
    font-size: 100px;
    right: 0;
    top: 0;
    opacity: 0;
}
.file:hover {
    text-decoration: none;
}
```
三、这是JS部分的代码
 ```
 function setImagePreview(avalue) {
                //input
                var docObjs = document.getElementsByClassName("inputImages");
                var docObj = docObjs[avalue];
                if (docObj.files && docObj.files[0]) {
                    var imgObjPreviews = document.getElementsByClassName(docObj.name);
                    var imgObjPreview = imgObjPreviews[0];
                if (avalue == 0) {
                    imgObjPreview.style.display = 'block';
                    imgObjPreview.style.width = '200px';
                    imgObjPreview.style.height = '350px';
                }else {
                    //火狐下，直接设img属性
                    imgObjPreview.style.display = 'block';
                    imgObjPreview.style.width = '100px';
                    imgObjPreview.style.height = '100px';
                }
                   imgObjPreview.src = window.URL.createObjectURL(docObj.files[0]);
                } else {
                    //IE下，使用滤镜
                    // docObj.select();
                    // var imgSrc = document.selection.createRange().text;
                    // var localImagId = document.getElementById("localImag");
                    // //必须设置初始大小
                    // localImagId.style.width = "100px";
                    // localImagId.style.height = "100px";
                    // //图片异常的捕捉，防止用户修改后缀来伪造图片
                    // try {
                    //     localImagId.style.filter = "progid:DXImageTransform.Microsoft.AlphaImageLoader(sizingMethod=scale)";
                    //     localImagId.filters.item("DXImageTransform.Microsoft.AlphaImageLoader").src = imgSrc;
                    // } catch(e) {
                    //     alert("您上传的图片格式不正确，请重新选择!");
                    //     return false;
                    // }
                    // imgObjPreview.style.display = 'none';
                    // document.selection.empty();
                }
                return true;
            }
```
>问题与解决：
问题一：是上传按钮默认的文件上传是这样的
![默认 2016-08-01 00.26.51.png](https://i-blog.csdnimg.cn/blog_migrate/247191efee00edfe40ac992ff86a4b93.webp?x-image-process=image/format,png)
但是我需要的是这样的：

![目标 2016-08-01 00.28.07.png](https://i-blog.csdnimg.cn/blog_migrate/b519bb3cae0f98c75720b46596facebb.webp?x-image-process=image/format,png)
解决方案：就是将fileAPI放在你需要的控件上面，然后将fileAPI设置为透明，然后点击你需要的控件其实就是点击了fileAPI。还有一个方案就是用js:将你的控件的点击事件里面的返回为fileAPI的事件。这样点击你的控件就完成了fileAPI事件了，（我想的，没有去实现喔）
问题二：点击事件冲突
一开始我是通过id选择器来标记image与input的,后来发现多个上传按钮就需要多个js判定，会有很多的重复代码。于是后来我改为了用类选择器但是类名一样无法将image与input对应。于是我将input的name与与image的类名写成一样，通过input的name找到对应的image。

#########NOTE：我前端开发很久没有弄了，很多忘记了，如有错误。请亲们一定要指出啊！

