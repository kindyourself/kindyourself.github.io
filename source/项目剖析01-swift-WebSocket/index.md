---
layout: '[layout]'
title: 项目剖析01-swift WebSocket
date: 2019-12-23 10:00:16
tags: [“swift”, “WebSocket”]
categories: "swift"
---

>已经很长一段时间没有总结项目了，正好最近完成项目第二版的改版(新项目完全是用swift写的)，就把项目中一些有意义的知识块在此记录一下， 项目中有实时的交易需要展示，所以用到了socket长链接，我用的是[Starscream](https://github.com/daltoniam/Starscream)这个第三方库，集成方法很简单去网站看看就知道。

- ### 1 先上代码
```
import UIKit
import Reachability
import Starscream
import zlib

let reachability = Reachability()! // 判断网络连接
let webSocket = WTWebsocket.shared
var reConnectTime = 0 // 设置重连次数
let reConnectMaxTime = 1000 // 设置最大重连次数
let reConnectIntervalTime: TimeInterval = 15 // 设置重连时间间隔(秒)
var websocketTimer: Timer? = nil
var reConnectSubscribeDict:[String : Any] = [:]
var page = "home"
var isReconnect = true

final class WTWebsocket: NSObject,WebSocketDelegate {
    
    var isPingBack = true
    var myWebsocket: WebSocket? = nil
    //  socket连接上函数
    func websocketDidConnect(socket: WebSocketClient) {
        //设置重连次数，解决无限重连问题
        reConnectTime = 0
        if reConnectSubscribeDict.count > 0 {
            self.subscribe(subscribeDict: reConnectSubscribeDict)
        }
        self.hearJump()
        if  websocketTimer == nil {
            websocketTimer = Timer.scheduledTimer(timeInterval: reConnectIntervalTime, target: self, selector: #selector(sendBrandStr), userInfo: nil, repeats: true)
        }
        isReconnect = true
    }
    //发送文字消息
    @objc func sendBrandStr(){
        self.checkPing()
        let json = getJSONStringFromDictionary(dictionary: ["topic":"PING"])
        SingletonSocket.sharedInstance.socket.write(string: json)
    }
    // 发送ping
    func hearJump() {
        let json = getJSONStringFromDictionary(dictionary: ["topic":"PING"])
        SingletonSocket.sharedInstance.socket.write(string: json)
    }
    //  socket断开执行函数
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        //执行重新连接方法
        socketReconnect()
    }
    //  接收返回消息函数
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
    }
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        guard let newStr = String(data: data.gzipUncompress(), encoding: .utf8) else {return}
        if newStr == "PONG" {
            isPingBack = true
            return
        }
      // 处理收到的信息
    }
    // 添加注册
    func subscribe(subscribeDict: [String : Any]) {
        var subscribeDicts = subscribeDict
        reConnectSubscribeDict = subscribeDicts
        page = subscribeDicts["type"] as! String
        subscribeDicts.removeValue(forKey: "type")
        let json = getJSONStringFromDictionary(dictionary:
            subscribeDicts as NSDictionary)
        SingletonSocket.sharedInstance.socket.write(string: json)
    }
    //检测
    @objc func checkPing() {
        if !isPingBack {
            // 重新连接
            socketReconnect()
        }else {
            isPingBack = false
        }
    }
    //构造单例数据
    static let shared = WTWebsocket()
    private override init() {
    }
}
//socket 重连逻辑
func socketReconnect() {
    //判断网络情况，如果网络正常，可以执行重连
    if reachability.connection != .none {
        //设置重连次数，解决无限重连问题
        reConnectTime =  reConnectTime + 1
        if reConnectTime < reConnectMaxTime {
            //添加重连延时执行，防止某个时间段，全部执行
            let time: TimeInterval = 2.0
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time) {
                SingletonSocket.sharedInstance.socket.connect()
                SingletonSocket.sharedInstance.socket.disconnect()
            }
        } else {
            //提示重连失败
        }
    } else {
        //提示无网络
    }
}
//socket主动断开，放在app进入后台时，数据进入缓存。app再进入前台，app出现卡死的情况
func socketDisConnect() {
    if !SingletonSocket.sharedInstance.socket.isConnected {
        websocketTimer?.invalidate()
        websocketTimer = nil
        SingletonSocket.sharedInstance.socket.disconnect()
    }
}
// initSocket方法
func initWebSocketSingle () {
    SingletonSocket.sharedInstance.socket.delegate = webSocket
}
//声明webSocket单例
class SingletonSocket {
    let socket:WebSocket = WebSocket(url: URL(string: AppURLHOST.SocketURL)!)
    class var sharedInstance : SingletonSocket{
        struct Static{
            static let instance:SingletonSocket = SingletonSocket()
        }
        if !Static.instance.socket.isConnected{
            Static.instance.socket.connect()
        }
        return Static.instance
    }
}
```
- ### 2 整个代码很简单，基本都有注释，大概聊一聊里面的一些关键点 
  * 2.1 发送ping-俗称发送心跳，这个主要是判断socket是否断开，链接成功后每次间隔固定时间发送一次请求，然后在返回中修改isPingBack，在下一次发送请求前检查isPingBack判断上一次的请求是否返回，这样就可以判断socket是否断开，这个间隔时间可以自由设定，但是最好不要太短，太短有可能是socket连接了但是没有来得及返回。当然太长也不行，这可能导致发现socket断开不及时。

  * 2.2 app在后台需要断开socket，当 app重新进入前台需要重新连接。
```
func applicationWillResignActive(_ application: UIApplication) {
        //进入后台模式，主动断开socket，防止出现处理不了的情况
        if SingletonSocket.sharedInstance.socket.isConnected {
            reConnectTime = reConnectMaxTime
            socketDisConnect()
        }
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        //进入前台模式，主动连接socket
        //解决因为网络切换或链接不稳定问题，引起socket断连问题
        //如果app从无网络，到回复网络，需要执行重连
        if !isFirstApplicationDidBecomeActive {
            reConnectTime = 0
            socketReconnect()
            WTBasicConfigManager.shareDataSingle.getHash()
        }
        isFirstApplicationDidBecomeActive = false
    }
```

   * 2.3 一定要设置最大重新连接的次数，不然app会无限重新连接

   * 2.4 连接成功或者重连成功都需要对需要推送的数据进行一次网络请求，确保数据的准确性。

- #### 3 以上就是我在项目中使用WebSocket的方法，如果有错误或者不足之处还望指正，谢谢