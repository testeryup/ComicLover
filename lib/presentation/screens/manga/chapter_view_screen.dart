import 'package:flutter/material.dart';
import 'package:getting_started/core/services/manga_api_service.dart';
import 'package:getting_started/core/services/saved_manga.dart';

class ChapterViewScreen extends StatefulWidget {
  final String mangaId;
  final int chapterNumber;
  final String?
  chapterUrl; // Thêm tham số chapterUrl cho trường hợp có sẵn URL API

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

  @override
  void initState() {
    super.initState();
    _loadChapterData();

    // Cập nhật trạng thái đọc
    _savedService.updateLastReadChapter(widget.mangaId, widget.chapterNumber);
  }

  Future<void> _loadChapterData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Lấy danh sách chapters để biết tổng số chapter
      final chapters = await _apiService.getChaptersList(widget.mangaId);
      setState(() {
        _totalChapters = chapters.length;
      });

      // Lấy hình ảnh của chapter
      if (widget.chapterUrl != null) {
        _imagesFuture = _apiService.getChapterImages(widget.chapterUrl!);
      } else {
        _imagesFuture = _apiService.getChapterImagesByMangaIdAndChapterNumber(
          widget.mangaId,
          widget.chapterNumber,
        );
      }
    } catch (e) {
      print('Lỗi khi tải dữ liệu chapter: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToChapter(int chapterNumber) {
    if (chapterNumber < 1 || chapterNumber > _totalChapters) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) => ChapterViewScreen(
              mangaId: widget.mangaId,
              chapterNumber: chapterNumber,
            ),
      ),
    );

    // Cập nhật trạng thái đọc
    _savedService.updateLastReadChapter(widget.mangaId, chapterNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chương ${widget.chapterNumber}'),
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
                          Text('Lỗi: ${snapshot.error}'),
                          ElevatedButton(
                            onPressed: _loadChapterData,
                            child: Text('Thử lại'),
                          ),
                        ],
                      ),
                    );
                  }

                  final images = snapshot.data!;
                  if (images.isEmpty) {
                    return const Center(child: Text('Không có hình ảnh nào'));
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
                              child: const Text('Chương trước'),
                            ),
                            Text(
                              'Chương ${widget.chapterNumber}/$_totalChapters',
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
                              child: const Text('Chương sau'),
                            ),
                          ],
                        ),
                      ),

                      // Chapter images
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: images.length,
                          itemBuilder: (context, index) {
                            return Image.network(
                              images[index],
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
                                  child: const Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.error, size: 50),
                                        SizedBox(height: 10),
                                        Text('Không thể tải hình ảnh'),
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
                              child: const Text('Chương trước'),
                            ),
                            ElevatedButton(
                              onPressed:
                                  widget.chapterNumber < _totalChapters
                                      ? () => _navigateToChapter(
                                        widget.chapterNumber + 1,
                                      )
                                      : null,
                              child: const Text('Chương sau'),
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
