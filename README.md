# HMHClassKitHelper
`HMHClassKitHelper` is a library for making ClassKit a little easier to use.

[![CI Status](https://img.shields.io/travis/theMikeSwan-HMH/HMHClassKitHelper.svg?style=flat)](https://travis-ci.org/theMikeSwan-HMH/HMHClassKitHelper)
[![Version](https://img.shields.io/cocoapods/v/HMHClassKitHelper.svg?style=flat)](https://cocoapods.org/pods/HMHClassKitHelper)
[![License](https://img.shields.io/cocoapods/l/HMHClassKitHelper.svg?style=flat)](https://cocoapods.org/pods/HMHClassKitHelper)
[![Platform](https://img.shields.io/cocoapods/p/HMHClassKitHelper.svg?style=flat)](https://cocoapods.org/pods/HMHClassKitHelper)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

### Overview of the example app
The example app allows you to navigate and read Shakespeare's Hamlet and Macbeth. It includes buttons to simulate completing a practice quiz and a graded quiz.

On a device with Schoolwork installed a teacher can assign the various scenes and then see how the students are progressing (what percentage they have read, if they have completed the practice quiz, what score they got on the graded quiz, and how long they spent on the assignment).

When a student opens as assignment in schoolwork and taps on a task in the example app they will be taken to the right place within the app to start the assignment.

The example includes a context provider extension as well which means the teacher does not need to launch the app before being able to see its content.

### Areas of interest
#### App
In the app itself the ClassKit related bits are primarily located in `AppDelegate.swift` and `SceneViewController.swift`. The app delegate takes care of the setup portion along with navigating to the correct view controller based on the incoming ClassKit activity. The scene view controller is the one that reports student progress to ClassKit.

In `AppDelegate` you will find the setup portion happens in `application(_ , didFinishLaunchingWithOptions: )`. When a student taps on an assignment the incoming user activity is taken care of in `application(_: continue: restorationHandler: )`.

#### Extension
The extension only has one file with any Swift code in it, `ContextRequestHandler.swift`. All of the action happens in `updateDescendants(of: completion: )` with the setup happening in `beginRequest(with: )`.

It should be noted that you can normally copy the contents of `updateDescendants(of: completion: )` and paste them into your own app as they rarely need to change. The only reason the at code has not been put into a protocol with an extension is that for some reason it only works if it is actually in the `ContextRequestHandler.swift` file. You can also find a copy of the code in the usage section below.

## Requirements
- iOS 11.4 or higher.
- An Apple Developer Account with ClassKit enabled. (You have to tell Apple that you make educational apps to use ClassKit).

## Installation

HMHClassKitHelper is available through a private CocoaPods spec repo, [HMHPods](https://github.com/theMikeSwan-HMH/HMHPods.git). To install the pod: 

If you do not yet have the HMHPods repo on your machine you will need to add it first:

```bash
pod repo add HMHPods https://github.com/theMikeSwan-HMH/HMHPods.git
```

Once the HMHPods repo is on your local machine you need to add it and the default spec repo to your Podfile. (Note that if you are not using any public pods you can skip the first line but if someone goes to add a public repo later they may be confused as tp why it doesn't work.)

Add the following lines to the top of your Podfile:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/theMikeSwan-HMH/HMHPods.git'
```
In the desired target(s) of your Podfile:

```ruby
pod 'HMHClassKitHelper'
```

If you prefer to not use CocoaPods you can just drag the `.swift` files from `HMHClassKitHelper/Classes` into your project.

## Usage
*It should be noted that this usage description assumes you are already familiar with how to use ClassKit and how to breakdown your content in an appropriate manner for ClassKit.*

### Data setup
In order for `ClassKitHelper` to do its thing your content needs to be in JSON format with the keys listed below:

```json
{
    "displayOrder" : 0,
    "title" : "Hamlet",
    "identifier" : "hamlet",
    "typeInt" : 0,
    "children" : [
        …
    ]
}

```

The nesting of children can be as deep as you want but keep in mind that the whole tree has to be traversed when the app declares all contexts.

There should be a separate JSON file for each bit of your content that should appear at the root level. If your app had a series of books then each book would have its own file, or if your app displays plays each play would have it's own file (you can check the example app under Resources if you want to see two complete JSON files).

### App usage
#### Declare Contexts
Apple recommends that ClassKit apps declare contexts as soon as possible. This means that any content the app knows about at launch should be declared in `application(_ , didFinishLaunchingWithOptions: )`.

Before you can have `ClassKitHelper` declare the contexts for you it needs to know about the content files. Each content file in the app needs to be added to `ClassKitHelper` with `addJSON(file: )`.

Once the files have been added you can call `declareContexts()`. Depending on the complexity of your content this could take a non-trivial amount of time to complete, so it is recommended to call it on a background thread to prevent UI issues. 

An example of adding the JSON files and declaring the contexts is below:

A free function:

``` swift
func contentFiles() -> [String] {
    let files = [Bundle.main.path(forResource: "hamlet", ofType: "json"),
                 Bundle.main.path(forResource: "macbeth", ofType: "json")]
    
    return files.compactMap({ $0 })
}
```
Placed in `application(_ , didFinishLaunchingWithOptions: )`:

``` swift
let files = contentFiles()
DispatchQueue.global().async {
	for file in files {
		self.classKitHelper.addJSON(file: file)
	}
	self.classKitHelper.declareContexts()
}
```

The function `contentFiles()` is a free function (not in another type) so that it can be used by both the `AppDelegate` and the `ContextRequestHandler` in the extension. Plus it doesn't really fit in any of the existing types in the project and a type with a single function seems rather useless.

Once the contexts have been declared the only bits that are left are to report student progress and navigate to the proper screen when the student taps an assignment in Schoolwork. `HMHClassKitHelper` doesn't provide any assistance with navigating to the proper screen but the example app does show one way of doing it.

#### Report Student Progress
Any class that will be reporting progress to ClassKit should conform to the `ClassKitEnabled` protocol. Most bits of the protocol have default implementations but you will need to create a `dataStore` property of type `ClassKitDataStore` but it can be the shared one:

```swift
var dataStore: ClassKitDataStore = CLSDataStore.shared
```

You will also need to implement `reportError(_: )` as it will vary based on the app.

The first bit of progress we will want to report to ClassKit is when the student starts working on a context. This is the most verbose part:

*Note: In the following examples `identifierPath` is used numerous times, it is of type `[String]`. In the example app it is a computed property.*

```swift
startActivity(for: identifierPath) { (context, activity, error) in
    guard let activity = activity else {
        if let error = error as? ClassKitError {
            self.reportError(error)
        } else if let error = error {
            self.reportError(ClassKitError.classKitError(underlyingError: error))
        }
        return
    }
    // Add any additional activity items, etc to the newly started activity.
    self.saveClassKitData()
}
```

##### When the student is done working on a context we need to tell ClassKit about it:

```swift
stopActivity(for: identifierPath)
```

##### When we want to tell ClassKit about the student completing a binary type task (such as simply completing a task or completing a pass/fail task that has no score):

```swift
let activityItem = CLSBinaryItem(identifier: self.practiceIdentifier, title: self.practiceTitle, type: .yesNo)
activityItem.value = true
addAdditional(activityItem: activityItem, for: identifierPath)
```

##### To report a student's progress though a task such as reading:

```swift
let progress = …
setProgress(progress, for: identifierPath)
```

##### To set the primary activity item as a score:

```swift
let score = …
et scoreItem = CLSScoreItem(identifier: self.scoreIdentifier, title: self.scoreTitle, score: score, maxScore: 100.0)
setPrimary(activityItem: scoreItem, for: self.identifierPath, startIfNeeded: false)
```

### Context provider extension usage
In a context provider extension the goal is to be as fast as possible since calls to the extension mean a teacher is actively navigating our content in Schoolwork. The main difference between the app and extension is that the extension *only* provides the contexts that are direct descendants of the context it was given.

Just like when declaring contexts in the app we first need to tell `ClassKitHelper` about our content files. In the extension this is best done in `beginRequest(with: )`:

```swift
let files = contentFiles()
for file in files {
	helper.addJSON(file: file)
}
```

When ClassKit is looking for updated info about the descendants of a context it will call `updateDescendants(of: completion: )`. The below code (which is also in the example extension) can pretty much be copied and pasted in most cases with a couple minor changes if desired (you may not want to log a message when a context has no children for example). This could would have been placed in a protocol or another class in `HMHClassKitHelper` but for some reason it only works if it is directly in `ContextRequestHandler`:

``` swift
func updateDescendants(of context: CLSContext, completion: @escaping (Error?) -> Void) {
	var error: Error? = nil
        
	guard let model = helper.contextModel(for: Array(context.identifierPath.dropFirst())) else {
		error = ClassKitError.contextNotFound(identifierPath: Array(context.identifierPath.dropFirst()))
		os_log(.error, log: self.log, "Unable to find a context model matching the path: %@", context.identifierPath)
       completion(error)
       return
	}
	guard let kids = model.children, kids.count > 0 else {
		os_log(.info, log: self.log, "The identifier path, %@, has no children.", context.identifierPath)
		completion(error)
		return
	}
        
	let predicate = NSPredicate(format: "%K = %@", CLSPredicateKeyPath.parent as CVarArg, context)
	CLSDataStore.shared.contexts(matching: predicate) { (childContexts, _) in
		for childNode in kids {
			if !childContexts.contains(where: { (context) -> Bool in
				context.identifier == childNode.identifier
			}), let childContext = self.helper.createContext(forIdentifier: childNode.identifier, parentContext: context, parentIdentifierPath: context.identifierPath) {
				context.addChildContext(childContext)
			}
		}
		CLSDataStore.shared.save(completion: { (error) in
            if let error = error {
                os_log(.error, log: self.log, "Save error: %s", error.localizedDescription)
            } else {
                os_log(.info, log: self.log, "Saved contexts")
            }
            completion(error)
        })
    }
}
```

In the above code we first make sure we can get an instance of `ContextModel` (the intermediary used by `HMHClassKitHelper` between `CLSContext`s and the JSON files). If we can't find a context for the identifier path we consider it an error (we should really have a `ContextModel` for every identifier path we get).

Once we have a model we then make sure it has children as there is nothing to do if it doesn't. We do not consider the lack of children an error though as all the bottom nodes will have no children. We do log an info message as that info may be useful if you have an issue where a context that should have children listed doesn't.

Once we have some children to work with we compare the list of children we have with those that already exist in the context we were given adding any from our list that are not in the context yet.

The last step is to save the data and log an error or info as appropriate.

## Author

theMikeSwan-HMH, michael.swan@hmhco.com

## License

HMHClassKitHelper is available under the MIT license. See the LICENSE file for more info.
