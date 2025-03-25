import 'package:flutter/material.dart';
import 'package:getting_started/core/services/saved_manga.dart';
import 'package:getting_started/data/models/manga.dart';
import 'package:getting_started/presentation/widgets/manga_card.dart';
import 'package:getting_started/core/navigation/manga_navigator.dart';
import 'package:getting_started/core/services/localization_service.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

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
        title: Text(context.tr('saved')),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              // Xử lý sắp xếp
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'name',
                    child: Text(context.tr('sort_by_name')),
                  ),
                  PopupMenuItem(
                    value: 'recent',
                    child: Text(context.tr('sort_by_recent')),
                  ),
                  PopupMenuItem(
                    value: 'progress',
                    child: Text(context.tr('sort_by_progress')),
                  ),
                ],
          ),
        ],
      ),
      body:
          _displayedMangas.isEmpty
              ? _buildEmptyState()
              : _buildSavedMangaList(_displayedMangas),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            context.tr('no_saved_comics'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('add_comics'),
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/home');
            },
            icon: const Icon(Icons.search),
            label: Text(context.tr('search')),
          ),
        ],
      ),
    );
  }

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
                title: Text(context.tr('detail')),
                leading: const Icon(Icons.info_outline),
                onTap: () {
                  Navigator.pop(context);
                  MangaNavigator.navigateToMangaDetail(context, manga);
                },
              ),
              if (lastReadChapter > 0)
                ListTile(
                  title: Text(
                    '${context.tr('continue_reading_chapter')} ${lastReadChapter + 1})',
                  ),
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
                  title: Text(context.tr('start_reading')),
                  leading: const Icon(Icons.play_arrow),
                  onTap: () {
                    Navigator.pop(context);
                    MangaNavigator.navigateToChapter(context, manga.id, 1);
                  },
                ),
              ListTile(
                title: Text(context.tr('delete_from_the_list')),
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

  void _showSortOptions(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => SimpleDialog(
            title: Text(context.tr('sort_by')),
            children: [
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _displayedMangas =
                        _savedService.getSavedMangasSortedByName();
                  });
                },
                child: Text(context.tr('sort_by_name')),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _displayedMangas =
                        _savedService.getSavedMangasSortedByRecent();
                  });
                },
                child: Text(context.tr('sort_by_recent')),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _displayedMangas =
                        _savedService.getSavedMangasSortedByProgress();
                  });
                },
                child: Text(context.tr('sort_by_progress')),
              ),
            ],
          ),
    );
  }

  void _removeManga(Manga manga) {
    setState(() {
      _savedService.removeManga(manga.id);
      _displayedMangas =
          _displayedMangas.where((m) => m.id != manga.id).toList();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${context.tr('deleted')} ${manga.title}'),
        action: SnackBarAction(
          label: context.tr('undo'),
          onPressed: () {
            setState(() {
              _savedService.addManga(manga);
              _displayedMangas.add(manga);
            });
          },
        ),
      ),
    );
  }
}
