//
//  PersistenceController.swift
//
//
//  Created by Ilian Konchev on 5.10.21.
//

import CoreData
import os

extension FileManager: @retroactive @unchecked Sendable {}

/// Configures and manages the CoreData stack for storing notifications.
public struct PersistenceController: Sendable {
    /// Test instance with in-memory store.
    public static let test = PersistenceController(inMemory: true)
    /// App instance configured for iOS with persistent storage.
    public static let app = PersistenceController(target: .iOSApp, inMemory: false)
    /// The persistent container managing the CoreData stack.
    public let container: NSPersistentContainer
    private let fileManager = FileManager.default

    /// Creates a persistence controller.
    /// - Parameters:
    ///   - target: App target for configuring shared containers.
    ///   - inMemory: Whether to use in-memory storage for testing.
    public init(target: AppTarget? = nil, inMemory: Bool = false) {
        if let modelURL = Bundle.module.url(forResource: "Zeplin", withExtension: "momd"),
            let model = NSManagedObjectModel(contentsOf: modelURL)
        {
            container = NSPersistentContainer(name: "Zeplin", managedObjectModel: model)
        } else {
            container = NSPersistentContainer(name: "Zeplin")
        }

        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        } else {
            guard let target = target else { return }
            #if !os(watchOS)
                guard let fileContainer = fileManager.containerURL(forSecurityApplicationGroupIdentifier: target.groupIdentifier) else {
                    fatalError("Shared file container could not be created.")
                }

                let storeURL = fileContainer.appendingPathComponent("Zeplin.sqlite")
                os_log("DB at %@", log: OSLog.app, type: .debug, storeURL.absoluteString)
                let storeDescription = NSPersistentStoreDescription(url: storeURL)
                storeDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
                storeDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
                container.persistentStoreDescriptions = [storeDescription]
            #else
                if let location = container.persistentStoreDescriptions.first?.apiURL?.absoluteString {
                    os_log("DB at %@", log: OSLog.app, type: .debug, location)
                }
            #endif
        }

        container.loadPersistentStores(completionHandler: { [weak container] _, error in  // storeDescription, error
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate.
                // You should not use this function in a shipping application, although
                // it may be useful during development.

                // Typical reasons for an error here include:
                // * The parent directory does not exist, cannot be created, or disallows writing.
                // * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                // * The device is out of space.
                // * The store could not be migrated to the current model version.
                // Check the error message to determine what the actual problem was.
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }

            container?.viewContext.name = "viewContext"
            container?.viewContext.automaticallyMergesChangesFromParent = true
            if let target = target {
                container?.viewContext.transactionAuthor = target.transactionAuthor
            }
        })
    }
}
