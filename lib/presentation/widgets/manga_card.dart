import 'package:flutter/material.dart';
import 'package:getting_started/core/navigation/manga_navigator.dart';
import 'package:getting_started/core/services/saved_manga.dart';
import 'package:getting_started/data/models/manga.dart';

class MangaCard extends StatelessWidget {
  final Manga manga;
  final int lastReadChapter;
  final VoidCallback? onLongPress;

  const MangaCard({
    Key? key,
    required this.manga,
    this.lastReadChapter = 0,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => MangaNavigator.navigateToMangaDetail(context, manga),
      onLongPress: onLongPress ?? () => _showOptions(context),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh bìa truyện
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Ảnh bìa
                  Image.network(
                    manga.thumbUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey[600],
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            value:
                                loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                          ),
                        ),
                      );
                    },
                  ),

                  // Hiển thị trạng thái đọc
                  if (lastReadChapter > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$lastReadChapter/${manga.currentChapter}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),

                  // Nút đọc tiếp
                  if (lastReadChapter > 0)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: FloatingActionButton.small(
                        heroTag: 'continue_${manga.id}',
                        onPressed: () {
                          MangaNavigator.continueReading(
                            context,
                            manga,
                            lastReadChapter,
                          );
                        },
                        child: const Icon(Icons.play_arrow),
                      ),
                    ),
                ],
              ),
            ),

            // Tên truyện
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                manga.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    final SavedMangaService _savedService = SavedMangaService();

    showModalBottomSheet(
      context: context,
      builder:
          (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Tiếp tục đọc'),
                subtitle:
                    lastReadChapter > 0
                        ? Text('Chapter ${lastReadChapter + 1}')
                        : Text('Bắt đầu đọc'),
                leading: Icon(Icons.play_arrow),
                onTap: () {
                  Navigator.pop(context);
                  MangaNavigator.continueReading(
                    context,
                    manga,
                    lastReadChapter,
                  );
                },
              ),
              ListTile(
                title: Text('Xem chi tiết truyện'),
                leading: Icon(Icons.info_outline),
                onTap: () {
                  Navigator.pop(context);
                  MangaNavigator.navigateToMangaDetail(context, manga);
                },
              ),
              if (_savedService.isMangaSaved(manga.id))
                ListTile(
                  title: Text('Xóa khỏi danh sách'),
                  leading: Icon(Icons.delete_outline, color: Colors.red),
                  onTap: () {
                    _savedService.removeManga(manga.id);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã xóa ${manga.title}'),
                        action: SnackBarAction(
                          label: 'Hoàn tác',
                          onPressed: () {
                            _savedService.addManga(manga);
                          },
                        ),
                      ),
                    );
                  },
                ),
              if (!_savedService.isMangaSaved(manga.id))
                ListTile(
                  title: Text('Lưu truyện'),
                  leading: Icon(Icons.bookmark_add_outlined),
                  onTap: () {
                    _savedService.addManga(manga);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Đã lưu ${manga.title}')),
                    );
                  },
                ),
            ],
          ),
    );
  }
}
