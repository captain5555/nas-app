import Foundation

enum UsageTag: String, Codable, CaseIterable {
    case unused = "unused"
    case used = "used"

    var displayName: String {
        switch self {
        case .unused: return "未使用"
        case .used: return "使用过"
        }
    }
}

enum ViralTag: String, Codable, CaseIterable {
    case notViral = "not_viral"
    case viral = "viral"

    var displayName: String {
        switch self {
        case .notViral: return "未爆"
        case .viral: return "爆款"
        }
    }
}

struct MaterialTags: Codable {
    var usage: UsageTag
    var viral: ViralTag
}
