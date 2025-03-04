import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:getting_started/data/models/manga.dart';
import 'package:getting_started/data/models/chapter.dart';
import 'package:getting_started/core/services/saved_manga.dart';

class MangaApiService {
  // Base URLs
  final String _baseUrl = 'https://otruyenapi.com/v1';

  // Cache dữ liệu để giảm số lượng request
  final Map<String, dynamic> _cache = {};

  // Singleton pattern
  static final MangaApiService _instance = MangaApiService._internal();
  factory MangaApiService() => _instance;
  MangaApiService._internal();

  /// Lấy thông tin chi tiết của một truyện dựa vào slug
  Future<Manga> getMangaBySlug(String slug) async {
    // Kiểm tra cache
    if (_cache.containsKey('manga_$slug')) {
      return _cache['manga_$slug'];
    }

    try {
      print('Fetching manga data for slug: $slug');
      final response = await http.get(
        Uri.parse('$_baseUrl/api/truyen-tranh/$slug'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] != 'success') {
          throw Exception(
            'API trả về lỗi: ${jsonData['message'] ?? 'Không rõ lỗi'}',
          );
        }

        final manga = Manga.fromJson(jsonData);

        // Lưu vào cache
        _cache['manga_$slug'] = manga;
        // Lưu mapping ID -> Slug để sau này có thể tìm bằng ID
        _cache['id_to_slug_${manga.id}'] = slug;
        _cache['manga_id_${manga.id}'] = manga;

        print('Successfully fetched manga: ${manga.title}');
        return manga;
      } else {
        throw Exception(
          'Không thể tải thông tin truyện: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching manga by slug: $e');
      // Nếu có lỗi, kiểm tra trong saved manga
      final SavedMangaService _savedService = SavedMangaService();
      final savedMangas = _savedService.getSavedMangas();
      final matchingManga = savedMangas.where((m) => m.slug == slug).toList();

      if (matchingManga.isNotEmpty) {
        return matchingManga.first;
      }

      throw Exception('Lỗi khi tải thông tin truyện: $e');
    }
  }

  /// Lấy thông tin chi tiết của một truyện dựa vào ID
  Future<Manga> getMangaById(String id) async {
    // Kiểm tra cache
    if (_cache.containsKey('manga_id_$id')) {
      return _cache['manga_id_$id'];
    }

    try {
      // Nếu chúng ta đã có mapping slug từ ID
      if (_cache.containsKey('id_to_slug_$id')) {
        String slug = _cache['id_to_slug_$id'];
        return getMangaBySlug(slug);
      }

      // Nếu không có cách lấy slug, trả về truyện từ SavedMangaService nếu có
      final SavedMangaService _savedService = SavedMangaService();
      if (_savedService.isMangaSaved(id)) {
        final savedMangas = _savedService.getSavedMangas();
        final manga = savedMangas.firstWhere(
          (m) => m.id == id,
          orElse: () => throw Exception('Không tìm thấy truyện với ID: $id'),
        );
        return manga;
      }

      throw Exception('Không thể tìm thấy thông tin truyện với ID: $id');
    } catch (e) {
      print('Error fetching manga by ID: $e');
      throw Exception('Lỗi khi tải thông tin truyện: $e');
    }
  }

  /// Lấy danh sách chapter của truyện
  Future<List<Chapter>> getChaptersList(String mangaId) async {
    // Kiểm tra cache
    if (_cache.containsKey('chapters_$mangaId')) {
      return _cache['chapters_$mangaId'];
    }

    try {
      // Nếu chúng ta đã có slug, lấy thông tin manga từ đó
      if (_cache.containsKey('id_to_slug_$mangaId')) {
        String slug = _cache['id_to_slug_$mangaId'];
        Manga manga = await getMangaBySlug(slug);
        return _extractChaptersFromManga(manga);
      }

      // Nếu chúng ta đã có thông tin manga từ cache ID
      if (_cache.containsKey('manga_id_$mangaId')) {
        Manga manga = _cache['manga_id_$mangaId'];
        return _extractChaptersFromManga(manga);
      }

      // Thử lấy từ SavedMangaService
      final SavedMangaService _savedService = SavedMangaService();
      if (_savedService.isMangaSaved(mangaId)) {
        // Lấy thông tin manga từ saved service
        final manga = _savedService.getSavedMangas().firstWhere(
          (m) => m.id == mangaId,
          orElse:
              () => throw Exception('Không tìm thấy truyện với ID: $mangaId'),
        );

        // Nếu manga từ saved service có thông tin chapter (từ API)
        if (manga.chapters.isNotEmpty) {
          return _extractChaptersFromManga(manga);
        }

        // Nếu không có thông tin chapter, tạo mock chapters dựa trên currentChapter
        final totalChapters = manga.getActualCurrentChapter();
        return List.generate(
          totalChapters,
          (index) => Chapter(
            id: 'local_${manga.id}_${index + 1}',
            number: index + 1,
            title: '',
            apiUrl: '', // Không có URL thực, sẽ phải xử lý đặc biệt khi đọc
          ),
        );
      }

      throw Exception(
        'Không thể lấy danh sách chapter: Không tìm thấy thông tin truyện',
      );
    } catch (e) {
      print('Error fetching chapters list: $e');
      return []; // Trả về danh sách trống trong trường hợp lỗi
    }
  }

  /// Trích xuất danh sách chapter từ đối tượng Manga
  List<Chapter> _extractChaptersFromManga(Manga manga) {
    List<Chapter> chapters = [];

    try {
      // Xử lý cấu trúc servers và chapters từ response API
      for (var server in manga.chapters) {
        if (server['server_name'] == 'Server #1' &&
            server['server_data'] != null) {
          var serverData = server['server_data'] as List<dynamic>;

          for (var chapterData in serverData) {
            chapters.add(
              Chapter(
                id: chapterData['chapter_api_data'] ?? '',
                number: int.tryParse(chapterData['chapter_name'] ?? '0') ?? 0,
                title: chapterData['chapter_title'] ?? '',
                apiUrl: chapterData['chapter_api_data'] ?? '',
              ),
            );
          }

          // Chỉ lấy chapter từ server #1
          break;
        }
      }

      // Sắp xếp chapters theo thứ tự tăng dần
      chapters.sort((a, b) => a.number.compareTo(b.number));

      // Lưu vào cache
      _cache['chapters_${manga.id}'] = chapters;
    } catch (e) {
      print('Lỗi khi xử lý danh sách chapter: $e');
    }

    return chapters;
  }

  /// Lấy nội dung của một chapter
  Future<List<String>> getChapterImages(String chapterApiUrl) async {
    // Kiểm tra cache
    if (_cache.containsKey('chapter_images_$chapterApiUrl')) {
      return _cache['chapter_images_$chapterApiUrl'];
    }

    try {
      print('Fetching chapter images from: $chapterApiUrl');
      final response = await http.get(Uri.parse(chapterApiUrl));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == 'success' && jsonData['data'] != null) {
          final data = jsonData['data'];
          final domainCdn = data['domain_cdn'] ?? '';
          final item = data['item'];

          if (item != null &&
              item['chapter_path'] != null &&
              item['chapter_image'] != null) {
            final chapterPath = item['chapter_path'];
            final chapterImages = item['chapter_image'] as List<dynamic>;

            // Tạo URLs đầy đủ cho các trang
            List<String> imageUrls =
                chapterImages.map<String>((img) {
                  final imageFile = img['image_file'];
                  return '$domainCdn/$chapterPath/$imageFile';
                }).toList();

            // Lưu vào cache
            _cache['chapter_images_$chapterApiUrl'] = imageUrls;

            print('Successfully fetched ${imageUrls.length} chapter images');
            return imageUrls;
          }
        }

        throw Exception('Định dạng dữ liệu chapter không hợp lệ');
      } else {
        throw Exception(
          'Không thể tải hình ảnh chapter: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching chapter images: $e');
      // Trả về mock images trong trường hợp lỗi
      return _getMockChapterImages(chapterApiUrl);
    }
  }

  /// Lấy hình ảnh của một chapter dựa vào ID manga và số chapter
  Future<List<String>> getChapterImagesByMangaIdAndChapterNumber(
    String mangaId,
    int chapterNumber,
  ) async {
    try {
      // Lấy danh sách chapters
      final chapters = await getChaptersList(mangaId);

      // Tìm chapter theo số
      final chapter = chapters.firstWhere(
        (ch) => ch.number == chapterNumber,
        orElse: () => throw Exception('Không tìm thấy chapter $chapterNumber'),
      );

      // Nếu có API URL, gọi API để lấy dữ liệu
      if (chapter.apiUrl.isNotEmpty) {
        return getChapterImages(chapter.apiUrl);
      }

      // Nếu không có URL, tạo mock data
      return _getMockChapterImages("${mangaId}_${chapterNumber}");
    } catch (e) {
      print('Lỗi khi tải hình ảnh chapter: $e');
      return _getMockChapterImages("${mangaId}_${chapterNumber}");
    }
  }

  // Tạo mock images để test
  List<String> _getMockChapterImages(String key) {
    final hash = key.hashCode.abs();
    return List.generate(
      15 + (hash % 10), // 15-25 trang mỗi chapter
      (index) =>
          'https://picsum.photos/800/${1000 + (index % 5) * 50}?random=${hash}_$index',
    );
  }
}
