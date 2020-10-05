//
//  NSObjectExtension.swift
//  reignposts
//
//  Created by Daniel Durán Schütz on 2/10/20.
//

import Foundation

extension NSObject {
    @objc class var stringRepresentation:String {
        let name = String(describing: self)
        return name
    }
}
