import Foundation
import CoreData

extension Material {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Material> {
        return NSFetchRequest<Material>(entityName: "Material")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var filename: String?
    @NSManaged public var path: String?
    @NSManaged public var title: String?
    @NSManaged public var descriptionText: String?
    @NSManaged public var usageTag: String?
    @NSManaged public var viralTag: String?
    @NSManaged public var fileSize: Int64
    @NSManaged public var fileModifiedAt: Date?
    @NSManaged public var localUpdatedAt: Date?
    @NSManaged public var folder: Folder?

}

extension Material: Identifiable {

}
