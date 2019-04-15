//
//  ContentFiles.swift
//  HMHClassKitHelper_Example
//
//  Created by Swan, Michael on 4/15/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//
// Putting the list of content files here allows them to be used in both the app and the extension. There are of course other options for supplying a list of all the content files and staying DRY (a plist is an obvious alternative).

import Foundation

/// Supplies an array of all the file paths that should be included in the content.
///
/// Keeping all of the files in one place makes it easy to add additional plays later.
///
/// - Returns: An array of file paths to the json files for the plays.
func contentFiles() -> [String] {
    let files = [Bundle.main.path(forResource: "hamlet", ofType: "json"),
                 Bundle.main.path(forResource: "macbeth", ofType: "json")]
    
    return files.compactMap({ $0 })
}
