class RecentDocument {
  final String fileName;
  final String fileType;
  final String localFilePath;
  final DateTime lastAccessed;
  final String uniqueFilename;

  RecentDocument({
    required this.fileName,
    required this.fileType,
    required this.localFilePath,
    required this.lastAccessed,
    required this.uniqueFilename,
  });

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'fileType': fileType,
      'localFilePath': localFilePath,
      'lastAccessed': lastAccessed.toIso8601String(),
      'uniqueFilename': uniqueFilename,
    };
  }

  factory RecentDocument.fromJson(Map<String, dynamic> json) {
    // return RecentDocument(
    //   fileName: json['fileName'] ,
    //   fileType: json['fileType'],
    //   localFilePath: json['localFilePath'],
    //   lastAccessed: DateTime.parse(json['lastAccessed']),
    //   uniqueFilename: json['uniqueFilename'],
    // );
    return RecentDocument(
        fileName: json['fileName'] ?? '',
        fileType: json['fileType'] ?? '',
        localFilePath: json['localFilePath'] ?? '',
        lastAccessed:
            DateTime.tryParse(json['lastAccessed'] ?? '') ?? DateTime.now(),
        uniqueFilename: json['uniqueFilename'] ?? '');
  }
}
