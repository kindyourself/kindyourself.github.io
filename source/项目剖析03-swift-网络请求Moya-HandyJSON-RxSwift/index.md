---
layout: '[layout]'
title: 项目剖析03-swift 网络请求Moya+HandyJSON+RxSwift
date: 2019-12-23 16:39:52
tags: [“swift”, “网络请求”, “Moya”, “HandyJSON”, “RxSwift”]
categories: "swift"
---


>项目第一版网络框架用的是[siesta](https://github.com/bustoutsolutions/siesta),它的缓存与自动刷新确实很好用而且代码很简洁，但是在文件的上传与下载以及对返回类型需要精确匹配要求这方面就很不友好，所以在第二版的我选择了[Moya](https://github.com/Moya/Moya),它是一个网络抽象层，它在[Alamofire](https://github.com/Alamofire/Alamofire)基础上提供了一系列的抽象接口方便维护。关于`Moya`的使用介绍很多，我就不再赘述了。我主要记录一下我在使用过程中学到的处理方式。我的网络框架是搭着[HandyJSON](https://github.com/alibaba/HandyJSON)和[RxSwift](https://github.com/Moya/Moya/blob/master/docs/RxSwift.md)一起构建的。

### 1 Moya
- 1 代码
```
import Foundation
import enum Result.Result
import Alamofire

//设置请求超时时间
private let requestTimeoutClosure = { (endpoint: Endpoint, done: @escaping MoyaProvider<ApiManager>.RequestResultClosure) in
    do {
        var request = try endpoint.urlRequest()
        request.timeoutInterval = 60
        done(.success(request))
    } catch {
        return
    }
}
let ApiManagerProvider = MoyaProvider<ApiManager>(endpointClosure: endpointMapping, requestClosure: requestTimeoutClosure, plugins:[])

// MARK: 取消所有请求
func cancelAllRequest() {
    WTOtherProvider.manager.session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
        dataTasks.forEach { $0.cancel() }
        uploadTasks.forEach { $0.cancel() }
        downloadTasks.forEach { $0.cancel() }
    }
    
    WTLoginProvider.manager.session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
        dataTasks.forEach { $0.cancel() }
        uploadTasks.forEach { $0.cancel() }
        downloadTasks.forEach { $0.cancel() }
    }
    ……
 }

public func endpointMapping<Target: TargetType>(target: Target) -> Endpoint {
    WTDLog("请求连接：\(target.baseURL)\(target.path) \n方法：\(target.method)\n参数：\(String(describing: target.task.self)) ")
    return MoyaProvider.defaultEndpointMapping(for: target)
}

final class RequestAlertPlugin: PluginType {
    
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        return request
    }
    
    func willSend(_ request: RequestType, target: TargetType) {
        //实现发送请求前需要做的事情
    }
    
    public func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {

        switch result {
        case .success(let response):
            guard response.statusCode == 200 else {
                if response.statusCode == 401 {
                    if isJumpLogin == false {
                        cancelAllRequest()
                        // 退出登录
                        if let nvc = (WTNavigationManger.Nav as? WTMainViewController) {
                            nvc.login()
                        }
                    }
                }
                return
            }
            var json = try? JSON(data: response.data)
            WTDLog("请求状态码\(json?["status"] ?? "")")
            
            guard let codeString = json?["status"] else {return}
             if codeString == 401 {// 退出登录
                if isJumpLogin == false {
                    cancelAllRequest()
                    if let nvc = (WTNavigationManger.Nav as? WTMainViewController) {
                        nvc.login()
                    }
                }
                break
            }

        case .failure(let error):
            WTDLog(error)
            let myAppdelegate = UIApplication.shared.delegate as! AppDelegate
            myAppdelegate.listenNetwork()
            break
        }
    }
}

struct AuthPlugin: PluginType {
    let token: String
}


enum ApiManager {
}

extension ApiManager: TargetType {
    var headers: [String : String]? {
        var dict = ["ColaLanguage": ("common.isChinese".L() == "YES") ? "CN" : "EN"]
        if let authToken =  WTLoginInfoManger.shareDataSingle.model?.accessToken {
            dict["Authorization"] = authToken
        }
        return dict
    }
    
    var baseURL: URL {
        return URL.init(string: AppURLHOST.MyPublicBaseURL)!
    }
    
    var path: String {
        return ""
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        return .requestPlain
    }
    
    var validate: Bool {
        return false
    }
    var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
}
/// 数据 转 模型
extension ObservableType where E == Response {
    public func mapHandyJsonModel<T: HandyJSON>(_ type: T.Type) -> Observable<T> {
        return flatMap { response -> Observable<T> in
            return Observable.just(response.mapHandyJsonModel(T.self))
        }
    }
}
/// 数据 转 模型
extension Response {
    func mapHandyJsonModel<T: HandyJSON>(_ type: T.Type) -> T {
        let jsonString = String.init(data: data, encoding: .utf8)
        if let modelT = JSONDeserializer<T>.deserializeFrom(json: jsonString) {
            return modelT
        }
        return JSONDeserializer<T>.deserializeFrom(json: "{\"msg\":\"\("common.try".L())\"}")!
    }
}

/// 自定义插件
public final class NetworkLoadingPlugin: PluginType {
    public func willSend(_ request: RequestType, target: TargetType) {
    }
    public func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
    }
}
```
- 2 模式Target -> Endpoint -> Request
![来自GitHub图片](https://i-blog.csdnimg.cn/blog_migrate/24422c24f3f5cf628f45d967e4ec09c9.png)

`Moya`虽然是基于Alamofire的但是我们在代码中却不会和Alamofire打交道，它是通过枚举来管理API的。我在项目中定义来一个API基类，然后为每一个模块定义了一个API管理类。
```
enum HomeApiManager {
    case getBanner // 获取轮播
    case getAnnouncement(per_page: String) // 获取公告
}
```
对于请求类型的改变和对于URL的改变也是通过枚举
```
var method: Moya.Method {
        switch self {
        case .orderCreate:
            return .post
        case .orderCancelById, .orderCancelByPair:
            return .delete
        default:
            return .get
        }
    }

var path: String {
        switch self {
        case .getKline:
            return "/api/kline"
        case .transGetByID(let orderId):
            return "/api/\(orderId)"
        }
    }
```
请求任务
```
    var task: Task {
        switch self {
        case .securityPostGoogleAuth(let tokenKey, let oldGoogleCode, let googleCode, let captcha):
            return .requestParameters(parameters: ["captcha": captcha], encoding: JSONEncoding.default) // post请求

        case .getReward(let type, let cursor, let limit):
            return .requestParameters(parameters: ["type": type], encoding: URLEncoding.default) // 其它请求

        case .uploadImage(let imageArry):
            let formDataAry:NSMutableArray = NSMutableArray()
            for (index,image) in imageArry.enumerated() {
                //图片转成Data
                let data:Data = image.jpegData(compressionQuality: 0.7)!
                //根据当前时间设置图片上传时候的名字
                var dateStr: String = "yyyy-MM-dd-HH:mm:ss".timeStampToString(timeStamp: Date().timeIntervalSince1970)
                //别忘记这里给名字加上图片的后缀哦
                dateStr = dateStr.appendingFormat("-%i.jpg", index)
                let formData = MultipartFormData(provider: .data(data), name: "file\(index)", fileName: dateStr, mimeType: "image/jpeg")
                formDataAry.add(formData)
            }
            return .uploadCompositeMultipart(formDataAry as! [MultipartFormData], urlParameters: [
                :])
            
        default:
            return .requestPlain
        }
    }
```
- 3 插件机制
`Moya`的另一个强大的功能就是它的插件机制，提供了两个接口，willSendRequest 和 didReceiveResponse，它可以在请求前和请求后做一些额外的操作而和主功能是解耦的，比如可以在请求前开始加载动画请求结束后移除加载动画，还可以自定义插件。
```
final class RequestAlertPlugin: PluginType {
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        return request
    }
    func willSend(_ request: RequestType, target: TargetType) {
        现发送请求前需要做的事情
        if target.headers?["isHiddentLoading"] != "true" {
            currentView?.addSubview(activityIndicatorView)
            activityIndicatorView.center = currentView!.center
            activityIndicatorView.startAnimating()
        }
    }
    public func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        if activityIndicatorView.isAnimating {
            activityIndicatorView.stopAnimating()
            activityIndicatorView.removeFromSuperview()
        }
    }
}

/// 自定义插件
public final class NetworkLoadingPlugin: PluginType {
    public func willSend(_ request: RequestType, target: TargetType) {
    }
    public func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
    }
}
```
Moya默认有4个插件
1. AccessTokenPlugin    // 管理AccessToken的插件
2. CredentialsPlugin       // 管理认证的插件
3. NetworkActivityPlugin // 管理网络状态的插件
4. NetworkLoggerPlugin // 管理网络log的插件

### 3 RxSwift
这里的RxSwift不是完整的RxSwift，而是为Moya定制的一个扩展(pod 'Moya/RxSwift')在数据请求回来后进行处理。
1. request()  传入API
2. asObservable() 是Moya为RxSwift提供的扩展方法，返回可监听序列
3. mapHandyJsonModel() 也是Moya RxSwift的扩展方法进行自定义的，可以把返回的数据解析成model
4. subscribe() 是对处理过的 Observable 订阅一个 onNext 的观察者，一旦得到JSON格式的数据，就会经行相应的处理
5. disposed() 是RxSwift的一个自动内存处理机制，类似ARC，会自动处理不需要的对象
```
/// 数据 转 模型
extension ObservableType where E == Response {
    public func mapHandyJsonModel<T: HandyJSON>(_ type: T.Type) -> Observable<T> {
        return flatMap { response -> Observable<T> in
            return Observable.just(response.mapHandyJsonModel(T.self))
        }
    }
}
/// 数据 转 模型
extension Response {
    func mapHandyJsonModel<T: HandyJSON>(_ type: T.Type) -> T {
        let jsonString = String.init(data: data, encoding: .utf8)
        if let modelT = JSONDeserializer<T>.deserializeFrom(json: jsonString) {
            return modelT
        }
        return JSONDeserializer<T>.deserializeFrom(json: "{\"msg\":\"\("common.try".L())\"}")!
    }
}
extension WTApiManager {
    class func NetExchangeRequest<T: BaseModel>(disposeBag: DisposeBag,type: ExchangeApiManager, model: T.Type, isBackFail: Bool = false, Success:@escaping (T)->(), Error: @escaping ()->()) {
        WTExchangeProvider.rx.request(type)
            .asObservable()
            .mapHandyJsonModel(model)
            .subscribe { (event) in
                switch event {
                case let .next(data):
                    if isBackFail {
                        Success(data)
                        break
                    }
                    guard data.status == 200 else {
                        WTProgressHUD.show(error: data.message ?? "common.try".L(), toView: nil)
                        Error()
                        break
                    }
                    Success(data)
                    break
                case let .error(error):
                    WTDLog(error)
                    Error()
                    break
                default:
                    break
                }
            }.disposed(by: disposeBag)
    }
}
```

### 4 HandyJSON
```
class BaseModel: HandyJSON {
    var status: Int = 0
    var message: String? = nil // 服务端返回提示
    required init(){}
}

class WTBaseModel<T: HandyJSON>: BaseModel {
    var data: T? // 具体的data的格式和业务相关，故用泛型定义
}
struct WTCurrencyBalanceModel: HandyJSON {
    var coinCode: String = ""
    let balanceAvailable: Double = 0.0
    let balanceFrozen: Double = 0.0
    let worth: Double = 0.0
}
// 网络请求 传入对应model
WTApiManager.NetOtherRequest(disposeBag: disposeBag, type: .getMarketsPrice, model: WTBaseModel<WTRateModel>, Success: {(model) in
}) {}
```

### 5 以上就是我在项目中使用`Moya+HandyJSON+RxSwift`的方法，如果有错误或者不足之处还望指正，谢谢

