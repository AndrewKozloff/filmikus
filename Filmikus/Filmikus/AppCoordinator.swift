//
//  AppCoordinator.swift
//  Filmikus
//
//  Created by Андрей Козлов on 27.07.2020.
//  Copyright © 2020 Андрей Козлов. All rights reserved.
//

import UIKit

class AppCoordinator {
	
	private let window: UIWindow
	
//	private lazy var authenticationCoordinator: AuthenticationCoordinator = {
//		let controller = NavigationController()
//		controller.apply(gradientStyle: .bluePurple)
//		let coordinator = AuthenticationCoordinator(navigationController: controller)
//		return coordinator
//	}()
	
	init(window: UIWindow) {
		self.window = window
	}
	
	func start() {
		let launchVC = LaunchViewController()
		launchVC.delegate = self
		window.rootViewController = launchVC
		window.makeKeyAndVisible()
	}
	
	func setRoot(viewController: UIViewController) {
		window.rootViewController = viewController
		UIView.transition(
			with: window,
			duration: 0.4,
			options: .transitionCrossDissolve,
			animations: nil,
			completion: nil
		)
	}
	
	@objc
	private func handleUserSubscribedNotification(notification: Notification) {
		setRoot(viewController: TabBarController())
		NotificationCenter.default.removeObserver(self, name: .userDidSubscribe, object: nil)
	}
}

// MARK: - LaunchViewControllerDelegate

extension AppCoordinator: LaunchViewControllerDelegate {
    func launchViewControllerDidShowAllContent(_ viewController: LaunchViewController) {
        setRoot(viewController: TabBarController())
    }
    
	
	func launchViewController(_ viewController: LaunchViewController, didReceiveAccess type: WelcomeTypeModel) {
        let welcomeTourVC = WelcomeTourViewController(welcomeType: type)
        welcomeTourVC.welcomeTourDelegate = self
        setRoot(viewController: welcomeTourVC)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserSubscribedNotification),
            name: .userDidSubscribe,
            object: nil
        )
	}
}

extension AppCoordinator: WelcomeTourViewControllerDelegate {
    func welcomeTourViewControllerDidClose(_ viewController: WelcomeTourViewController) {
        let tabBarVC = TabBarController()
        tabBarVC.selectedTab = .profile
        setRoot(viewController: tabBarVC)
    }
}
