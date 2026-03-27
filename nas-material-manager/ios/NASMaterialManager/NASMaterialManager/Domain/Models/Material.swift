import Foundation

struct Material {
    let id: UUID
    let filename: String
    let path: String
    var title: String?
    var description: String?
    var tags: MaterialTags
    let fileSize: Int64?
    let fileModifiedAt: Date?
    var localUpdatedAt: Date
    let folderID: UUID?
}
