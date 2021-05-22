//
//  MenuViewController.swift
//  Video Editor
//
//  Created by Krish Shah on 22/05/21.
//

import UIKit

class MenuViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        UITabBar.appearance().barTintColor = .systemBackground
        viewControllers = [
            createNavController(for: FeedViewController(), title: "Feed", image: UIImage(systemName: "list.bullet.below.rectangle")!),
            createNavController(for: EditorViewController(), title: "Editor", image: UIImage(systemName: "perspective")!)
        ]
    }
    
    func createNavController(for rootViewController: UIViewController, title: String, image: UIImage) -> UIViewController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        navController.navigationBar.prefersLargeTitles = true
        rootViewController.navigationItem.title = title
        return navController
    }

}
