class LegalSource {
  final String title;
  final String citation;

  /// 'Statute' or 'Official resource'.
  final String type;

  const LegalSource({
    required this.title,
    required this.citation,
    required this.type,
  });

  Map<String, dynamic> toJson() =>
      {'title': title, 'citation': citation, 'type': type};

  factory LegalSource.fromJson(Map<String, dynamic> j) => LegalSource(
        title: j['title'] as String,
        citation: j['citation'] as String,
        type: j['type'] as String,
      );
}
