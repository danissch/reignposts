//
//  PostsViewModel.swift
//  reignposts
//
//  Created by Daniel Durán Schütz on 30/09/20.
//

import Foundation
import UIKit
import CoreData

class PostsViewModel: PostsViewModelProtocol {
    
    let loadFromLocalJsonAtRefresh = false // Local Json (Only development purpose)
    var networkService:NetworkServiceProtocol?
    let persistanceContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var privatePostsList = [Post]()
    var posts: [Post] {
        get { privatePostsList }
    }
    private var privateDeletedPosts = [DeletedPost]()
    var deletedPosts: [DeletedPost] {
        get{ privateDeletedPosts}
    }

    func getPosts(complete: @escaping (ServiceResult<[Post]>) -> Void) {
        getDeletedPosts()
        if PersistanceManager.get.thereAreLocalPosts(){
            getLocalPosts(complete: complete)
        }else{
            getRemotePosts(complete: complete)
        }
    }
    
    func getLocalPosts(complete: @escaping (ServiceResult<[Post]>) -> Void) {
        
        do {
            let request = Post.fetchRequest() as NSFetchRequest<Post>
            let sortByDate = NSSortDescriptor(key: "created_at_i", ascending: false)
            request.sortDescriptors = [sortByDate]
            
            self.privatePostsList = try persistanceContext.fetch(request)
            return complete(.Success(self.privatePostsList, 200))
        }catch{
            print("error:\(error)")
            return complete(.Error("Error decoding or retrieving local data", 500))
        }
    }
    
    func getRemotePosts(refresh: Bool = false, complete: @escaping (ServiceResult<[Post]>) -> Void) {
        guard let networkService = networkService else {
            return complete(.Error("Missing network service", 0))
        }
        
        let baseUrl = networkService.baseUrl
        let url = "\(baseUrl)?query=ios"
        
        networkService.request(url: url,
                               method: .get,
                               parameters: nil)
        { [weak self](result) in
            switch result{
            case .Success(let json, let statusCode):
                
                do {
                    var postsResponse:DataModelRes?
                    if refresh, self?.loadFromLocalJsonAtRefresh == true { //Only for development purpose
                        postsResponse = self?.loadJson()
                        self?.createDataFromRequest(refresh: refresh, response: postsResponse, statusCode: statusCode, complete: complete)
                    }else{ //Default option to bring the news remotely
                        if let data = json?.data(using: .utf8){
                            let decoder = JSONDecoder()
                            postsResponse = try decoder.decode(DataModelRes.self, from: data)
                            self?.createDataFromRequest(refresh: refresh, response: postsResponse, statusCode: statusCode, complete: complete)
                        }else{
                            return complete(.Error("Error parsing data", statusCode))
                        }
                    }

                }catch{
                    print("error:\(error)")
                    return complete(.Error("Error decoding", statusCode))
                }
            case .Error(let message, let statusCode):
                print("Error case: PostsViewModel:")
                return complete(.Error(message, statusCode))
            }
        }
    }
    /* Used to bring news locally from the newPost.json (development purpose)*/
    func loadJson(filename fileName: String = "newPosts") -> DataModelRes? {
        if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(DataModelRes.self, from: data)
                return jsonData
            } catch {
                print("error:\(error)")
            }
        }
        return nil
    }

    func createDataFromRequest(refresh:Bool, response: DataModelRes?, statusCode: Int, complete: @escaping (ServiceResult<[Post]>) -> Void){
        
        getDeletedPosts()
        if let resp = response {
            fillPosts(resp: resp, refresh: refresh)
            do {
                try self.persistanceContext.save()
                PersistanceManager.get.setLocalPostsDataStatus(value: true)
            } catch {
                return complete(.Error("Error: Data not saved", statusCode))
            }
            getLocalPosts(complete:complete)
        }
    }
    
    func fillPosts(resp: DataModelRes, refresh:Bool){
        for post in resp.hits ?? [] {
            if refresh {
                validateToCreate(postToCreate:post)
            }else{
                createNewPost(post: post)
            }
            
        }
    }
    
    func createNewPost(post: PostModelRes){
        let newPost = Post(context: self.persistanceContext)
        newPost.author = post.author
        newPost.created_at = post.created_at
        newPost.created_at_i = Int64(post.created_at_i ?? 0)
        newPost.object_ID = post.objectID
        newPost.story_id = Int64(post.story_id ?? 0)
        newPost.story_title = post.story_title
        newPost.story_url = URL(string: post.story_url ?? "")
        newPost.title = post.title
        newPost.url = URL(string: post.url ?? "")
    }
    
    func deletePost(postToDelete:Post, complete: @escaping (ServiceResult<[Post]>) -> Void){
        self.saveDeletedPost(postToDelete: postToDelete, complete: complete)
    }
    
    func saveDeletedPost(postToDelete:Post, complete: @escaping (ServiceResult<[Post]>) -> Void){
        
        let deletedPost = DeletedPost(context: self.persistanceContext)
        deletedPost.idObject = postToDelete.object_ID
        deletedPost.date = Date()
        
        self.persistanceContext.delete(postToDelete)
        
        do {
            try self.persistanceContext.save()
            return complete(.Success(self.privatePostsList, 200))
        } catch {
            return complete(.Error("Error Post not deleted", 500))
        }
    }
    
    func getDeletedPosts(){
        do {
            self.privateDeletedPosts = try persistanceContext.fetch(DeletedPost.fetchRequest())
        }catch{
            print("error:\(error)")
        }
    }
    
    func validateToCreate(postToCreate:PostModelRes){
        if isDeletedPost(postModelRes: postToCreate) {
            //Message:: object is deleted!!
        }else if postObjectAlreadyExist(postModelRes: postToCreate){
            //Message:: object already exist!!
        }else if postToCreate.story_title == nil, postToCreate.title == nil {
            //Message:: object with title nil in progress or something!!
        }else{
            createNewPost(post: postToCreate)
        }
    }
    
    func isDeletedPost(postModelRes:PostModelRes) -> Bool{
        for deleted in deletedPosts {
            if deleted.idObject == postModelRes.objectID {
                return true
            }
        }
        return false
    }
    
    func postObjectAlreadyExist(postModelRes:PostModelRes) -> Bool {
        for existentItem in posts {
            if existentItem.object_ID == postModelRes.objectID {
                return true
            }
        }
        return false
    }
    
}
