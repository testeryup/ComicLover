import 'package:getting_started/data/models/manga.dart';

class SavedMangaService {
  // Singleton pattern
  static final SavedMangaService _instance = SavedMangaService._internal();
  factory SavedMangaService() => _instance;
  SavedMangaService._internal();

  // Danh sách truyện đã lưu (mock data)
  final List<Manga> _savedMangas = [
    Manga(
      id: '657d148310dc9c0a7e2dd50d',
      title: "Xích Nguyệt",
      slug: "xich-nguyet",
      thumbUrl:
          'https://img.otruyenapi.com/uploads/comics/xich-nguyet-thumb.jpg',
      description:
          'Câu chuyện kể về một thiếu niên với vầng trăng màu đỏ, sở hữu sức mạnh bí ẩn có thể thay đổi vận mệnh thế giới.',
      status: 'Đang cập nhật',
      currentChapter: 57,
    ),
    Manga(
      id: '658e76fb68e54cf5b508fd97',
      title: 'Vưu Vật',
      slug: 'vuu-vat',
      thumbUrl: 'https://img.otruyenapi.com/uploads/comics/vuu-vat-thumb.jpg',
      description:
          'Trong thế giới nơi con người và sinh vật huyền bí chung sống, một thiếu niên phát hiện ra mình có khả năng giao tiếp với các sinh vật khác thường.',
      status: 'Đang cập nhật',
      currentChapter: 89,
    ),
    Manga(
      id: '65b202ad66b83f0711f2ca0e',
      title: 'Xin Chào! Bác Sĩ Thú Y',
      slug: 'xin-chao-bac-si-thu-y',
      thumbUrl:
          'https://img.otruyenapi.com/uploads/comics/xin-chao-bac-si-thu-y-thumb.jpg',
      description:
          'Cuộc sống thường ngày của một bác sĩ thú y trẻ tuổi tài năng, giải quyết các vấn đề sức khỏe cho thú cưng và xây dựng mối quan hệ với chủ của chúng.',
      status: 'Đang cập nhật',
    ),
    Manga(
      id: '658f7d7410dc9c0a7e2e4ce7',
      title: 'Vua Hiệp Sĩ Đã Trở Lại',
      slug: 'vua-hiep-si-da-tro-lai-voi-mot-vi-than',
      thumbUrl:
          'https://img.otruyenapi.com/uploads/comics/vua-hiep-si-da-tro-lai-voi-mot-vi-than-thumb.jpg',
      description:
          'Sau khi hy sinh trong trận chiến cuối cùng, vị vua hiệp sĩ huyền thoại được một vị thần hồi sinh và trở lại thế giới đã thay đổi sau 1000 năm.',
      status: 'Đang cập nhật',
    ),
    Manga(
      id: '6713687e80217a7ba9b9a0a5',
      title: 'Võng Du Thiên Hạ Vô Song',
      slug: 'vong-du-thien-ha-vo-song',
      thumbUrl:
          'https://img.otruyenapi.com/uploads/comics/vong-du-thien-ha-vo-song-thumb.jpg',
      description:
          'Một game thủ tầm thường bỗng nhiên nhận được năng lực đặc biệt trong thế giới game thực tế ảo, bắt đầu hành trình chinh phục đỉnh cao.',
      status: 'Đang cập nhật',
    ),
    Manga(
      id: '65a3b8dc31b3ad694edbef72',
      title: 'Tu Tiên Trở Về Tại Vườn Trường',
      slug: 'tu-tien-tro-ve-tai-vuon-truong',
      thumbUrl:
          'https://img.otruyenapi.com/uploads/comics/tu-tien-tro-ve-tai-vuon-truong-thumb.jpg',
      description:
          'Một tu tiên mạnh mẽ sau khi tu luyện vạn năm đã quay trở về trường học hiện đại nơi anh từng học, mang theo tri thức và sức mạnh phi thường.',
      status: 'Đang cập nhật',
    ),
  ];

  // Thông tin đọc của người dùng - Mock đọc thực tế hơn
  final Map<String, int> _lastReadChapter = {
    '657d148310dc9c0a7e2dd50d': 45, // Đã đọc Xích Nguyệt đến chap 45
    '658e76fb68e54cf5b508fd97': 76, // Đã đọc Vưu Vật đến chap 76
    '65b202ad66b83f0711f2ca0e': 12, // Đã đọc Xin Chào! Bác Sĩ Thú Y đến chap 12
    '6713687e80217a7ba9b9a0a5':
        80, // Đã đọc Võng Du Thiên Hạ Vô Song đến chap 80
    '65a3b8dc31b3ad694edbef72':
        95, // Đã đọc Tu Tiên Trở Về Tại Vườn Trường đến chap 95
  };

  // Thời gian truy cập lần cuối để sắp xếp theo đọc gần đây
  final Map<String, DateTime> _lastAccessTime = {
    '65b202ad66b83f0711f2ca0e': DateTime.now().subtract(
      const Duration(hours: 2),
    ), // 2 giờ trước
    '6713687e80217a7ba9b9a0a5': DateTime.now().subtract(
      const Duration(hours: 6),
    ), // 6 giờ trước
    '657d148310dc9c0a7e2dd50d': DateTime.now().subtract(
      const Duration(days: 1),
    ), // 1 ngày trước
    '65a3b8dc31b3ad694edbef72': DateTime.now().subtract(
      const Duration(days: 3),
    ), // 3 ngày trước
    '658e76fb68e54cf5b508fd97': DateTime.now().subtract(
      const Duration(days: 7),
    ), // 7 ngày trước
  };

  // Lấy danh sách truyện đã lưu
  List<Manga> getSavedMangas() {
    return _savedMangas;
  }

  // Lấy danh sách truyện đã lưu và sắp xếp theo tên
  List<Manga> getSavedMangasSortedByName() {
    final List<Manga> sortedList = List.from(_savedMangas);
    sortedList.sort((a, b) => a.title.compareTo(b.title));
    return sortedList;
  }

  // Lấy danh sách truyện đã lưu và sắp xếp theo truy cập gần đây
  List<Manga> getSavedMangasSortedByRecent() {
    final List<Manga> sortedList = List.from(_savedMangas);
    sortedList.sort((a, b) {
      final timeA = _lastAccessTime[a.id] ?? DateTime(2000);
      final timeB = _lastAccessTime[b.id] ?? DateTime(2000);
      return timeB.compareTo(timeA); // Sắp xếp giảm dần theo thời gian
    });
    return sortedList;
  }

  // Lấy danh sách truyện đã lưu và sắp xếp theo tiến độ đọc
  List<Manga> getSavedMangasSortedByProgress() {
    final List<Manga> sortedList = List.from(_savedMangas);
    sortedList.sort((a, b) {
      final progressA = (_lastReadChapter[a.id] ?? 0) / a.currentChapter;
      final progressB = (_lastReadChapter[b.id] ?? 0) / b.currentChapter;
      return progressB.compareTo(progressA); // Sắp xếp giảm dần theo tiến độ
    });
    return sortedList;
  }

  // Lấy chapter đã đọc của một truyện
  int getLastReadChapter(String mangaId) {
    return _lastReadChapter[mangaId] ?? 0;
  }

  // Lấy phần trăm tiến độ đọc
  double getReadingProgress(String mangaId) {
    final manga = _savedMangas.firstWhere(
      (element) => element.id == mangaId,
      orElse:
          () => Manga(
            id: '',
            title: '',
            slug: '',
            thumbUrl: '',
            description: '',
            status: '',
            currentChapter: 1,
          ),
    );

    if (manga.id.isEmpty || manga.currentChapter <= 0) return 0.0;

    final lastRead = _lastReadChapter[mangaId] ?? 0;
    return lastRead / manga.currentChapter;
  }

  // Cập nhật chapter đã đọc
  void updateLastReadChapter(String mangaId, int chapterNumber) {
    final currentLastRead = _lastReadChapter[mangaId] ?? 0;
    // Chỉ cập nhật nếu chapter mới lớn hơn chapter đã lưu
    if (chapterNumber > currentLastRead) {
      _lastReadChapter[mangaId] = chapterNumber;
    }
    _lastAccessTime[mangaId] = DateTime.now(); // Cập nhật thời gian truy cập
  }

  // Thêm truyện vào danh sách đã lưu
  // Thêm truyện vào danh sách đã lưu
  void addManga(Manga manga) {
    int existingIndex = _savedMangas.indexWhere(
      (element) => element.id == manga.id,
    );

    if (existingIndex != -1) {
      // Nếu truyện đã tồn tại, cập nhật thông tin mới
      Manga existingManga = _savedMangas[existingIndex];

      // Merge thông tin mới nhất
      _savedMangas[existingIndex] = Manga(
        id: manga.id,
        title: manga.title,
        slug: manga.slug,
        thumbUrl: manga.thumbUrl,
        description: manga.description,
        status: manga.status,
        currentChapter:
            manga.getActualCurrentChapter() > existingManga.currentChapter
                ? manga.getActualCurrentChapter()
                : existingManga.currentChapter,
        chapters:
            manga.chapters.isNotEmpty ? manga.chapters : existingManga.chapters,
        authors:
            manga.authors.isNotEmpty ? manga.authors : existingManga.authors,
        categories:
            manga.categories.isNotEmpty
                ? manga.categories
                : existingManga.categories,
      );
    } else {
      // Nếu truyện chưa tồn tại, thêm mới
      _savedMangas.add(manga);
    }

    // Cập nhật thời gian truy cập
    _lastAccessTime[manga.id] = DateTime.now();
  }

  // Xóa truyện khỏi danh sách đã lưu
  void removeManga(String mangaId) {
    _savedMangas.removeWhere((element) => element.id == mangaId);
    _lastReadChapter.remove(mangaId);
    _lastAccessTime.remove(mangaId);
  }

  // Kiểm tra truyện đã được lưu chưa
  bool isMangaSaved(String mangaId) {
    return _savedMangas.any((element) => element.id == mangaId);
  }

  // Tìm kiếm truyện trong danh sách đã lưu
  List<Manga> searchSavedMangas(String query) {
    if (query.isEmpty) return _savedMangas;

    final lowercaseQuery = query.toLowerCase();
    return _savedMangas.where((manga) {
      return manga.title.toLowerCase().contains(lowercaseQuery) ||
          manga.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
}
