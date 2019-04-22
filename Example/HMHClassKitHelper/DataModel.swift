//
//  DataModel.swift
//  HMHClassKitHelper_Example
//
//  Created by Swan, Michael on 3/21/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//
// The three structs that make up the data model of the example app.
//
// Note that they use the same JSON data as the ContextModel struct used by HMHClassKitHelper.
// They extract the bits they need from teh data and map the children property to acts or scenes.

import UIKit


/// Represents an entire play
struct Play: Codable {
    let title: String
    let identifier: String
    let acts: [Act]
    
    // Since we want to call the children of a play acts we use the CodingKeys enum to map the name over.
    enum CodingKeys: String, CodingKey {
        case title
        case identifier
        case acts = "children"
    }
}

/// Represents a single act within a play
struct Act: Codable {
    let title: String
    let identifier: String
    let scenes: [Scene]
    var number: Int {
        return Int(title.replacingOccurrences(of: "Act ", with: "")) ?? 1
    }
    var displayTitle: String {
        return "Act \(number.romanNumeral)"
    }
    
    enum CodingKeys: String, CodingKey {
        case title
        case identifier
        case scenes = "children"
    }
}

/// Represents a single scene within an act of a play.
struct Scene: Codable {
    let title: String
    let identifier: String
    var number: Int {
        return Int(title.replacingOccurrences(of: "Scene ", with: "")) ?? 1
    }
    let contentPath: String
    
    /// Pulls the HTML string from adaptedHTML and converts it to an attributed string for use in text views.
    var contents: NSAttributedString {
        let data = Data(adaptedHTML().utf8)
        if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
            return attributedString
        }
        return NSAttributedString(string: "Unable to load scene text!")
    }
    
    /// Returns an HTML string with the text of the scene in it.
    ///
    /// The MIT website we use to get the text for each scene has a tables of links at the top and bottom of the page (some of which don't work), we don't want them in our app, but we do want to give them credit for supplying the text. This method grabs the HTML from shakespeare.mit.edu, strips out the tables of links and inserts credit just before the closing body tag.
    ///
    /// - Returns: HTML string for the scene.
    private func adaptedHTML() -> String {
        guard let url = URL(string: contentPath), let source = try? String(contentsOf: url) else { return "" }
        let parts = source.components(separatedBy: "<table")
        var intermediate = ""
        for part in parts {
            let x = part.components(separatedBy: "</table>")
            intermediate.append(x.last ?? "")
        }
        var y = intermediate.components(separatedBy: "</body>")
        if let scheme = url.scheme, let host = url.host {
            y.insert("<p>Script text courtesy of <a href=\"\(scheme)://\(host)\">\(host)</a></p>\n</body>", at: 1)
        } else {
            y.insert("\n</body>", at: 1)
        }
        let final = y.joined(separator: "")
        return final
    }
}
