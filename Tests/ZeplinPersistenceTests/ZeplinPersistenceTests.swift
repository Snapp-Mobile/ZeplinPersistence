import CoreData
import XCTest

@testable import ZeplinPersistence

final class ZeplinPersistenceTests: XCTestCase {
    func testInMemoryPersistenceStoresSaveAndFetchNotifications() throws {
        let controller = PersistenceController.test
        let context = controller.container.viewContext

        let notification = NotificationRecord(context: context)
        notification.id = UUID()
        notification.notificationId = "test-123"
        notification.actionDescription = "commented on"
        notification.contextDescription = "Design System"
        notification.authorName = "Test User"
        notification.created = Date()
        notification.lastUpdated = Date()
        notification.isRead = false
        notification.originalData = Data()

        try context.save()

        let fetchRequest = NotificationRecord.findById("test-123")
        let results = try context.fetch(fetchRequest)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.notificationId, "test-123")
        XCTAssertEqual(results.first?.authorName, "Test User")
        XCTAssertFalse(results.first?.isRead ?? true)
    }
}
