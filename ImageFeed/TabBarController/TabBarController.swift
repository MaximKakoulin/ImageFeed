//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Максим on 28.05.2023.
//

import UIKit


final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.isTranslucent = false
        tabBar.barTintColor = .YPBlack
        tabBar.tintColor = .YPWhite

    let imagesListViewController = ImagesListViewController()
        imagesListViewController.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: "tab_editorial_active"),
            selectedImage: nil
        )
        imagesListViewController.tabBarItem.accessibilityIdentifier = "ImagesList"

        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )
        profileViewController.tabBarItem.accessibilityIdentifier = "Profile"

        self.viewControllers = [imagesListViewController, profileViewController]
    }
}

