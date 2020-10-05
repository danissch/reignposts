//
//  DatesManager.swift
//  reignposts
//
//  Created by Daniel Durán Schütz on 4/10/20.
//

import Foundation

class DatesManager {
    static let get = DatesManager()
    var now:Date!
    func getDateDifference(startTime: Int64) -> String{
        
        var difference:String
        now = Date()
        let operation = Int64(now.timeIntervalSince1970) - startTime
        if operation >= 84600 {
            let formatter = RelativeDateTimeFormatter()
            formatter.dateTimeStyle = .named
            formatter.unitsStyle = .full
            formatter.unitsStyle = .abbreviated
            difference = formatter.localizedString(for: startTime.toDate(), relativeTo: now)
        }else if operation >= 3600 {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.month, .day, .hour]
            formatter.unitsStyle = .abbreviated
            formatter.allowsFractionalUnits = true //Not working properly
            difference = formatter.string(from: startTime.toDate(), to: now)!
        }else if operation <= 59 {
            difference = "now"
        }else{
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.month, .day, .hour, .minute]
            formatter.unitsStyle = .abbreviated
            formatter.allowsFractionalUnits = false
            difference = formatter.string(from: startTime.toDate(), to: now)!
        }
        
        return difference
    }
    
}
