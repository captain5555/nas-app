enum UsageTag {
  unused('unused', '未使用'),
  used('used', '使用过');

  final String rawValue;
  final String displayName;
  const UsageTag(this.rawValue, this.displayName);

  static UsageTag fromRawValue(String value) {
    return UsageTag.values.firstWhere(
      (e) => e.rawValue == value,
      orElse: () => UsageTag.unused,
    );
  }
}

enum ViralTag {
  notViral('not_viral', '未爆'),
  viral('viral', '爆款');

  final String rawValue;
  final String displayName;
  const ViralTag(this.rawValue, this.displayName);

  static ViralTag fromRawValue(String value) {
    return ViralTag.values.firstWhere(
      (e) => e.rawValue == value,
      orElse: () => ViralTag.notViral,
    );
  }
}

class MaterialTags {
  final UsageTag usage;
  final ViralTag viral;

  MaterialTags({
    required this.usage,
    required this.viral,
  });

  MaterialTags copyWith({
    UsageTag? usage,
    ViralTag? viral,
  }) {
    return MaterialTags(
      usage: usage ?? this.usage,
      viral: viral ?? this.viral,
    );
  }
}
