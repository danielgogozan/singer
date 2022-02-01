//
//  MainViewController.swift
//  Singer
//
//  Created by Daniel Gogozan on 08.11.2021.
//

import UIKit

class MainViewController: UITabBarController {
    
    //  same view model per any SongDetailViewController that gets created
    private let service = MusicService(urlSessionConfiguration: URLSessionConfiguration.default, fileManager: FileManager.default)
    private lazy var songViewModel: SongViewModel = SongViewModel(service: service)
    private lazy var musicViewModel: MusicViewModel = MusicViewModel(service: service)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // how to add init here
        setViewControllers([
            createNavigationController(for: MusicViewController(musicViewModel: musicViewModel, songViewModel: songViewModel), title: "Music", image: UIImage(systemName: "music.note.list")),
            createNavigationController(for: DiscoverViewController(songViewModel: songViewModel), title: "Discover", image: UIImage(systemName:"eyes"))],animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = UIColor(named: "my-red")
    }
    
    private func createNavigationController(for rootViewController: UIViewController, title: String, image: UIImage?) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: rootViewController)
        // title is not shown implicitly
        navigationController.navigationItem.title = "AAAAAAAAAAAA"
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController.tabBarItem.title = title
        navigationController.tabBarItem.image = image
        navigationController.navigationBar.tintColor = UIColor(named: "my-red")
        
        return navigationController
    }
}
