//
//  PostsViewModelProtocol.swift
//  reignposts
//
//  Created by Daniel Durán Schütz on 30/09/20.
//

import Foundation

protocol PostsViewModelProtocol {
    var posts:[Post]{get}
    var deletedPosts:[DeletedPost]{get}
    func getPosts(complete:@escaping(ServiceResult<[Post]>) -> Void)
    func deletePost(postToDelete:Post, complete: @escaping (ServiceResult<[Post]>) -> Void)
    func getRemotePosts(refresh:Bool, complete: @escaping (ServiceResult<[Post]>) -> Void)
    
}
