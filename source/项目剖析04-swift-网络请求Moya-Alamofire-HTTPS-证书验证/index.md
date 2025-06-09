---
layout: '[layout]'
title: 项目剖析04-swift 网络请求Moya+Alamofire(HTTPS)证书验证
date: 2024-03-05 16:02:13
tags: [“swift”, “证书验证”, “SSL”]
categories: "swift"
---


## SSL证书验证

&emsp;一种加强App 和 Server 间通讯安全的方法。主要目标是确保 App 仅与预先验证的 Server 建立安全连接，防止中间人攻击（Man-in-the-Middle，MitM）等安全风险。一般常用的有两种方式进行验证，Certificate Pinning和Public Key Pinning。

>Alamofire5.0 以后将证书验证类放于ServerTrustEvaluation这个类里面。一共有6种验证策略：
1. **DefaultTrustEvaluator** - （默认验证策略）只要是合法证书就能通过验证。
2. **RevocationTrustEvaluator**（验证注销策略）对注销证书做的一种额外设置，Alamofire从iOS10.1才开始支持吊销证书的策略。
3. **PinnedCertificatesTrustEvaluator**（证书验证策略）app端会对服务器端返回的证书和本地保存的证书中的全部内容进行校验需要全部正确，此验证策略还可以接受自签名证书，安全性相对较高，此方法较为固定，如果 Server 更新证书，App 需要定期更新并重新上架。
4. **PublicKeysTrustEvaluator**（公钥验证策略）app端只会对服务器返回的证书和本地保存的证书中的 PublicKey(公钥)进行校验，所以当证书需要更新时，只需确保公钥保持不变，不需要更新App。
5. **CompositeTrustEvaluator**（自定义组合验证策略）以上多种策略组合一起，只有在所有数组中值都成功时才成功。
6. **DisabledTrustEvalutor**（不验验证策略）无条件信任，所有都可以通过验证。正式环境不建议用此策略，多用于测试。

**我们用的是PublicKeysTrustEvaluator（公钥验证策略）**
* * *

> 1.后台提供证书，将正式放在项目目录中。

![本地证书存放](https://i-blog.csdnimg.cn/blog_migrate/d2b909e2935eccedbf88e97df824ecf9.png)
> 2.获取本地证书，提取证书的公钥（获取公钥key数组）。证书后缀名一般有：.cer、.crt、.der等，我项目中用的cer，证书链必须包含一个固定的公钥。

```
struct WTCertificates {
    static let rootCA = WTCertificates.certificate( )
    static func certificate() -> [SecKey] {
        var publicKeyArray:[SecKey] = []
        for resource in ["xxx", "xxxx", "xxxxx"] {// 本地证书名称
            if let filePath = Bundle.main.path(forResource: resource, ofType: "cer"), let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) as CFData, let certificate = SecCertificateCreateWithData(nil, data),let publicKey = certificate.af.publicKey {
                publicKeyArray.append(publicKey)
            }
        }
        return publicKeyArray
    }
}
```
> 3.给Session添加策略（接受质询）

```
var requestManagerSession: Session = {
    if WTCertificates.rootCA.count > 0, verifyCert {
        let certificates: [SecKey] = WTCertificates.rootCA
        let trustPolicy = PublicKeysTrustEvaluator(keys: certificates, performDefaultValidation: false, validateHost: false)
        let manager = ServerTrustManager(evaluators: [
            "xxx.xxx.com": trustPolicy,
            "xx.xx.jftplus.com": trustPolicy,
            "xxx.xx.com": trustPolicy])// base url 如何域名过多，可以子类化 ServerTrustManager，并用自己的自定义实现重写 serverTrustEvaluator(forHost:) 方法
        let configuration = URLSessionConfiguration.af.default
        return Session(configuration: configuration, serverTrustManager: manager)
    }
    return MoyaProvider<ApiManager>.defaultAlamofireSession()
}()
```

> 4.在Moya中添加requestManagerSession

```
var JKOtherApiManagerProvider = MoyaProvider<JKOtherApiManager>(endpointClosure: endpointMapping, requestClosure: requestTimeoutClosure, session:requestManagerSession, plugins:[RequestAlertPlugin(), networkPlugin])
```
>## OC HTTPS 证书配置验证
```
//1 将证书拖进项目

//2 获取证书路径
NSString *certPath = [[NSBundle mainBundle] pathForResource: @"cetus" ofType:@"cer"];
//3 获取证书data
NSData *certData = [NSData dataWithContentsOfFile:certPath];
//4 创建AFN 中的securityPolicy
AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModePublicKey withPinnedCertificates:[[NSSet alloc] initWithObjects:certData,nil]];
//5 这里就可以添加多个server证书
NSSet *dataSet = [[NSSet alloc]initWithObjects:certData, nil];
//6 绑定证书（不止一个证书）
[securityPolicy setPinnedCertificates:dataSet];
//7 是否允许无效证书
securityPolicy.allowInvalidCertificates = YES;
//8 是否需要验证域名
securityPolicy.validatesDomainName = YES;
uploadManager.securityPolicy = securityPolicy;
```
> 我们后台给的证书格式后缀是.pem，以下是用OpenSSL命令将.pem证书转换为cer格式证书方法

1. 打开命令行工具，进入存放xxx.pem证书的目录
2. 输入以下命令，将.pem证书转换为cer格式
```
openssl x509 -in xxx.pem -inform PEM -out xxx.cer -outform DER
```
3. 执行完毕后，您将在当前目录下看到生成的xxx.cer文件

>**注意：转换后的cer证书文件只包含公钥，不包含私钥信息**
