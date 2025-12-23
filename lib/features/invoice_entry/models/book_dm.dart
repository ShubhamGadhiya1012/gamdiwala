class BookDm {
  final String bookCode;
  final String description;

  BookDm({required this.bookCode, required this.description});

  factory BookDm.fromJson(Map<String, dynamic> json) {
    return BookDm(
      bookCode: json['BookCode'] ?? '',
      description: json['Description'] ?? '',
    );
  }
}
