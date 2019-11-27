//
//  WebServices.swift
//  GOGOVAN DEMO
//
//  Created by Chuen on 24/11/2019.
//  Copyright © 2019 Chuen. All rights reserved.
//

import Foundation
import Alamofire
import RxAlamofire
import RxSwift


public struct MappableRequest<Model: Codable> {
    let method: HTTPMethod
    let url: URL
    let param: [String: Any]?
    let encoding: ParameterEncoding
    var header: [String: String]?
    var requestOptions: RequestOption = []
    
    init(method: HTTPMethod = .get,
         releativeURL: String,
         param: [String:Any]? = nil,
         encoding: ParameterEncoding = JSONEncoding.default,
         header: [String:String]? = nil) {
        let urlString = releativeURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url = URL(string: urlString ?? "")!
        self.init(method: method,
                  absoluteURL: url,
                  param: param,
                  encoding: encoding,
                  header: header)
    }
    
    init(method: HTTPMethod,
         absoluteURL: URL,
         param: [String:Any]? = nil,
         encoding: ParameterEncoding,
         header: [String:String]? = nil) {
        self.method = method
        self.url = absoluteURL
        self.param = param
        self.encoding = encoding
        self.header = header
    }
}

struct RequestOption: OptionSet {
    let rawValue: Int
    
    static let noLoadingIndicator = RequestOption(rawValue: 1)
    static let noDefaultErrorAlert = RequestOption(rawValue: 2)
}

class WebServices {
    static let afSessionManager:Alamofire.SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        return Alamofire.SessionManager(configuration: configuration)
    }()
    
    static let decoder:JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        return decoder
    }()
    
    static func requestJSONByModel<M:Codable>(request: MappableRequest<M>) -> Observable<M>{
        //        var header: [String: String]?
        var requestObservable: Observable<M> = Observable
            .deferred { () -> Observable<(HTTPURLResponse, [String:Any])> in
                return WebServices.requestJSON(request.method,
                                               request.url,
                                               parameters: request.param,
                                               encoding: request.encoding,
                                               headers: nil)
            }
            .map(WebServices.mapResponseToModel)
        
        if !request.requestOptions.contains(RequestOption.noLoadingIndicator) {
            requestObservable = requestObservable.showLoadingDialog()
        }
        
        return requestObservable
    }
    
    private static func mapResponseToModel<M:Codable>(httpResponse: HTTPURLResponse, json: [String:Any]) throws -> M {
        do {
            return try WebServices.mapJsonToModel(json, modelType: M.self)
        } catch let error as DecodingError {
            debugPrint(error)
            throw ResponseError.init(url: httpResponse.url, rawResponse: httpResponse)
        }
    }
    
    static func mapJsonToModel<M>(_ jsonDict:Any, modelType:M.Type) throws -> M where M:Decodable {
        let jsonData = try JSONSerialization.data(withJSONObject: jsonDict, options: [])
        let model = try WebServices.decoder.decode(modelType, from: jsonData)
        return model
    }
    
    static func requestJSON(_ method: Alamofire.HTTPMethod = .post,
                            _ url: URLConvertible,
                            parameters: [String: Any]? = nil,
                            encoding: ParameterEncoding = JSONEncoding.default,
                            headers: [String: String]? = nil) -> Observable<(HTTPURLResponse, [String:Any])> {
        
        let request = WebServices.afSessionManager.rx
            .request(method, url,
                     parameters: parameters,
                     encoding: encoding,
                     headers: headers)
            .responseJSON()
        
        let response = WebServices.responseJSON(dataResponse: request, url: url)
        
        return response
        
    }
    
    private static func responseJSON(dataResponse: Observable<DataResponse<Any>>, url: URLConvertible) -> Observable<(HTTPURLResponse, [String:Any])> {
        return dataResponse
            .map { (response) -> (HTTPURLResponse, [String:Any]) in
                
                let url = response.request?.url
                
                guard let httpResponse = response.response else {
                    throw ResponseError.init(url: url)
                }
                
                guard let jsonValue = response.value as? [String:Any] else {
                    throw ResponseError.init(url: url, rawResponse: httpResponse)
                }
                
                return (httpResponse, jsonValue)
            }
            .catchError { (error) -> Observable<(HTTPURLResponse, [String:Any])> in
                throw error
        }
        
    }
}

struct ResponseError: Error {
    let url:URL?
    let rawResponse: HTTPURLResponse?
    
    init(url: URL?, rawResponse: HTTPURLResponse? = nil) {
        self.url = url
        self.rawResponse = rawResponse
    }
}
