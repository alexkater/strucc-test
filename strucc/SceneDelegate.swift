//
//  SceneDelegate.swift
//  strucc
//
//  Created by Alejandro Arjonilla Garcia on 26/05/2020.
//  Copyright © 2020 aarjincc. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = scene as? UIWindowScene else { return }

//        let cameraViewController = MediaEditingViewController()
//        let cameraViewController = PreviewViewController()
        let cameraViewController = CameraViewController()

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UINavigationController(rootViewController: cameraViewController)
        self.window = window
        window.makeKeyAndVisible()
    }
}
