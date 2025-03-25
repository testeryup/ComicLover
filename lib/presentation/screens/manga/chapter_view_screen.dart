import 'package:flutter/material.dart';
import 'package:getting_started/core/services/manga_api_service.dart';
import 'package:getting_started/core/services/saved_manga.dart';
import 'package:getting_started/data/models/chapter.dart';
import 'package:getting_started/core/services/localization_service.dart'; // Thêm import
import 'dart:math' as math;

class ChapterViewScreen extends StatefulWidget {
  final String mangaId;
  final int chapterNumber;
  final String? chapterUrl;

  const ChapterViewScreen({
    Key? key,
    required this.mangaId,
    required this.chapterNumber,
    this.chapterUrl,
  }) : super(key: key);

  @override
  State<ChapterViewScreen> createState() => _ChapterViewScreenState();
}

class _ChapterViewScreenState extends State<ChapterViewScreen> {
  final MangaApiService _apiService = MangaApiService();
  final SavedMangaService _savedService = SavedMangaService();

  late Future<List<String>> _imagesFuture;
  bool _isLoading = true;
  int _totalChapters = 0;
  final ScrollController _scrollController = ScrollController();
  late List<Chapter> _chapters;

  List<String> _visibleImages = [];
  List<String> _allImages = [];
  int _loadBatchSize = 10;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadChapterData();

    // Thêm listener cho scroll controller
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent - 1000) {
        _loadMoreImages();
      }
    });

    // Cập nhật trạng thái đọc
    _savedService.updateLastReadChapter(widget.mangaId, widget.chapterNumber);
  }

  Future<void> _loadChapterData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Lấy danh sách chapters để biết tổng số chapter
      _chapters = await _apiService.getChaptersList(widget.mangaId);
      setState(() {
        _totalChapters = _chapters.length;
      });

      // Tìm chapterUrl nếu không được truyền vào
      String? chapterUrlToUse = widget.chapterUrl;
      if (chapterUrlToUse == null) {
        // Tìm chapter trong danh sách chapters
        for (var chapter in _chapters) {
          if (chapter.number == widget.chapterNumber) {
            chapterUrlToUse = chapter.apiUrl;
            break;
          }
        }
      }

      // Lấy hình ảnh của chapter
      if (chapterUrlToUse != null) {
        _imagesFuture = _apiService.getChapterImages(chapterUrlToUse);
      } else {
        throw Exception(
          '${context.tr('error_loading_chapter')} ${widget.chapterNumber}',
        );
      }
    } catch (e) {
      print('${context.tr('error_loading_chapter')}: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToChapter(int chapterNumber) {
    if (chapterNumber < 1 || chapterNumber > _totalChapters) return;

    // Tìm chapterUrl cho chapter mới
    String? chapterUrl;
    for (var chapter in _chapters) {
      if (chapter.number == chapterNumber) {
        chapterUrl = chapter.apiUrl;
        break;
      }
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) => ChapterViewScreen(
              mangaId: widget.mangaId,
              chapterNumber: chapterNumber,
              chapterUrl: chapterUrl,
            ),
      ),
    );

    // Cập nhật trạng thái đọc
    _savedService.updateLastReadChapter(widget.mangaId, chapterNumber);
  }

  void _loadMoreImages() {
    if (_isLoadingMore || _visibleImages.length >= _allImages.length) return;

    setState(() {
      _isLoadingMore = true;
      final end = math.min(
        _visibleImages.length + _loadBatchSize,
        _allImages.length,
      );
      _visibleImages.addAll(_allImages.sublist(_visibleImages.length, end));
      _isLoadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${context.tr('chapter')} ${widget.chapterNumber}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              // Quay lại màn hình chi tiết truyện
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : FutureBuilder<List<String>>(
                future: _imagesFuture,
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
                            '${context.tr('error_loading_chapter')}: ${snapshot.error}',
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadChapterData,
                            child: Text(context.tr('try_again')),
                          ),
                        ],
                      ),
                    );
                  }

                  final images = snapshot.data!;
                  if (images.isEmpty) {
                    return Center(child: Text(context.tr('no_images')));
                  }

                  // Khởi tạo dữ liệu hình ảnh
                  if (_allImages.isEmpty) {
                    _allImages = images;
                    _visibleImages = images.take(_loadBatchSize).toList();
                  }

                  return Column(
                    children: [
                      // Navigation buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed:
                                  widget.chapterNumber > 1
                                      ? () => _navigateToChapter(
                                        widget.chapterNumber - 1,
                                      )
                                      : null,
                              child: Text(context.tr('previous_chapter')),
                            ),
                            Text(
                              '${context.tr('chapter')} ${widget.chapterNumber}/$_totalChapters',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ElevatedButton(
                              onPressed:
                                  widget.chapterNumber < _totalChapters
                                      ? () => _navigateToChapter(
                                        widget.chapterNumber + 1,
                                      )
                                      : null,
                              child: Text(context.tr('next_chapter')),
                            ),
                          ],
                        ),
                      ),

                      // Chapter images
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: _visibleImages.length,
                          itemBuilder: (context, index) {
                            return Image.network(
                              _visibleImages[index],
                              headers: {
                                'User-Agent':
                                    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36',
                                'Referer': 'https://otruyen.cc/',
                              },
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return SizedBox(
                                  height: 300,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 300,
                                  color: Colors.grey[300],
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.error, size: 50),
                                        const SizedBox(height: 10),
                                        Text(context.tr('cannot_load_image')),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),

                      // Bottom navigation buttons
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed:
                                  widget.chapterNumber > 1
                                      ? () => _navigateToChapter(
                                        widget.chapterNumber - 1,
                                      )
                                      : null,
                              child: Text(context.tr('previous_chapter')),
                            ),
                            ElevatedButton(
                              onPressed:
                                  widget.chapterNumber < _totalChapters
                                      ? () => _navigateToChapter(
                                        widget.chapterNumber + 1,
                                      )
                                      : null,
                              child: Text(context.tr('next_chapter')),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
    );
  }
}
