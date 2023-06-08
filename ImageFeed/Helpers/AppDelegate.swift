//
//  AppDelegate.swift
//  ImageFeed
//
//  Created by Максим on 19.03.2023.
//

import UIKit
import ProgressHUD

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        ProgressHUD.animationType = .systemActivityIndicator
        ProgressHUD.colorHUD = .black
        ProgressHUD.colorAnimation = .black
        return true
    }

        // MARK: UISceneSession Lifecycle

        func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
            let sceneConfiguration = UISceneConfiguration(
                name: "Main",
                sessionRole: connectingSceneSession.role
            )

            sceneConfiguration.delegateClass = SceneDelegate.self
            return sceneConfiguration
            // Called when a new scene session is being created.
            // Use this method to select a configuration to create the new scene with.
        }

        func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
            // Called when the user discards a scene session.
            // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
            // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
        }
    }


