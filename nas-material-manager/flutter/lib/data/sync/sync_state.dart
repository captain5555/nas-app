enum SyncState { idle, checking, downloading, uploading, error }

class SyncStatus {
  final SyncState state;
  final DateTime? lastSyncAt;
  final double? progress;
  final String? errorMessage;

  SyncStatus({
    required this.state,
    this.lastSyncAt,
    this.progress,
    this.errorMessage,
  });

  SyncStatus copyWith({
    SyncState? state,
    DateTime? lastSyncAt,
    double? progress,
    String? errorMessage,
  }) {
    return SyncStatus(
      state: state ?? this.state,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      progress: progress ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
