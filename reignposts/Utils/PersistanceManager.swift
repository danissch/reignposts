//
//  PersistanceManager.swift
//  reignposts
//
//  Created by Daniel Durán Schütz on 1/10/20.
//

import Foundation

class PersistanceManager{
    static var get = PersistanceManager()
    let userDefaults = UserDefaults.standard
    
    func thereAreLocalPosts() -> Bool {
        return userDefaults.object(forKey: "thereAreLocalPosts") != nil
    }
    
    func setLocalPostsDataStatus(value:Bool = true){
        userDefaults.set(value, forKey: "thereAreLocalPosts")
    }
    
    func getLocalPostsDataStatus() -> Bool {
        return userDefaults.bool(forKey: "thereAreLocalPosts")
        
    }
    
}
