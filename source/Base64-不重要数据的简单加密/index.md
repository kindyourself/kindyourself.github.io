---
layout: '[layout]'
title: Base64-不重要数据的简单加密
date: 2016-07-09 20:31:41
tags: [“Base64”, “加密”]
categories: "iOS"
---

###导语
>  最近公司要求对服务器的token等参数进行一个简单的加密，防止恶意请求。要求加密过程自定义，于是就想到了用base64，其实这不是一个加密解密的算法，其实它就是使用64个字符来对任意数据进行编码解码的，具体底层实现原理就不讨论了，它是随着iOS7推出的。

##我的实现过程（可以根据公司需求自定义）：
1.先编码一次
2.对编码结果的数据交换首位字符在编码一次
3.对编码结果逆序在编码一次

##示例代码
```
+(NSString *)base64EncodedString:(NSString *)string {
Base64Encoding *base64 = [[Base64Encoding alloc] init];
   
    // 1次
    NSString *encrypt1 = [base64 base64EncodedString:string];
    // 交换字符串首位次序
    NSString *string1 = [base64 changeStringFirsrAndLast:encrypt1];
    
    // 2次
    NSString *encrypt2 = [base64 base64EncodedString:string1];
    // 交换字符串首位次序
    NSString *string2 = [base64 changeStringOrder:encrypt2];
    
    // 3次
    NSString *encrypt3 = [base64 base64EncodedString:string2];
    
    return encrypt3;
}
// 添加逗号
- (NSString *)addSeparaedSingle:(NSString *)string {
    NSMutableString *mutableString = [string mutableCopy];
    NSInteger cont = mutableString.length;
    for (int i = 0; i < cont - 1; i ++) {
        [mutableString insertString:@"," atIndex:2 * i + 1];
    }
    return mutableString;
}
// 去掉逗号
- (NSString *)removeSeparaedSingle:(NSString *)string {
   return [string stringByReplacingOccurrencesOfString:@"," withString:@""];
}
// 字符串转数组
- (NSMutableArray *)stringChangeArray:(NSString *)string {
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:[string componentsSeparatedByString:@","]];
    return mutableArray;
}
// 数组转字符串
- (NSString *)arrayChangeString:(NSArray *)array {
    return [array componentsJoinedByString:@","];
}
// 字符串交换首尾
- (NSString *)changeStringFirsrAndLast:(NSString *)string {
    NSString *str = [self addSeparaedSingle:string];
    NSMutableArray *mutableArray = [self stringChangeArray:str];
    NSString *temp = mutableArray[0];
    mutableArray[0] = mutableArray[mutableArray.count - 1];
    mutableArray[mutableArray.count - 1] = temp;
    NSString *arrayString = [self arrayChangeString:mutableArray];
    return [self removeSeparaedSingle:arrayString];
}
// 字符串逆序
- (NSString *)changeStringOrder:(NSString *)string {
    NSString *str = [self addSeparaedSingle:string];
    NSMutableArray *mutableArray = [self stringChangeArray:str];
    NSArray *reversedArray = [[mutableArray reverseObjectEnumerator] allObjects];
    NSString *arrayString = [self arrayChangeString:reversedArray];
    return [self removeSeparaedSingle:arrayString];
}
// 编码
- (NSString *)base64EncodedString:(NSString *)string {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [data base64EncodedStringWithOptions:0];
}
```
###结束语：
  这个可以根据公司的要求跟后台写的好加密的规则，解密就交给后台了，```方法：initWithBase64EncodedData``` 采用逆向规则解密即可，当然这个是极其容易被破解的，涉及敏感数据是不可使用这个方法的。