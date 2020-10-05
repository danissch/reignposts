//
//  Connectivity.swift
//  reignposts
//
//  Created by Daniel Durán Schütz on 5/10/20.
//

import Foundation
import Alamofire
class Connectivity {
    class var isConnectedToInternet:Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
}

