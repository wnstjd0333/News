//
//  AppDelegate.swift
//  News
//
//  Created by kimjunseong on 2020/02/12.
//  Copyright © 2020 kimjunseong. All rights reserved.
//

import UIKit
import BackgroundTasks

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window?.rootViewController = UINavigationController(rootViewController: MainViewController())

        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.News.refresh", using: nil) { task in
            self.handleAppProcessing(task: task as! BGProcessingTask)
        }
        return true
    }
    
    private func scheduleAppProcessing() {
        let request = BGProcessingTaskRequest(identifier: "com.News.refresh")
        request.requiresNetworkConnectivity = false
        request.requiresExternalPower = true
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app processing: \(error)")
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        scheduleAppProcessing()
    }
    
    private func handleAppProcessing(task: BGProcessingTask) {
        scheduleAppRefresh()
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        task.expirationHandler = {
            queue.cancelAllOperations()
        }
        
        let array = [1, 2, 3, 4, 5]
        array.enumerated().forEach { arg in
            let (offset, value) = arg
            let operation = PrintOperation(id: value)
            if offset == array.count - 1 {
                operation.completionBlock = {
                    task.setTaskCompleted(success: operation.isFinished)
                }
            }
            queue.addOperation(operation)
        }
    }
    
    private func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.News.refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    
    private func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleAppRefresh()
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        task.expirationHandler = {
            queue.cancelAllOperations()
        }
        
        let array = [1, 2, 3, 4, 5]
        array.enumerated().forEach { arg in
            let (offset, value) = arg
            let operation = PrintOperation(id: value)
            if offset == array.count - 1 {
                operation.completionBlock = {
                    task.setTaskCompleted(success: operation.isFinished)
                }
            }
            queue.addOperation(operation)
        }
    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

class PrintOperation: Operation {
    let id: Int
    
    init(id: Int) {
        self.id = id
    }
    
    override func main() {
        print("this operation id is \(self.id)")
    }
}

