class RecentDocument {
  final String fileName;
  final String fileType;
  final DateTime lastAccessed;
  final String localFilePath;

  RecentDocument({
    required this.fileName,
    required this.fileType,
    required this.lastAccessed,
    required this.localFilePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'fileType': fileType,
      'lastAccessed': lastAccessed.toIso8601String(),
      'localFilePath': localFilePath,
    };
  }

  factory RecentDocument.fromJson(Map<String, dynamic> json) {
    return RecentDocument(
      fileName: json['fileName'] as String,
      fileType: json['fileType'] as String,
      lastAccessed: DateTime.parse(json['lastAccessed'] as String),
      localFilePath: json['localFilePath'] as String,
    );
  }
}
