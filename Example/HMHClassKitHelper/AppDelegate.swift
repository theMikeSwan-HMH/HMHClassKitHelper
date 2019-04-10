//
//  AppDelegate.swift
//  HMHClassKitHelper
//
//  Created by theMikeSwan-HMH on 03/18/2019.
//  Copyright (c) 2019 theMikeSwan-HMH. All rights reserved.
//

import UIKit
import ClassKit
import HMHClassKitHelper


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let classKitHelper = ClassKitHelper.shared
    
    /// Supplies an array of all the file paths that should be included in the content.
    ///
    /// Keeping all of the files in one place makes it easy to add additional plays later.
    ///
    /// - Returns: An array of file paths to the json files for the plays.
    static func contentFiles() -> [String] {
        let files = [Bundle.main.path(forResource: "hamlet", ofType: "json"),
                     Bundle.main.path(forResource: "macbeth", ofType: "json")]
        
        return files.compactMap({ $0 })
    }
    
    /// All the plays that are part of the app's content.
    let plays: [Play] = {
        var plays = [Play]()
        let decoder = JSONDecoder()
        for file in contentFiles() {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: file)), let play = try? decoder.decode(Play.self, from: data) {
                plays.append(play)
            }
        }
        return plays
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let navController = window?.rootViewController as! UINavigationController
        let playController = navController.viewControllers[0] as! PlaysCollectionViewController
        playController.plays = plays
        
        // We decalare the ClassKit contexts on a background thread to keep from blocking the main UI
        let files = AppDelegate.contentFiles()
        DispatchQueue.global().async {
            for file in files {
                self.classKitHelper.addJSON(file: file)
            }
            self.classKitHelper.declareContexts()
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // This is where calls come in when a student taps on an assignment in Schoolwork. The inbound userActivity will have isClassKitDeepLink set to true
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard userActivity.isClassKitDeepLink, var identifierPath = userActivity.contextIdentifierPath else { return false }
        // The first bit of the identifier path is the main app context, we don't need that bit
        identifierPath = Array(identifierPath.dropFirst())
        switch identifierPath.count {
        case 0:
            // Apparently the teacher assigned all the plays…??
            // Means we don't need to go anywhere special though
            break
        case 1:
            // Only a play was selected so we should show all acts in it
            navigateToActs(at: identifierPath)
        case 2:
            // An act was selected so we show all its scenes
            navigateToScenes(at: identifierPath)
        default:
            // Should never be more than three, but if it is we will just ignore the extras
            navigateToScene(at: identifierPath)
        }
        return true
    }
    
    private func navigateToActs(at identifierPath: [String]) {
        guard let play = (plays.first { $0.identifier == identifierPath.first }) else { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ActsTable") as! ActsTableViewController
        vc.play = play
        pushTo(vc: vc)
    }
    
    private func navigateToScenes(at identifierPath: [String]) {
        guard let play = (plays.first { $0.identifier == identifierPath.first }) else { return }
        let idPath = Array(identifierPath.dropFirst())
        guard let act = (play.acts.first { $0.identifier == idPath.first}) else { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ScenesTable") as! ScenesTableViewController
        vc.play = play
        vc.act = act
        pushTo(vc: vc)
    }
    
    private func navigateToScene(at identifierPath: [String]) {
        guard let play = (plays.first { $0.identifier == identifierPath.first }) else { return }
        var idPath = Array(identifierPath.dropFirst())
        guard let act = (play.acts.first { $0.identifier == idPath.first}) else { return }
        idPath = Array(idPath.dropFirst())
        guard let scene = (act.scenes.first { $0.identifier == idPath.first }) else { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SceneViewController") as! SceneViewController
        vc.play = play
        vc.act = act
        vc.scene = scene
        pushTo(vc: vc)
    }
    
    private func pushTo(vc: UIViewController) {
        let navController = window?.rootViewController as! UINavigationController
        navController.pushViewController(vc, animated: true)
    }
}

