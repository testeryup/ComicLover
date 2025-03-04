class Chapter {
  final String id;
  final int number;
  final String title;
  final String apiUrl;

  Chapter({
    required this.id,
    required this.number,
    required this.title,
    required this.apiUrl,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['chapter_api_data'] ?? '',
      number: int.tryParse(json['chapter_name'] ?? '0') ?? 0,
      title: json['chapter_title'] ?? '',
      apiUrl: json['chapter_api_data'] ?? '',
    );
  }
}
