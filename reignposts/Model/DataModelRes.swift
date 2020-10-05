//
//  DataModelRes.swift
//  reignposts
//
//  Created by Daniel Durán Schütz on 30/09/20.
//

import Foundation

struct DataModelRes:Decodable {
    var hits: [PostModelRes]?

}

struct PostModelRes:Decodable {
    var created_at: String?
    var title:String?
    var url: String?
    var author: String?
    var story_id: Int?
    var story_title: String?
    var story_url: String?
    var created_at_i: Int?
    var objectID: String?
}


