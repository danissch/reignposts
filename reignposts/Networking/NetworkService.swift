//
//  NetworkService.swift
//  reignposts
//
//  Created by Daniel Durán Schütz on 30/09/20.
//

import Foundation
import Alamofire

class NetworkService: NetworkServiceProtocol {
    
    static let get = NetworkService()
    private init(){}
    
    var afSessionManager:AFSessionManagerProtocol?
    private let verbose = true
    
    private func verbosePrint(_ msg:String){
        if verbose {
            print(msg)
        }
    }
    var baseUrl: String{
        get {
            return ApiRoutes.postsUrl
        }
    }
    
    private func treatError(url:String, response: DataResponse<String>) -> String{
        verbosePrint("error =\(response.description)")
        if let localizedDescription = response.result.error?.localizedDescription{
            return localizedDescription
        } else if response.result.debugDescription.count > 0 {
            return response.result.debugDescription
        }
        return "error: \(response.response?.statusCode ?? 0)"
    }
    
    func request(url: String, method: HTTPMethod, parameters: Parameters?, complete: @escaping (ServiceResult<String?>) -> Void) {
        guard let sessionManager = afSessionManager else {
            return complete(.Error("Error creating request", 0))
        }
        
        sessionManager.responseString(url, method: method, parameters: parameters, enconding: JSONEncoding.default)
        { [weak self] response in
            self?.verbosePrint("url=\(response.request?.url?.description ?? "")")
            let statusCode = response.response?.statusCode ?? -1
            self?.verbosePrint("status code=\(statusCode)")
            if response.result.isSuccess {
                return complete(.Success(response.result.value, statusCode))
            }
            return complete(.Error(self?.treatError(url: url, response: response) ?? "", response.response?.statusCode))
            
        }
        
        
    }
    
}
