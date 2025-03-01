import 'package:flutter/material.dart';
import 'package:getting_started/core/services/saved_manga.dart';
import 'package:getting_started/data/models/manga.dart';
import 'package:getting_started/presentation/widgets/managa_card.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({Key? key}) : super(key: key);

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  final SavedMangaService _savedService = SavedMangaService();

  @override
  Widget build(BuildContext context) {
    final savedMangas = _savedService.getSavedMangas();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Truyện đã lưu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              _showSortOptions(context);
            },
          ),
        ],
      ),
      body:
          savedMangas.isEmpty
              ? _buildEmptyState()
              : _buildSavedMangaList(savedMangas),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Bạn chưa lưu truyện nào',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/home');
            },
            child: const Text('Khám phá truyện ngay'),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedMangaList(List<Manga> mangas) {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: mangas.length,
      itemBuilder: (context, index) {
        final manga = mangas[index];
        final lastReadChapter = _savedService.getLastReadChapter(manga.id);

        return MangaCard(
          manga: manga,
          lastReadChapter: lastReadChapter,
          onTap: () => _openMangaDetail(manga),
          onLongPress: () => _showMangaOptions(manga),
        );
      },
    );
  }

  void _openMangaDetail(Manga manga) {
    // Navigation to manga detail screen
    Navigator.pushNamed(context, '/manga-detail', arguments: manga.id);
  }

  void _showMangaOptions(Manga manga) {
    final lastReadChapter = _savedService.getLastReadChapter(manga.id);

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
                  _continueReading(manga, lastReadChapter);
                },
              ),
              ListTile(
                title: Text('Xem chi tiết truyện'),
                leading: Icon(Icons.info_outline),
                onTap: () {
                  Navigator.pop(context);
                  _openMangaDetail(manga);
                },
              ),
              ListTile(
                title: Text('Xóa khỏi danh sách'),
                leading: Icon(Icons.delete_outline, color: Colors.red),
                onTap: () {
                  Navigator.pop(context);
                  _removeManga(manga);
                },
              ),
            ],
          ),
    );
  }

  void _continueReading(Manga manga, int lastReadChapter) {
    final nextChapter = lastReadChapter + 1;
    if (nextChapter <= manga.currentChapter) {
      Navigator.pushNamed(
        context,
        '/chapter-view',
        arguments: {'mangaId': manga.id, 'chapterNumber': nextChapter},
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bạn đã đọc đến chapter mới nhất')),
      );
    }
  }

  void _removeManga(Manga manga) {
    setState(() {
      _savedService.removeManga(manga.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã xóa ${manga.title}'),
        action: SnackBarAction(
          label: 'Hoàn tác',
          onPressed: () {
            setState(() {
              _savedService.addManga(manga);
            });
          },
        ),
      ),
    );
  }

  void _showSortOptions(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => SimpleDialog(
            title: const Text('Sắp xếp theo'),
            children: [
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  // Sort logic here
                },
                child: const Text('Tên (A-Z)'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  // Sort logic here
                },
                child: const Text('Mới đọc gần đây nhất'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  // Sort logic here
                },
                child: const Text('Mới cập nhật'),
              ),
            ],
          ),
    );
  }
}
