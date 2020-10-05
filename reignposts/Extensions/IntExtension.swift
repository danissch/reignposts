//
//  IntExtension.swift
//  reignposts
//
//  Created by Daniel Durán Schütz on 4/10/20.
//

import Foundation

extension Int64 {
    func toDate() -> Date{
        return NSDate(timeIntervalSince1970: TimeInterval(self)) as Date
    }
}

