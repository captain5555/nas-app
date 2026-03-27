import Foundation
import CoreData

extension Folder {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Folder> {
        return NSFetchRequest<Folder>(entityName: "Folder")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var path: String?
    @NSManaged public var name: String?
    @NSManaged public var parentFolderID: UUID?
    @NSManaged public var childrenFolders: NSSet?
    @NSManaged public var materials: NSSet?

}

extension Folder: Identifiable {

}
