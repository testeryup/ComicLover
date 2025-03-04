class Manga {
  final String id;
  final String title;
  final String slug;
  final String thumbUrl;
  final String description;
  final String status;
  final int currentChapter;
  final List<dynamic> chapters;
  final List<String> authors;
  final List<Map<String, dynamic>> categories;

  Manga({
    required this.id,
    required this.title,
    required this.slug,
    required this.thumbUrl,
    required this.description,
    required this.status,
    this.currentChapter = 0,
    this.chapters = const [],
    this.authors = const [],
    this.categories = const [],
  });

  // Lấy số chapter thực tế từ dữ liệu API nếu có
  int getActualCurrentChapter() {
    if (chapters.isNotEmpty) {
      for (var server in chapters) {
        if (server['server_name'] == 'Server #1' &&
            server['server_data'] != null) {
          final serverData = server['server_data'] as List;
          return serverData.length;
        }
      }
    }
    return currentChapter > 0 ? currentChapter : 0;
  }

  factory Manga.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    if (data == null) {
      return Manga(
        id: '',
        title: '',
        slug: '',
        thumbUrl: '',
        description: '',
        status: '',
      );
    }

    final item = data['item'];
    final appDomainCdnImage =
        data['APP_DOMAIN_CDN_IMAGE'] ?? 'https://img.otruyenapi.com';

    // Tính toán số chapter hiện có
    int currentChapCount = 0;
    List<dynamic> chaptersData = item['chapters'] ?? [];
    for (var server in chaptersData) {
      if (server['server_name'] == 'Server #1' &&
          server['server_data'] != null) {
        currentChapCount = (server['server_data'] as List).length;
        break;
      }
    }

    return Manga(
      id: item['_id'] ?? '',
      title: item['name'] ?? '',
      slug: item['slug'] ?? '',
      thumbUrl:
          item['thumb_url'] != null
              ? '$appDomainCdnImage/uploads/comics/${item['thumb_url']}'
              : '',
      description: item['content'] ?? '',
      status: item['status'] == 'ongoing' ? 'Đang cập nhật' : 'Hoàn thành',
      currentChapter: currentChapCount,
      chapters: chaptersData,
      authors: List<String>.from(item['author'] ?? []),
      categories: List<Map<String, dynamic>>.from(item['category'] ?? []),
    );
  }
}
