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
        
        // We decalare the ClassKit contexts on a background thread to keep from blocking the main UI.
        // Our simple example is unlikely to take any noticable time but an app with more content could take much longer.
        let files = contentFiles()
        DispatchQueue.global().async {
            for file in files {
                self.classKitHelper.addJSON(file: file)
            }
            self.classKitHelper.declareContexts()
        }
        return true
    }

    // This is where calls come in when a student taps on an assignment in Schoolwork. The inbound userActivity will have isClassKitDeepLink set to true
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        // First we want to see if this is a ClassKit deep link or not.
        // If it is we will need the identifier path to go to the right place.
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

