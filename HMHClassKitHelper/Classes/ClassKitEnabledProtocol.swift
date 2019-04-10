//
//  ClassKitEnabledProtocol.swift
//  HMHClassKitHelper
//
//  Created by Swan, Michael on 3/29/19.
//

import Foundation
import ClassKit

/// `ClassKitEnabled` is a protocol designed to make performing common ClassKit operations a little easier.
///
/// A default implementation exists for all fo the methods except `reportError(_:)`. That method is left to the implementer as possible responses to the various errors depend on the specific use case. The errors sent to this method will be of the type `ClassKitError`.
public protocol ClassKitEnabled {
    
    /// The ClassKit data store (or a mock for testing).
    ///
    /// In most cases this will come from `CLSDataStore.shared`.
    var dataStore: ClassKitDataStore { get set }
    
    /// Called when an error is detected.
    ///
    /// Errors originating within the `ClassKitEnabled` protocol will be of type `ClassKitError`.
    ///
    /// - Parameter error: The error that occured.
    func reportError(_ error: Error)
    
    /// Triggers the `dataStore` to save its data. If an error occurs it will be sent to `reportError(_:)`.
    ///
    func saveClassKitData()
    
    /// Starts a new activity on a context and passes the context and activity to the completion handler.
    ///
    /// This method will search for the context specified by `identifierPath`, set it to active, and add a new activity on it. If the context could not be found the error parameter of the completion handler will have `ClassKitError.contextNotFound` in it.
    ///
    /// - Parameters:
    ///   - identifierPath: The full path to the context an activity should be started on.
    ///   - completion: A callback that contains the context and its new activity if the context was found and an error if no context was found.
    func startActivity(for identifierPath: [String], completion: @escaping(CLSContext?, CLSActivity?, Error?) -> Void)
    
    /// Adds an additional activity item to the context at `identifierPath`. If requested it will start the context and add an activity first if that hasn't been done yet.
    ///
    /// - Parameters:
    ///   - activityItem: The activity item to add
    ///   - identifierPath: The path to the desired context
    ///   - startIfNeeded: Flag to indicate if the context should be made active and an activity started on it if needed. Defaults to `true`.
    func addAdditional(activityItem: CLSActivityItem, for identifierPath: [String], startIfNeeded: Bool)
    
    /// Adds a secondary activity item to the given activity
    ///
    /// - Parameters:
    ///   - activityItem: The activity item to add
    ///   - activity: The activity the item should be added to.
    func addAdditional(activityItem: CLSActivityItem, to activity: CLSActivity)
    
    /// Finds the context at `identifierPath` (assuming one exists), grabs the activity on it and sets the progress.
    ///
    /// If the context has not been started and/ or there is no activity yet associated with the context setting the `startIfNeeded` flag to true will cause the context to be started and an activity added to it. If the flag is false this method will fail.
    ///
    /// - Parameters:
    ///   - progress: A `Double` that indicates the student's current progress through the context.
    ///   - identifierPath: The identifier path to the desired context.
    ///   - startIfNeeded: Flag to indicate if the context should be made active and an activity started on it if needed. Defaults to `true`.
    func setProgress(_ progress: Double, for identifierPath: [String], startIfNeeded: Bool)
    
    /// Sets the passed in progress to the selected activity.
    ///
    /// - Parameters:
    ///   - progress: A `Double` that indicates the student's current progress through the context.
    ///   - activity: The activity the progress should be set on.
    func setProgress(_ progress: Double, on activity: CLSActivity)
    
    /// Assigns the primary activity item to the activity associated with the context at the given path.
    ///
    /// The primary activity item will typically be something like the score on a quiz.
    ///
    /// - Parameters:
    ///   - activityItem: The activity item to set as primary
    ///   - identifierPath: The identifier path to the desired context.
    ///   - startIfNeeded: Flag to indicate if the context should be made active and an activity started on it if needed. Defaults to `true`.
    func setPrimary(activityItem: CLSActivityItem, for identifierPath: [String], startIfNeeded: Bool)
    
    /// Sets the given activity item as the primary on the given activity.
    ///
    /// The primary activity item will typically be something like the score on a quiz.
    ///
    /// - Parameters:
    ///   - activityItem: The activity item to set as primary
    ///   - activity: The activity to which the item should be assigned
    func setPrimary(activityItem: CLSActivityItem, on activity: CLSActivity)
    
    /// Indicates that the student has stopped working on the activity associated with the context at the given identifier path. If `resignActive` is `true` the context will also be set as not active.
    ///
    /// - Parameters:
    ///   - identifierPath: Path to the desired context
    ///   - resignActive: Flag to indicate if the context should also resign active in addition to stopping the activity. Defaults to `true`.
    func stopActivity(for identifierPath: [String], resignActive: Bool)
}

public extension ClassKitEnabled {
    func saveClassKitData() {
        dataStore.save { (error) in
            if let error = error {
                self.reportError(ClassKitError.classKitError(underlyingError: error))
            }
        }
    }
    
    func startActivity(for identifierPath: [String], completion: @escaping(CLSContext?, CLSActivity?, Error?) -> Void) {
        dataStore.mainAppContext.descendant(matchingIdentifierPath: identifierPath) { (context, error) in
            guard let context = context else {
                completion(nil, nil, ClassKitError.contextNotFound(identifierPath: identifierPath))
                return
            }
            context.becomeActive()
            let activity = context.createNewActivity()
            activity.start()
            completion(context, activity, error)
        }
    }
    
    func addAdditional(activityItem: CLSActivityItem, for identifierPath: [String], startIfNeeded: Bool = true) {
        dataStore.mainAppContext.descendant(matchingIdentifierPath: identifierPath) { (context, error) in
            if let error = error {
                self.reportError(ClassKitError.classKitError(underlyingError: error))
            }
            guard let context = context else {
                self.reportError(ClassKitError.contextNotFound(identifierPath: identifierPath))
                return
            }
            let activity: CLSActivity
            if context.currentActivity != nil {
                activity = context.currentActivity!
            } else if startIfNeeded {
                activity = context.createNewActivity()
            } else {
                self.reportError(ClassKitError.noActivity(identifierPath: identifierPath))
                return
            }
            if startIfNeeded && !activity.isStarted {
                activity.start()
            }
            
            self.addAdditional(activityItem: activityItem, to: activity)
        }
    }
    
    func addAdditional(activityItem: CLSActivityItem, to activity: CLSActivity) {
        activity.addAdditionalActivityItem(activityItem)
        self.saveClassKitData()
    }
    
    func setProgress(_ progress: Double, for identifierPath: [String], startIfNeeded: Bool = true) {
        dataStore.mainAppContext.descendant(matchingIdentifierPath: identifierPath) { (context, error) in
            if let error = error {
                self.reportError(ClassKitError.classKitError(underlyingError: error))
            }
            guard let context = context else {
                self.reportError(ClassKitError.contextNotFound(identifierPath: identifierPath))
                return
            }
            let activity: CLSActivity
            if context.currentActivity != nil {
                activity = context.currentActivity!
            } else if startIfNeeded {
                activity = context.createNewActivity()
            } else {
                self.reportError(ClassKitError.noActivity(identifierPath: identifierPath))
                return
            }
            if startIfNeeded && !activity.isStarted {
                activity.start()
            }
            self.setProgress(progress, on: activity)
        }
    }
    
    func setProgress(_ progress: Double, on activity: CLSActivity) {
        activity.progress = progress
        saveClassKitData()
    }
    
    func setPrimary(activityItem: CLSActivityItem, for identifierPath: [String], startIfNeeded: Bool = true) {
        dataStore.mainAppContext.descendant(matchingIdentifierPath: identifierPath) { (context, error) in
            if let error = error {
                self.reportError(ClassKitError.classKitError(underlyingError: error))
            }
            guard let context = context else {
                self.reportError(ClassKitError.contextNotFound(identifierPath: identifierPath))
                return
            }
            let activity: CLSActivity
            if context.currentActivity != nil {
                activity = context.currentActivity!
            } else if startIfNeeded {
                activity = context.createNewActivity()
            } else {
                self.reportError(ClassKitError.noActivity(identifierPath: identifierPath))
                return
            }
            if startIfNeeded && !activity.isStarted {
                activity.start()
            }
            self.setPrimary(activityItem: activityItem, on: activity)
        }
    }
    
    func setPrimary(activityItem: CLSActivityItem, on activity: CLSActivity) {
        activity.primaryActivityItem = activityItem
        saveClassKitData()
    }
    
    func stopActivity(for identifierPath: [String], resignActive: Bool = true) {
        dataStore.mainAppContext.descendant(matchingIdentifierPath: identifierPath) { (context, error) in
            if let error = error {
                self.reportError(ClassKitError.classKitError(underlyingError: error))
            }
            guard let context = context else {
                self.reportError(ClassKitError.contextNotFound(identifierPath: identifierPath))
                return
            }
            guard let activity = context.currentActivity else {
                self.reportError(ClassKitError.noActivity(identifierPath: identifierPath))
                return
            }
            activity.stop()
            if resignActive {
                context.resignActive()
            }
            self.saveClassKitData()
        }
    }
}
