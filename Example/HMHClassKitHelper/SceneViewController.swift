//
//  SceneViewController.swift
//  HMHClassKitHelper
//
//  Created by theMikeSwan-HMH on 03/18/2019.
//  Copyright (c) 2019 theMikeSwan-HMH. All rights reserved.
//

import UIKit
import HMHClassKitHelper
import ClassKit
import os

class SceneViewController: UIViewController, UITextViewDelegate {
    
    var dataStore: ClassKitDataStore = CLSDataStore.shared
    
    private let classKitLog: OSLog = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "ClassKit")
    
    // Constants for various ClassKit items specific to this app. Keeps us from misspelling them later.
    private let practiceIdentifier = "practiceQuiz"
    private let practiceTitle = "Practice Quiz"
    private let scoreIdentifier = "finalScore"
    private let scoreTitle = "Quiz Score"
    
    var play: Play?
    var act: Act?
    var scene: Scene? {
        didSet {
            setupView()
        }
    }

    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var practiceButton: UIBarButtonItem!
    @IBOutlet private weak var quizButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startActivity(for: identifierPath) { (context, activity, error) in
            guard let activity = activity else {
                if let error = error as? ClassKitError {
                    self.reportError(error)
                } else if let error = error {
                    self.reportError(ClassKitError.classKitError(underlyingError: error))
                }
                return
            }
            // Since we have just started a fresh activity we set the progress to 0 and indicate that the practice quiz has not been completed.
            self.setProgress(0.0, on: activity)
            let activityItem = CLSBinaryItem(identifier: self.practiceIdentifier, title: self.practiceTitle, type: .yesNo)
            activityItem.value = false
            self.addAdditional(activityItem: activityItem, to: activity)
            self.saveClassKitData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // We are going away so the student can't make anymore progress in this context right now.
        stopActivity(for: identifierPath)
    }
    
    private func setupView() {
        guard let scene = scene, let textView = textView else { return }
        textView.attributedText = scene.contents
        self.title = scene.title
        self.navigationItem.rightBarButtonItems = [quizButton, practiceButton]
    }

    @IBAction func practice(_ sender: Any) {
        let alert = UIAlertController(title: "Practice Done!", message: "In this sample app we don't have any actual quizzes. The practice quiz is a done or not done setting that has been set to done now.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true
            , completion: nil)
        // Here we set the practice quiz to be complete by creating a new activity item with the same identifier as before but a value of true.
        let activityItem = CLSBinaryItem(identifier: self.practiceIdentifier, title: self.practiceTitle, type: .yesNo)
        activityItem.value = true
        addAdditional(activityItem: activityItem, for: identifierPath)
    }
    @IBAction func takeQuiz(_ sender: Any) {
        let alert = UIAlertController(title: "Practice Done!", message: "In this sample app we don't have any actual quizzes. The quiz is percentage from 0-100%. Select an option below for either a random passing or failing( <60%) score.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Pass", style: .default, handler: { (_) in
            // In a shipping app we would have an actual quiz and the score we reported would be based on the student's results on said quiz. To keep this example simple we just make a random number in the passing or failing range.
            let score = Double.random(in: 60...100)
            let scoreItem = CLSScoreItem(identifier: self.scoreIdentifier, title: self.scoreTitle, score: score, maxScore: 100.0)
            // Here we assign the score we created above as the primary activity item since it is the thing the teacher will care most about. We set startIfNeeded to false because if we somehow got here without starting an activity we want to know so we can fix the mistake.
            self.setPrimary(activityItem: scoreItem, for: self.identifierPath, startIfNeeded: false)
        }))
        alert.addAction(UIAlertAction(title: "Fail", style: .destructive, handler: { (_) in
            let score = Double.random(in: 0..<60)
            let scoreItem = CLSScoreItem(identifier: self.scoreIdentifier, title: self.scoreTitle, score: score, maxScore: 100.0)
            self.setPrimary(activityItem: scoreItem, for: self.identifierPath, startIfNeeded: false)
        }))
        self.present(alert, animated: true
            , completion: nil)
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = textView.contentOffset.y + textView.frame.size.height
        let total = textView.contentSize.height
        
        // The scroll view can bounce, so use care to bound the progress.
        let progress = Double(max(0, min(1, position / total)))
        // Here we set the student's progress based on how far through the text they have gotten.
        setProgress(progress, for: identifierPath)
        
    }
}

extension SceneViewController: ClassKitEnabled {
    var identifierPath: [String] {
        get {
            guard let play = play, let act = act, let scene = scene else { return [String]() }
            return [play.identifier, act.identifier, scene.identifier]
        }
    }
    
    // In a shipping app the error handling should likely let the user know there was an issue…
    func reportError(_ error: Error) {
        guard let error = error as? ClassKitError else { return }
        switch error {
        case .contextNotFound(let identifierPath):
            os_log(.error, log: classKitLog, "Unable to find a context for %@", identifierPath)
        case .classKitError(let underlyingError):
            os_log(.error, log: classKitLog, "There was a problem in ClassKit: %@", underlyingError.localizedDescription)
        case .noActivity(let identifierPath):
            os_log(.error, log: classKitLog, "No Activity attached to context at %@", identifierPath)
        }
    }
    
}
