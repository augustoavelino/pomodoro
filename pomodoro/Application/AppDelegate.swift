//
//  AppDelegate.swift
//  pomodoro
//
//  Created by Augusto Avelino on 19/02/24.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var notificationCenter = UNUserNotificationCenter.current()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupWindow()
        setupNotificationCenter()
        return true
    }
    
    private func setupNotificationCenter() {
        notificationCenter.delegate = self
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { _, error in
            if let error = error {
                debugPrint("UNUserNotificationCenter error: \(error.localizedDescription)")
            }
        }
    }
    
    private func setupWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = makeInitialViewController()
        window?.makeKeyAndVisible()
    }
    
    private func makeInitialViewController() -> UIViewController {
        let navigationController = UINavigationController(
            rootViewController: TimerViewController(
                pomodoroTimer: PomodoroTimer(settings: .default)))
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.tintColor = .white
        return navigationController
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.badge, .banner, .list, .sound])
    }
}
