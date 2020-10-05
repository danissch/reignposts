//
//  HomeViewController.swift
//  reignposts
//
//  Created by Daniel Durán Schütz on 30/09/20.
//

import UIKit
import NVActivityIndicatorView
//import NVPullToRefresh

class HomeViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    let minHeightContentCell:CGFloat = 100
    var postsViewModel:PostsViewModelProtocol?
    var window: UIWindow?
    var refreshControl = UIRefreshControl()
    var loading:NVActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViewModel()
        setDelegates()
        tableViewMainConfiguration()
        setActivityIndicatorConfig()
        requestRows()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func initViewModel(){
        let viewModel = PostsViewModel()
        NetworkService.get.afSessionManager = AFSessionManager()
        viewModel.networkService = NetworkService.get
        self.postsViewModel = viewModel as PostsViewModelProtocol
    }

    func setActivityIndicatorConfig(){
        loading = NVActivityIndicatorView(frame: .zero, type: .ballSpinFadeLoader, color: .systemGray, padding: 10)
        loading.translatesAutoresizingMaskIntoConstraints = true
        loading.frame = refreshControl.bounds
        loading.backgroundColor = .systemGray6
        loading.autoresizingMask = [.flexibleWidth]
        
        refreshControl.autoresizingMask = [.flexibleWidth]
        refreshControl.tintColor = .clear
        refreshControl.addSubview(loading)
        refreshControl.bringSubviewToFront(loading)
        refreshControl.backgroundColor = .systemGray6
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)

        tableView.addSubview(refreshControl)
    }
    
    func setDelegates(){
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableViewMainConfiguration(){
        tableView.register(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: "PostTableViewCell")
        tableView.preservesSuperviewLayoutMargins = false
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.layoutMargins = UIEdgeInsets.zero
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
        
    }
    
    func requestRows(){
        self.postsViewModel?.getPosts(){[weak self](result) in
            switch result {
            case .Success(_, _):
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .Error(let message, let statusCode):
                print("Error: \(message), code: \(statusCode)")
            }
        }
    }
    
    func closeRefresh(){
        DispatchQueue.main.asyncAfter(deadline:DispatchTime.now() + 1){
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
            self.loading.stopAnimating()
        }
    }
    
    @objc func refresh(_ sender: AnyObject) {
       // Code to refresh table view
        loading.startAnimating()
        if !Connectivity.isConnectedToInternet {
            closeRefresh()
            let alert = UIAlertController(title: "Do you have Internet connection?", message: "It's recommended to bring your news.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
         }
        
        self.postsViewModel?.getRemotePosts(refresh: true){[weak self](result) in
            switch result {
            case .Success(_, _):
                self?.closeRefresh()
            case .Error(let message, let statusCode):
                print("Error refresh: \(message), code: \(statusCode)")
            }
        }
        
    }
}

extension HomeViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        goToWebView(indexPath: indexPath)
    }
    
    func goToWebView(indexPath: IndexPath){
        if let dataItem = postsViewModel?.posts[indexPath.row] {
            let vc = PostDetailViewController.instantiateFromXIB() as PostDetailViewController
            let isUrl = (dataItem.story_url != nil)
            vc.setData(urlBrowser: (isUrl ? dataItem.story_url : dataItem.url)!)
            self.pushVc(uiViewController: vc, navigationBarIsHidden: false)
            vc.backButton()
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction(style: .destructive, title: "Delete"){
          (action, view, completionHandler) in
            self.deleteItem(indexPath: indexPath)
        }
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func deleteItem(indexPath: IndexPath){
        if let post = self.postsViewModel?.posts[indexPath.row] {
            self.postsViewModel?.deletePost(postToDelete: post){[weak self](result) in
                switch result {
                case .Success(_, _):
                    self?.requestRows()
                case .Error(let message, let statusCode):
                    print("Error: \(message), code: \(statusCode)")
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
extension HomeViewController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postsViewModel?.posts.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell") as? PostTableViewCell else {
            return UITableViewCell()
        }
        
        if let post = postsViewModel?.posts[indexPath.row]{
            let thereisATitle = (post.story_title != nil)
            cell.cell_title.text = thereisATitle ? post.story_title : post.title ?? ""
            let datetime = DatesManager.get.getDateDifference(startTime: post.created_at_i)
            cell.cell_author_create_at.text = "\(post.author ?? "") - \(datetime)"
        }
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        let line = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width , height: 3 / UIScreen.main.scale))
        line.backgroundColor = UIColor.systemGray3
        line.autoresizingMask = [.flexibleWidth]
        cell.addSubview(line)
        
        return cell
        
    }
    
    
}
