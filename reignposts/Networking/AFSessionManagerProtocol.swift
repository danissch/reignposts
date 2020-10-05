//
//  AFSessionManagerProtocol.swift
//  reignposts
//
//  Created by Daniel Durán Schütz on 30/09/20.
//

import Foundation
import Alamofire

protocol AFSessionManagerProtocol {
    func responseString(_ url:String,
                        method: HTTPMethod,
                        parameters: Parameters?,
                        enconding: ParameterEncoding,
                        completionHandler: @escaping (DataResponse<String>) -> Void)
}
