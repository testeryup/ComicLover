import 'package:flutter/material.dart';
import 'package:getting_started/data/models/manga.dart';
import 'package:getting_started/core/services/saved_manga.dart';
import 'package:getting_started/presentation/screens/manga/chapter_view_screen.dart';

class MangaNavigator {
  /// Điều hướng đến màn hình chi tiết truyện bằng ID
  static void navigateToMangaDetailById(BuildContext context, String mangaId) {
    print("navigateToMangaDetailById: $mangaId");
    Navigator.pushNamed(context, '/manga-detail', arguments: mangaId);
  }

  /// Điều hướng đến màn hình chi tiết truyện bằng slug
  static void navigateToMangaDetailBySlug(BuildContext context, String slug) {
    print("navigateToMangaDetailBySlug: $slug");
    Navigator.pushNamed(context, '/manga-detail', arguments: 'slug:$slug');
  }

  /// Điều hướng đến màn hình chi tiết truyện bằng object Manga
  static void navigateToMangaDetail(BuildContext context, Manga manga) {
    print("navigateToMangaDetail: $manga");
    Navigator.pushNamed(
      context,
      '/manga-detail',
      arguments: {'mangaId': manga.id, 'slug': manga.slug},
    );
  }

  /// Điều hướng đến màn hình đọc chapter bằng ID manga và số chapter
  static void navigateToChapter(
    BuildContext context,
    String mangaId,
    int chapterNumber,
  ) {
    print(
      "Calling navigateToChapter with: mangaId=$mangaId, chapterNumber=$chapterNumber",
    );

    // Không sử dụng named route, dùng trực tiếp MaterialPageRoute
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ChapterViewScreen(
              mangaId: mangaId,
              chapterNumber: chapterNumber,
              // Không cần truyền chapterUrl, ChapterViewScreen tự xử lý
            ),
      ),
    );
  }

  /// Điều hướng đến màn hình đọc chapter bằng URL API của chapter
  static void navigateToChapterByUrl(
    BuildContext context,
    String mangaId,
    int chapterNumber,
    String chapterUrl,
  ) {
    print("Navigating to chapter with URL: $chapterUrl");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ChapterViewScreen(
              mangaId: mangaId,
              chapterNumber: chapterNumber,
              chapterUrl: chapterUrl,
            ),
      ),
    );
  }

  /// Điều hướng đến màn hình đọc chapter từ đối tượng Manga
  static void continueReading(
    BuildContext context,
    Manga manga,
    int lastReadChapter,
  ) {
    final nextChapter = lastReadChapter > 0 ? lastReadChapter + 1 : 1;
    final actualCurrentChapter = manga.getActualCurrentChapter();

    if (nextChapter <= actualCurrentChapter) {
      navigateToChapter(context, manga.id, nextChapter);

      // Cập nhật chapter đã đọc
      final SavedMangaService _savedService = SavedMangaService();
      _savedService.updateLastReadChapter(manga.id, nextChapter);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn đã đọc đến chapter mới nhất')),
      );
    }
  }
}
