class Manga {
  final String id;
  final String title;
  final String slug;
  final String thumbUrl;
  final String description;
  final String status;
  final int currentChapter;
  Manga({
    required this.id,
    required this.title,
    required this.slug,
    required this.thumbUrl,
    required this.description,
    required this.status,
    required this.currentChapter,
  });

  factory Manga.fromJson(Map<String, dynamic> json) {
    return Manga(
      id: json['item']['_id'] ?? '',
      title: json['item']['name'] ?? '',
      slug: json['item']['slug'] ?? '',
      description: json['item']['content'] ?? '',
      status: json['item']['status'] ?? '',
      thumbUrl:
          "https://img.otruyenapi.com/uploads/comics/$json['item']['thumb_url']",
      currentChapter:
          json['item']['chapters'] != null
              ? _countTotalChapters(json['item']['chapter'])
              : 0,
    );
  }

  static int _countTotalChapters(List<dynamic> servers) {
    try {
      // Tìm server #1
      var server1 = servers.firstWhere(
        (server) => server['server_name'] == 'Server #1',
        orElse: () => {'server_data': []},
      );

      // Đếm số chapter trong server #1
      return (server1['server_data'] as List).length;
    } catch (e) {
      print('Error counting chapters: $e');
      return 0;
    }
  }
  // static int _countTotalChapters(List<dynamic> servers) {
  //   try {
  //     // Nếu không có server nào
  //     if (servers.isEmpty) return 0;

  //     // Tìm server có nhiều chapter nhất (thường là server đầy đủ nhất)
  //     int maxChapters = 0;

  //     for (var server in servers) {
  //       if (server['server_data'] != null) {
  //         int serverChapters = (server['server_data'] as List).length;
  //         if (serverChapters > maxChapters) {
  //           maxChapters = serverChapters;
  //         }
  //       }
  //     }

  //     return maxChapters;
  //   } catch (e) {
  //     print('Error counting chapters: $e');
  //     return 0;
  //   }
  // }
}
