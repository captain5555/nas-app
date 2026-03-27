import Foundation

struct IndexFile: Codable {
    let version: Int
    let updatedAt: Date
    let files: [String: MaterialIndex]

    enum CodingKeys: String, CodingKey {
        case version
        case updatedAt = "updated_at"
        case files
    }
}

struct MaterialIndex: Codable {
    let title: String?
    let description: String?
    let tags: TagsIndex
    let updatedAt: Date
    let fileSize: Int64?
    let fileModifiedAt: Date?

    enum CodingKeys: String, CodingKey {
        case title
        case description
        case tags
        case updatedAt = "updated_at"
        case fileSize = "file_size"
        case fileModifiedAt = "file_modified_at"
    }
}

struct TagsIndex: Codable {
    let usage: String
    let viral: String
}
