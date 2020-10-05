//
//  NetworkServiceProtocol.swift
//  reignposts
//
//  Created by Daniel Durán Schütz on 30/09/20.
//

import Foundation
import Alamofire

enum ServiceResult<T> {
    case Success(T, Int)
    case Error(String, Int?)
}

protocol NetworkServiceProtocol {
    var baseUrl: String{ get }
    func request(url:String,
                 method:HTTPMethod,
                 parameters:Parameters?,
                 complete: @escaping(ServiceResult<String?>) -> Void)
}
