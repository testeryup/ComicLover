import 'package:flutter/material.dart';
import 'package:getting_started/core/services/saved_manga.dart';
import 'package:getting_started/data/models/manga.dart';
import 'package:getting_started/presentation/widgets/manga_card.dart';
import 'package:getting_started/core/navigation/manga_navigator.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({Key? key}) : super(key: key);

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

// Thay đổi phần build để sử dụng state cho danh sách manga đã sắp xếp
class _SavedScreenState extends State<SavedScreen> {
  final SavedMangaService _savedService = SavedMangaService();
  late List<Manga> _displayedMangas;

  @override
  void initState() {
    super.initState();
    _displayedMangas = _savedService.getSavedMangas();
  }

  @override
  Widget build(BuildContext context) {
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
          _displayedMangas.isEmpty
              ? _buildEmptyState()
              : _buildSavedMangaList(_displayedMangas),
    );
  }

  // Thêm phương thức _buildEmptyState
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Chưa có truyện nào được lưu',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thêm truyện để đọc sau',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/home');
            },
            icon: const Icon(Icons.search),
            label: const Text('Tìm truyện'),
          ),
        ],
      ),
    );
  }

  // Thêm phương thức _buildSavedMangaList
  Widget _buildSavedMangaList(List<Manga> mangas) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: mangas.length,
      itemBuilder: (context, index) {
        final manga = mangas[index];
        final lastReadChapter = _savedService.getLastReadChapter(manga.id);

        return MangaCard(
          manga: manga,
          lastReadChapter: lastReadChapter,
          onLongPress: () => _showMangaOptions(manga),
        );
      },
    );
  }

  // Thêm phương thức _showMangaOptions
  void _showMangaOptions(Manga manga) {
    final lastReadChapter = _savedService.getLastReadChapter(manga.id);

    showModalBottomSheet(
      context: context,
      builder:
          (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(manga.title),
                subtitle: Text(manga.status),
                leading: Image.network(
                  manga.thumbUrl,
                  width: 40,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          const Icon(Icons.broken_image),
                ),
              ),
              const Divider(),
              ListTile(
                title: const Text('Xem chi tiết'),
                leading: const Icon(Icons.info_outline),
                onTap: () {
                  Navigator.pop(context);
                  MangaNavigator.navigateToMangaDetail(context, manga);
                },
              ),
              if (lastReadChapter > 0)
                ListTile(
                  title: Text('Tiếp tục đọc (Chương ${lastReadChapter + 1})'),
                  leading: const Icon(Icons.play_arrow),
                  onTap: () {
                    Navigator.pop(context);
                    MangaNavigator.continueReading(
                      context,
                      manga,
                      lastReadChapter,
                    );
                  },
                )
              else
                ListTile(
                  title: const Text('Bắt đầu đọc'),
                  leading: const Icon(Icons.play_arrow),
                  onTap: () {
                    Navigator.pop(context);
                    MangaNavigator.navigateToChapter(context, manga.id, 1);
                  },
                ),
              ListTile(
                title: const Text('Xóa khỏi danh sách'),
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                onTap: () {
                  Navigator.pop(context);
                  _removeManga(manga);
                },
              ),
            ],
          ),
    );
  }

  // Sửa hàm _showSortOptions để thực sự thay đổi danh sách hiển thị
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
                  setState(() {
                    _displayedMangas =
                        _savedService.getSavedMangasSortedByName();
                  });
                },
                child: const Text('Tên (A-Z)'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _displayedMangas =
                        _savedService.getSavedMangasSortedByRecent();
                  });
                },
                child: const Text('Mới đọc gần đây nhất'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _displayedMangas =
                        _savedService.getSavedMangasSortedByProgress();
                  });
                },
                child: const Text('Tiến độ đọc cao nhất'),
              ),
            ],
          ),
    );
  }

  // Cập nhật phương thức _removeManga để cập nhật UI đúng cách
  void _removeManga(Manga manga) {
    setState(() {
      _savedService.removeManga(manga.id);
      // Cập nhật lại danh sách hiển thị
      _displayedMangas =
          _displayedMangas.where((m) => m.id != manga.id).toList();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã xóa ${manga.title}'),
        action: SnackBarAction(
          label: 'Hoàn tác',
          onPressed: () {
            setState(() {
              _savedService.addManga(manga);
              // Thêm lại manga vào danh sách hiển thị
              _displayedMangas.add(manga);
            });
          },
        ),
      ),
    );
  }
}
