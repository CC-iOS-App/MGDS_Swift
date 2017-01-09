//
//  DSHttpClient.swift
//  ds-ios
//
//  Created by 宋立君 on 15/10/27.
//  Copyright © 2015年 Songlijun. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON



//定义http协议
protocol HttpProtocol{
    //定义一个方法，接收一个参数：AnyObject
    func didRecieveResults(_ results: Any)
}

class HttpController: NSObject {
    
    //定义一个代理
    var delegate:HttpProtocol?
    //定义一个方法，接收网址，请求数据，回调代理的方法，传回数据
    
    // ds api
    func onDSResource(_ urlRequestConvertible:URLRequestConvertible){
        Alamofire.request(urlRequestConvertible).responseJSON { response in
            if let JSON = response.result.value {
                self.delegate?.didRecieveResults(JSON)
            }else{
                
            }
        }
    }
    
    /**
     获取视频资源
     
     - parameter urlRequestConvertible: 请求
     - parameter callback:              返回视频资源
     */
//    class func getVideos(_ urlRequestConvertible:URLRequestConvertible, callback:@escaping ([VideoInfo]?)->Void ){
//        alamofireManager.request(urlRequestConvertible).responseJSON { response in
//            
//            switch response.result {
//                
//            case .success:
//                //判断http状态码
//                if response.response?.statusCode == 200 {
//                    if let JSON = response.result.value {
//                        let videoInfos:[VideoInfo];
//                        videoInfos = ((JSON as! NSDictionary).value(forKey: "content") as! [NSDictionary]).map { VideoInfo(id: $0["id"] as! String,title: $0["title"] as! String,pic: $0["pic"] as! String,url: $0["videoUrl"] as! String,cTime: $0["pushTime"] as! String,isCollectStatus: $0["isCollectStatus"] as! Int)}
//                        
//                        callback(videoInfos)
//                    }
//                    
//                }else{
//                    callback(nil)
//                }
//            case .failure(let error):
//                print(error)
//                callback(nil)
//            }
//            
//        }
//    }
    
    
    /**
     根据视频id获取视频信息
     
     - parameter urlRequestConvertible: 请求
     - parameter callback:              视频信息
     */
//    class func getVideoById(_ urlRequestConvertible:URLRequestConvertible, callback:@escaping (VideoInfo?)->Void ){
//        alamofireManager.request(urlRequestConvertible).responseJSON { response in
//            switch response.result {
//            case .success:
//                //判断http状态码
//                if response.response?.statusCode == 200 {
//                    if let JSON = response.result.value {
//                        
//                        let videoDict = (JSON as! NSDictionary).value(forKey: "content") as! NSDictionary
//                        
//                        let videoInfo = VideoInfo(id: videoDict["id"] as! String,
//                            title:  videoDict["title"] as! String,
//                            pic:  videoDict["pic"] as! String,
//                            url:  videoDict["videoUrl"] as! String,
//                            cTime:  videoDict["pushTime"] as! String,
//                            isCollectStatus:  videoDict["isCollectStatus"] as! Int)
//                        
//                        callback(videoInfo)
//                    }
//                }else{
//                    callback(nil)
//                }
//            case .failure(let error):
//                print(error)
//                callback(nil)
//            }
//            
//        }
//    }
    
    /**
     处理用户收藏
     
     - parameter urlRequestConvertible: 请求
     - parameter callback:              callback description
     */
//    class func onUserAndMovie(_ urlRequestConvertible:URLRequestConvertible, callback:@escaping (Int?)->Void ){
//        alamofireManager.request(urlRequestConvertible).responseJSON { response in
//            switch response.result {
//            case .success:
//                let statusCode = response.response?.statusCode
//                if  statusCode == 201 || statusCode == 200 {
//                    callback(statusCode)
//                }else{
//                    callback(0)
//                }
//            case .failure(let error):
//                print(error)
//                callback(0)
//            }
//            
//        }
//    }
    
    /**
     用户网络请求管理
     
     - parameter urlRequestConvertible: 请求
     - parameter callback:              callback description
     */
    class func onUser(_ urlRequestConvertible:URLRequestConvertible, callback:@escaping (User?)->Void ){
        Alamofire.request(urlRequestConvertible).responseJSON { response in
            switch response.result {
            case .success:
                let statusCode = response.response?.statusCode
                if  statusCode == 201 || statusCode == 200 {
                    
                    if let JSON = response.result.value {
                        
                        let userDictionary = (JSON as! NSDictionary).value(forKey: "content") as! NSDictionary
                        
                        UserDefaults.standard.set(userDictionary, forKey: "userInfo")

                        
                        let userInfo = User(id: userDictionary["id"] as! Int,
            
                            nickName: userDictionary["nickName"] as! String,
                            password: "",
                            headImage: userDictionary["headImage"] as! String,
                            phone: userDictionary["phone"] as! String,
                            gender: userDictionary["gender"] as! Int,
                            platformId: userDictionary["platformId"] as! String,
                            platformName: userDictionary["platformName"] as! String)
                        
                        
//                        DataCenter.shareDataCenter.user = userInfo
                    
//                        callback(statusCode)

                        
                    }
                    
                    
                    
                }else{
                    callback(nil)
                }
            case .failure(let error):
                print(error)
//                callback(0)
            }
            
        }
    }

}




// MARK: - 扩展Manager
//extension Alamofire.Manager {
//    
//    /// 请求规则
//    static let sharedInstanceAndTimeOut: Manager = {
//        let configuration = URLSessionConfiguration.default
//        //请求超时 时间
//        configuration.timeoutIntervalForRequest = 10 // 秒
//        
//        configuration.httpAdditionalHeaders = Manager.defaultHTTPHeaders
//        return Manager(configuration: configuration)
//    }()
//}

// 创建HttpClient结构体
//struct HttpClientByVideo {
//    
//    // 创建逗视网络请求 Alamofire 路由
//    enum DSRouter: URLRequestConvertible {
//        
//        // 逗视API地址
//        static let baseURLString = "https://api.ds.itjh.net/v1/rest/video/"
//        
//        
//        // 请求方法
//        case videosByType(Int,Int,Int,Int) //根据类型获取视频
//        case getVideosByBanner(Int) //获取发现Banner视频
//        case getVideoTaxis(Int) //获取排行榜
//        case getVideosById(String,Int) //根据视频id获取视频信息
//        
//        // 不同请求，对应不同请求类型
//        var method: Alamofire.HTTPMethod {
//            switch self {
//            case .videosByType:
//                return .get
//            case .getVideosByBanner:
//                return .get
//            case .getVideoTaxis:
//                return .get
//            case .getVideosById:
//                return .get
//            }
//        }
//        
//        var URLRequest: NSMutableURLRequest {
//            
//            let (path) : (String) = {
//                
//                switch self {
//                case .videosByType(let vid, let count, let type,let userId):
//                    return ("getVideosByType/\(vid)/\(count)/\(type)/\(userId)")
//                case .getVideosByBanner(let userId):
//                    return "getVideosByBanner/\(userId)"
//                case .getVideoTaxis(let userId):
//                    return "getVideoTaxis/\(userId)"
//                case .getVideosById(let videoId,let userId):
//                    return "getVideosById/\(videoId)/\(userId)"
//                }
//            }()
//            
//            let URL = Foundation.URL(string: DSRouter.baseURLString)
//            let URLRequest = NSMutableURLRequest(url: URL!.appendingPathComponent(path))
//            
//            URLRequest.httpMethod = method.rawValue
//            
//            let encoding = URLEncoding.default.encode(URLRequest as! URLRequestConvertible, with: nil).0
//            return encoding
//        }
//    }
//}




// 创建HttpClient User结构体
struct HttpClientByUser {
    
    // 创建逗视网络请求 Alamofire 路由
    enum DSRouter: URLRequestConvertible {
        // 逗视API地址
        static let baseURLString = "https://api.ds.itjh.net/v1/rest/user/"
        
        // 请求方法
        case registerUser(User) //注册用户
        case loginUser(String,String) //用户登录
        
        
        // 不同请求，对应不同请求类型
        var method: Alamofire.HTTPMethod {
            switch self {
            case .registerUser:
                return .post
            case .loginUser:
                return .get
            }
        }

        
        /// Returns a URL request or throws if an `Error` was encountered.
        ///
        /// - throws: An `Error` if the underlying `URLRequest` is `nil`.
        ///
        /// - returns: A URL request.
         // MARK: URLRequestConvertible
        
        func asURLRequest() throws -> URLRequest {
            let (path) : (String) = {
                switch self {
                case .registerUser(_):
                    return "registerUser"
                case .loginUser(let phone,let password):
                    return "loginUser/\(phone)/\(password)"
                }
                
            }()

            
            let url = try DSRouter.baseURLString.asURL()
            var urlRequest = URLRequest(url: url.appendingPathComponent(path))
            urlRequest.httpMethod = method.rawValue
            
            switch self {
                case .registerUser(let user):
                    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    //用户参数
                    let parameters = ["nickName": user.nickName,"headImage": user.headImage,"phone":user.phone,"platformId":user.platformId,"platformName":user.platformName,"password":user.password,"gender":user.gender] as [String : Any]
                    urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
                default:
                    break
            }
            
            return urlRequest
        }
    }
}


//// 创建HttpClient结构体 工具类
//struct HttpClientByUtil {
//    
//    // 创建逗视网络请求 Alamofire 路由
//    enum DSRouter: URLRequestConvertible {
//        
//        // 逗视API地址
//        static let baseURLString = "https://api.ds.itjh.net/v1/rest/util/"
//        
//        
//        // 请求方法
//        case getQiNiuUpToken() //获取七牛token
//        
//        
//        // 不同请求，对应不同请求类型
//        var method: Alamofire.HTTPMethod {
//            switch self {
//            case .getQiNiuUpToken:
//                return .get
//            }
//        }
//        
//        var URLRequest: NSMutableURLRequest {
//            
//            let (path) : (String) = {
//                
//                switch self {
//                case .getQiNiuUpToken():
//                    return ("getQiNiuUpToken")
//                }
//            }()
//            
//            let URL = Foundation.URL(string: DSRouter.baseURLString)
//            let URLRequest = NSMutableURLRequest(url: URL!.appendingPathComponent(path))
//            
//            URLRequest.httpMethod = method.rawValue
//            
//            let encoding = Alamofire.ParameterEncoding.url
//            return encoding.encode(URLRequest, parameters: nil).0
//        }
//    }
//}
//
//


// 创建HttpClient结构体
//struct HttpClientByUserAndVideo {
//    
//    // 创建逗视网络请求 Alamofire 路由
//    enum DSRouter: URLRequestConvertible {
//        
//        // 逗视API地址
//        static let baseURLString = "https://api.ds.itjh.net/v1/rest/userAndVideo/"
//        
//        
//        // 请求方法
//        case deleteByUserIdAndVideoId(Int,String) //取消收藏
//        
//        case addUserFavoriteVideo(UserFavorite) //收藏
//        
//        case getVideosByUserId(Int,Int,Int) //根据用户id获取收藏记录
//        
//        
//        // 不同请求，对应不同请求类型
//        var method: Alamofire.Method {
//            switch self {
//            case .deleteByUserIdAndVideoId:
//                return .DELETE
//            case .addUserFavoriteVideo:
//                return .POST
//            case .getVideosByUserId:
//                return .GET
//            }
//        }
//        
//        var URLRequest: NSMutableURLRequest {
//            
//            //返回请求链接
//            let (path) : (String) = {
//                switch self {
//                case .getVideosByUserId(let userId, let pageNum, let count):
//                    return ("getVideosByUserId/\(userId)/\(pageNum)/\(count)")
//                case .deleteByUserIdAndVideoId(let userId, let vid):
//                    return ("deleteByUserIdAndVideoId/\(userId)/\(vid)")
//                case .addUserFavoriteVideo(_):
//                    return "addUserFavoriteVideo"
//                }
//            }()
//            
//            
//            let URL = Foundation.URL(string: DSRouter.baseURLString)
//            let URLRequest = NSMutableURLRequest(url: URL!.appendingPathComponent(path))
//            URLRequest.httpMethod = method.rawValue
//            
//            
//            
//            switch self {
//            case .addUserFavoriteVideo(let userFavorite):
//                
//                URLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
//                //用户参数
//                let parameters = ["userId": userFavorite.userId,"videoId": userFavorite.videoId,"status":userFavorite.status] as [String : Any]
//                do {
//                    URLRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions())
//                } catch {
//                }
//                
//            default: break
//                
//            }
//            
//            let encoding = Alamofire.ParameterEncoding.url
//            return encoding.encode(URLRequest, parameters: nil).0
//        }
//    }
//}


