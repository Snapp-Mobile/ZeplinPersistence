//
//  NotificationRecord+CoreDataClass.swift
//
//
//  Created by Ilian Konchev on 9.10.21.
//  Copyright © 2021 Ilian Konchev. All rights reserved.
//
//

import CoreData
import Foundation
import ZeplinKit

@objc(NotificationRecord)
public class NotificationRecord: NSManagedObject {
    @NSManaged public var actionDescription: String
    @NSManaged public var authorAvatarURL: URL?
    @NSManaged public var authorEmotar: String?
    @NSManaged public var authorName: String
    @NSManaged public var contextDescription: String
    @NSManaged public var created: Date
    @NSManaged public var id: UUID
    @NSManaged public var isRead: Bool
    @NSManaged public var lastUpdated: Date
    @NSManaged public var notificationId: String
    @NSManaged public var originalData: Data
    @NSManaged public var projectId: String?
    @NSManaged public var remoteImageURL: URL?
    @NSManaged public var screenId: String?

    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<NotificationRecord> {
        let request = NSFetchRequest<NotificationRecord>(entityName: "Notification")
        request.propertiesToFetch = [
            "actionDescription", "authorName", "authorAvatarURL", "authorEmotar",
            "created", "contextDescription", "isRead", "lastUpdated", "notificationId", "projectId",
            "remoteImageURL", "screenId",
        ]
        request.sortDescriptors = [
            NSSortDescriptor(key: "created", ascending: false)
        ]
        request.fetchBatchSize = 100
        request.returnsObjectsAsFaults = false
        return request
    }

    @nonobjc
    public class func fetchKnownNotifications() -> NSFetchRequest<NotificationRecord> {
        let request = NSFetchRequest<NotificationRecord>(entityName: "Notification")
        request.propertiesToFetch = ["created", "lastUpdated", "notificationId"]
        request.sortDescriptors = [
            NSSortDescriptor(key: "created", ascending: false)
        ]
        request.returnsObjectsAsFaults = false
        return request
    }

    @nonobjc
    public class func fetchLastCreatedNotification(debug: Bool = false) -> NSFetchRequest<NotificationRecord> {
        let request = NSFetchRequest<NotificationRecord>(entityName: "Notification")
        request.propertiesToFetch = ["created"]
        request.sortDescriptors = [
            NSSortDescriptor(key: "created", ascending: false)
        ]
        request.fetchLimit = 1
        request.fetchOffset = debug ? 1 : 0
        request.returnsObjectsAsFaults = false
        return request
    }

    @nonobjc
    public class func fetchLastUpdatedNotification(debug: Bool = false) -> NSFetchRequest<NotificationRecord> {
        let request = NSFetchRequest<NotificationRecord>(entityName: "Notification")
        request.propertiesToFetch = ["lastUpdated"]
        request.sortDescriptors = [
            NSSortDescriptor(key: "lastUpdated", ascending: false)
        ]
        request.fetchLimit = 1
        request.fetchOffset = debug ? 1 : 0
        request.returnsObjectsAsFaults = false
        return request
    }

    @nonobjc
    public class func findById(_ notificationId: String) -> NSFetchRequest<NotificationRecord> {
        let request = NSFetchRequest<NotificationRecord>(entityName: "Notification")
        request.predicate = NSPredicate(format: "notificationId = %@", notificationId)
        request.returnsObjectsAsFaults = false
        return request
    }
}

extension NotificationRecord {
    public static func create(with notification: ZeplinNotification, in context: NSManagedObjectContext) {
        let record = NotificationRecord(context: context)
        record.id = UUID()
        record.update(from: notification)
    }

    public func update(from notification: ZeplinNotification) {
        created = Date(timeIntervalSince1970: notification.created)
        notificationId = notification.id
        let lastUpdatedInterval = notification.updated ?? notification.created
        lastUpdated = Date(timeIntervalSince1970: lastUpdatedInterval)
        isRead = notification.isRead
        actionDescription = notification.actionDescription
        contextDescription = notification.contextDescription
        if let remoteImageURLStr = notification.screenVersion?.thumbnails["small"] {
            remoteImageURL = URL(string: remoteImageURLStr)
        }
        authorName = notification.actor.user?.username ?? "[unknown]"
        if let avatarURL = notification.actor.user?.avatarURL {
            authorAvatarURL = URL(string: avatarURL)
        }
        authorEmotar = notification.actor.user?.emotar

        let info = notification.userInfo
        projectId = info.projectId
        screenId = info.screenId

        do {
            originalData = try JSONEncoder().encode(notification)
        } catch {
            originalData = Data()
        }
    }

    public var representation: ZeplinNotificationRepresentation {
        return ZeplinNotificationRepresentation(
            id: notificationId,
            created: created.timeIntervalSince1970,
            lastUpdated: lastUpdated.timeIntervalSince1970,
            isRead: isRead
        )
    }

    public func matches(_ searchTerm: String, _ showsOnlyUnread: Bool) -> Bool {
        let term = searchTerm.lowercased()
        let termMatched =
            searchTerm.isEmpty ? true : (actionDescription.lowercased().contains(term) || contextDescription.lowercased().contains(term))
        if showsOnlyUnread {
            return termMatched && !isRead
        } else {
            return termMatched
        }
    }

    public func differsFrom(_ notification: ZeplinNotification) -> Bool {
        let date = notification.updated ?? notification.created
        return lastUpdated.timeIntervalSince1970 != date || created.timeIntervalSince1970 != notification.created
    }
}
