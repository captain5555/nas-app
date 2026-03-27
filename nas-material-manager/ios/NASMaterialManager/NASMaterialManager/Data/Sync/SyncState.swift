import Foundation

enum SyncState {
    case idle
    case checking
    case downloading
    case uploading
    case error(String)
}

struct SyncStatus {
    let state: SyncState
    let lastSyncAt: Date?
    let progress: Double?
}
