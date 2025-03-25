import 'package:flutter/material.dart';
import 'package:getting_started/core/services/manga_api_service.dart';
import 'package:getting_started/core/services/saved_manga.dart';
import 'package:getting_started/data/models/chapter.dart';
import 'package:getting_started/data/models/manga.dart';
import 'package:getting_started/core/navigation/manga_navigator.dart';
import 'package:getting_started/core/services/localization_service.dart'; // Thêm import

class MangaDetailScreen extends StatefulWidget {
  final String mangaId;
  final String? slug; // Thêm tham số slug

  const MangaDetailScreen({Key? key, required this.mangaId, this.slug})
    : super(key: key);

  @override
  State<MangaDetailScreen> createState() => _MangaDetailScreenState();
}

class _MangaDetailScreenState extends State<MangaDetailScreen> {
  final SavedMangaService _savedService = SavedMangaService();
  final MangaApiService _apiService = MangaApiService();

  late Future<Manga> _mangaFuture;
  bool _isSaved = false;
  bool _loadingChapters = true;
  List<Chapter>? _chapters;

  @override
  void initState() {
    super.initState();
    _loadManga();
  }

  Future<void> _loadManga() async {
    try {
      // Nếu có slug, ưu tiên dùng slug
      if (widget.slug != null && widget.slug!.isNotEmpty) {
        _mangaFuture = _apiService.getMangaBySlug(widget.slug!);
      } else {
        // Nếu không có slug, dùng ID
        _mangaFuture = _apiService.getMangaById(widget.mangaId);
      }

      final manga = await _mangaFuture;
      setState(() {
        _isSaved = _savedService.isMangaSaved(manga.id);
      });

      // Tải danh sách chapters
      _loadChapters(manga.id);
    } catch (e) {
      print('Error in _loadManga: $e');
    }
  }

  Future<void> _loadChapters(String mangaId) async {
    setState(() {
      _loadingChapters = true;
    });

    try {
      final chapters = await _apiService.getChaptersList(mangaId);
      setState(() {
        _chapters = chapters;
        _loadingChapters = false;
      });
    } catch (e) {
      print('Error loading chapters: $e');
      setState(() {
        _chapters = [];
        _loadingChapters = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Manga>(
        future: _mangaFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${context.tr('error_loading_manga')}: ${snapshot.error}',
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _loadManga();
                      });
                    },
                    child: Text(context.tr('try_again')),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return Center(child: Text(context.tr('manga_not_found')));
          }

          final manga = snapshot.data!;
          final lastReadChapter = _savedService.getLastReadChapter(manga.id);
          final totalChapters = manga.getActualCurrentChapter();

          return CustomScrollView(
            slivers: [
              // App bar với ảnh bìa
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    manga.title,
                    style: const TextStyle(
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black, blurRadius: 3)],
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        manga.thumbUrl,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                Container(color: Colors.grey),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      _isSaved ? Icons.bookmark : Icons.bookmark_outline,
                    ),
                    onPressed: () {
                      setState(() {
                        if (_isSaved) {
                          _savedService.removeManga(manga.id);
                        } else {
                          _savedService.addManga(manga);
                        }
                        _isSaved = !_isSaved;
                      });

                      // Hiển thị thông báo
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _isSaved
                                ? '${context.tr('added_to_list')} ${manga.title}'
                                : '${context.tr('removed_from_list')} ${manga.title}',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),

              // Thông tin truyện
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        manga.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${context.tr('status')}: ${_getLocalizedStatus(context, manga.status)}',
                      ),
                      if (manga.authors.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          '${context.tr('genres')}: ${manga.authors.join(", ")}',
                        ),
                      ],
                      if (manga.categories.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children:
                              manga.categories.map((category) {
                                return Chip(
                                  label: Text(category['name'] ?? ''),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                );
                              }).toList(),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Text(
                        context.tr('description'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(manga.description),
                      const SizedBox(height: 16),

                      // Hiển thị tiến độ đọc nếu đã đọc
                      if (lastReadChapter > 0) ...[
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${context.tr('reading_progress')}: $lastReadChapter/$totalChapters',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: lastReadChapter / totalChapters,
                                    backgroundColor: Colors.grey[300],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Button đọc tiếp
                      if (lastReadChapter > 0 &&
                          lastReadChapter < totalChapters)
                        ElevatedButton.icon(
                          onPressed: () {
                            MangaNavigator.navigateToChapter(
                              context,
                              manga.id,
                              lastReadChapter + 1,
                            );
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: Text(
                            '${context.tr('continue_reading')} ${context.tr('chapter')} ${lastReadChapter + 1}',
                          ),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),

                      // Button đọc từ đầu
                      if (lastReadChapter == 0 ||
                          lastReadChapter == totalChapters)
                        ElevatedButton.icon(
                          onPressed: () {
                            MangaNavigator.navigateToChapter(
                              context,
                              manga.id,
                              lastReadChapter == totalChapters ? 1 : 1,
                            );
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: Text(
                            lastReadChapter == totalChapters
                                ? context.tr('read_from_beginning')
                                : context.tr('start_reading'),
                          ),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),

                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.tr('chapters_list'),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (_chapters != null && _chapters!.isNotEmpty)
                            OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _chapters = _chapters!.reversed.toList();
                                });
                              },
                              child: Text(context.tr('reverse_order')),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Danh sách chương
              _buildChaptersList(manga.id, lastReadChapter),
            ],
          );
        },
      ),
    );
  }

  String _getLocalizedStatus(BuildContext context, String status) {
    if (status.toLowerCase().contains('cập nhật')) {
      return context.tr('ongoing');
    } else if (status.toLowerCase().contains('hoàn thành')) {
      return context.tr('completed');
    }
    return status;
  }

  Widget _buildChaptersList(String mangaId, int lastReadChapter) {
    if (_loadingChapters) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_chapters == null || _chapters!.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text(context.tr('no_chapters')),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final chapter = _chapters![index];
        final isRead = chapter.number <= lastReadChapter;

        return ListTile(
          title: Text(
            '${context.tr('chapter')} ${chapter.number}${chapter.title.isNotEmpty ? ': ${chapter.title}' : ''}',
            style: TextStyle(color: isRead ? Colors.grey : null),
          ),
          leading: Icon(
            isRead ? Icons.check_circle : Icons.circle_outlined,
            color: isRead ? Colors.green : null,
          ),
          onTap: () {
            final apiUrl = chapter.apiUrl; // Lấy URL API từ chapter
            if (apiUrl != null && apiUrl.isNotEmpty) {
              MangaNavigator.navigateToChapterByUrl(
                context,
                mangaId,
                chapter.number,
                apiUrl,
              );
            } else {
              // Fallback nếu không có URL
              MangaNavigator.navigateToChapter(
                context,
                mangaId,
                chapter.number,
              );
            }
          },
        );
      }, childCount: _chapters!.length),
    );
  }
}
