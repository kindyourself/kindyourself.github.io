---
layout: '[layout]'
title: iOS-解压zip
date: 2016-07-09 20:31:07
tags: [“iOS”, “解压zip”]
categories: "iOS"
---

最近的项目中涉及到了将zip文件从服务上下载下来，然后解压使用。搜索了一下发现有一个压缩与解压zip文件的第三方“SSZipArchive”：https://github.com/ZipArchive/ZipArchive 是用C语言实现的，包装用于OC与swift.
##### 一、在使用过程中遇到过几个坑：
1. 导入头文件冲突，我在pch文件里面导入了一些OC的头文件，而SSZipArchive是由C语言实现的，所以报了很多的系统错误。解决办法：将pch里面的导入头文件代码放在
"#ifdef __OBJC__
//导入头文件     
"#endif 里面"
  或者删除里面导入头文件的代码，去具体需要的文件里面导入，有一点暴力哈。
2. 我每一次下载的文件样式都是一样的，所以希望覆盖式的解压，一开始没有注意以为它只有解压方法：+ (BOOL)unzipFileAtPath:(NSString *)path toDestination:(NSString *)destination;
就自己去判定是否存在然后删除，后来去仔细的看源码才发现它是有带是否覆盖式解压的方法：+ (BOOL)unzipFileAtPath:(NSString *)path toDestination:(NSString *)destination overwrite:(BOOL)overwrite password:(NSString *)password error:(NSError * *)error;
当然它还有很多方法，包括带有代理方法，带有密码，带有完成后的block回调方法，
http://blog.csdn.net/zhengang007/article/details/51019479
这里有每一个方法的详细说明。

##### 二、我的实现：
```
- (void)downFileFromServer{
//远程地址
NSURL *URL = [NSURL URLWithString:DOWN_URL];
//默认配置
NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//AFN3.0+基于封住URLSession的句柄
AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
//请求
NSURLRequest *request = [NSURLRequest requestWithURL:URL];
//下载Task操作
_downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
// 下载进度
} destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
//- block的返回值, 要求返回一个URL, 返回的这个URL就是文件的位置的路径
NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
NSString *path = [cachesPath stringByAppendingPathComponent:response.suggestedFilename];
return [NSURL fileURLWithPath:path];
} completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
//设置下载完成操作
// filePath就是你下载文件的位置，你可以解压，也可以直接拿来使用
NSString *imgFilePath = [filePath path];// 将NSURL转成NSString
MyLog(@"imgFilePath = %@",imgFilePath);
NSArray *documentArray =  NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
NSString *path = [[documentArray lastObject] stringByAppendingPathComponent:@"Preferences"];
[self releaseZipFilesWithUnzipFileAtPath:imgFilePath Destination:path];
}];
[_downloadTask resume];
}
// 解压
- (void)releaseZipFilesWithUnzipFileAtPath:(NSString *)zipPath Destination:(NSString *)unzipPath{
NSError *error;
if ([SSZipArchive unzipFileAtPath:zipPath toDestination:unzipPath overwrite:YES password:nil error:&error delegate:self]) {
MyLog(@"success");
MyLog(@"unzipPath = %@",unzipPath);
}else {
MyLog(@"%@",error);
}
}
#pragma mark - SSZipArchiveDelegate
- (void)zipArchiveWillUnzipArchiveAtPath:(NSString *)path zipInfo:(unz_global_info)zipInfo {
MyLog(@"将要解压。");
}
- (void)zipArchiveDidUnzipArchiveAtPath:(NSString *)path zipInfo:(unz_global_info)zipInfo unzippedPath:(NSString *)unzippedPat uniqueId:(NSString *)uniqueId {
MyLog(@"解压完成！");
}
```

  当然还得遵守协议：SSZipArchiveDelegate
  以上就是我使用SSZipArchive的体会，欢迎各位指正。