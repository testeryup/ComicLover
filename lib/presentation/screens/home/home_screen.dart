import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:getting_started/presentation/screens/manga/manga_detail_screen.dart';
import 'package:getting_started/core/services/reading_history_service.dart';
import 'package:getting_started/core/services/localization_service.dart';

// Move the getImageUrl method outside of any class to make it a top-level function
String getImageUrl(String thumbUrl) {
  // For debugging
  print('Original thumb_url: $thumbUrl');

  String imageUrl;
  if (thumbUrl.startsWith('http')) {
    // Already a full URL
    imageUrl = thumbUrl;
  } else if (thumbUrl.startsWith('/uploads/')) {
    // Path starts with /uploads/
    imageUrl = 'https://img.otruyenapi.com$thumbUrl';
    print('Constructed image URL: $imageUrl');
  } else {
    // Assume it's just a filename
    imageUrl = 'https://img.otruyenapi.com/uploads/comics/$thumbUrl';
    print('Constructed image URL: $imageUrl');
  }

  // For debugging
  print('Constructed image URL: $imageUrl');
  return imageUrl;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<dynamic> items = [];
  List<dynamic> searchResults = [];
  String searchQuery = '';
  bool isLoading = true;
  bool isSearching = false;
  bool isSearchLoading = false;
  TextEditingController searchController = TextEditingController();
  String selectedCategory = 'All';
  List<String> categories = ['All'];
  List<Map<String, dynamic>> readingHistory = [];
  final ReadingHistoryService _historyService = ReadingHistoryService();

  @override
  void initState() {
    super.initState();
    fetchData();
    _loadReadingHistory();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://otruyenapi.com/v1/api/home'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            items = data['data']['items'];
            isLoading = false;

            // Extract unique categories
            Set<String> uniqueCategories = {'All'};
            for (var item in items) {
              if (item['category'] != null) {
                for (var category in item['category']) {
                  uniqueCategories.add(category['name']);
                }
              }
            }
            categories = uniqueCategories.toList();

            // Pre-populate search results with all items
            searchResults = List.from(items);
          });
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    }
  }

  Future<void> _loadReadingHistory() async {
    final history = await _historyService.getReadingHistory();
    setState(() {
      readingHistory = history;
    });
  }

  void filterManga(String query) {
    if (query.isEmpty) {
      setState(() {
        searchResults = List.from(items);
        isSearchLoading = false;
      });
      return;
    }

    setState(() {
      isSearchLoading = true;
    });

    // Apply local filtering
    final filteredResults =
        items.where((manga) {
          return manga['name'].toString().toLowerCase().contains(
            query.toLowerCase(),
          );
        }).toList();

    setState(() {
      searchResults = filteredResults;
      isSearchLoading = false;
    });
  }

  List<dynamic> getFilteredItems() {
    if (searchQuery.isEmpty && selectedCategory == 'All') {
      return items;
    }

    return items.where((item) {
      bool matchesSearch =
          searchQuery.isEmpty ||
          item['name'].toString().toLowerCase().contains(
            searchQuery.toLowerCase(),
          );

      bool matchesCategory =
          selectedCategory == 'All' ||
          (item['category'] != null &&
              item['category'].any((cat) => cat['name'] == selectedCategory));

      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          // Enhanced light blue gradient background
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade100, Colors.blue.shade50, Colors.white],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Column(
          children: [
            // Add search bar at the top that's always visible
            Padding(
              padding: const EdgeInsets.only(
                top: 50.0,
                left: 16.0,
                right: 16.0,
                bottom: 8.0,
              ),
              child: _buildSearchBar(),
            ),
            // Main content area - takes all remaining space
            Expanded(
              child:
                  isSearching
                      ? _buildSearchResults()
                      : isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildMainContent(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        mini: true,
        child: const Icon(Icons.menu),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  Widget _buildSearchResults() {
    if (isSearchLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (searchResults.isEmpty) {
      return Center(child: Text(context.tr('no_result')));
    }

    // Simplified search results list that takes full height
    return ListView.builder(
      itemCount: searchResults.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final manga = searchResults[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            width: 50,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                getImageUrl(manga['thumb_url']),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.error));
                },
              ),
            ),
          ),
          title: Text(
            manga['name'],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            '${context.tr('chapter')} ${manga['chaptersLatest']?[0]?['chapter_name'] ?? context.tr('unknown')}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              manga['status'] == 'ongoing'
                  ? context.tr('ongoing')
                  : context.tr('completed'),
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          onTap: () {
            // Store necessary data before async operation
            final String mangaId = manga['_id'] ?? '';
            final String? slug = manga['slug'];

            // Use a separate method to handle the async operations
            _navigateToMangaDetail(manga, mangaId, slug);
          },
        );
      },
    );
  }

  // New method to handle async operations and navigation
  Future<void> _navigateToMangaDetail(
    dynamic manga,
    String mangaId,
    String? slug,
  ) async {
    await _historyService.addToHistory(manga);

    // Check if widget is still mounted before using context
    if (!mounted) return;

    _loadReadingHistory();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MangaDetailScreen(mangaId: mangaId, slug: slug),
      ),
    );
  }

  Widget _buildMainContent() {
    final filteredItems = getFilteredItems();

    return Stack(
      children: [
        SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                const SizedBox(height: 16),
                _buildCategoryFilter(),
                const SizedBox(height: 24),
                _buildTrendingManga(filteredItems),
                const SizedBox(height: 24),
                _buildTopReaders(),
                const SizedBox(height: 24),
                _buildContinueReading(),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage:
                      items.isNotEmpty
                          ? NetworkImage(getImageUrl(items[0]['thumb_url']))
                          : null,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('stay_trending'), // Thay vì 'Stay trending!'
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                Text(
                  context.tr('manga_reader'), // Thay vì 'Manga Reader'
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.grid_view_rounded),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          // Add back button when searching
          if (isSearching)
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.grey),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                setState(() {
                  isSearching = false;
                  searchQuery = '';
                  searchController.clear();
                });
              },
            ),
          if (!isSearching) const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: context.tr('search_manga'), // Thay vì 'Search manga'
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  isSearching = value.isNotEmpty;
                });
                // Apply local filtering instead of API call
                filterManga(value);
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.grey),
            onPressed: () {
              // Show filter options
              showModalBottomSheet(
                context: context,
                builder: (context) => _buildFilterOptions(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOptions() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('sort_by'), // Thay vì 'Sort by'
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: Text(context.tr('name_asc')), // Thay vì 'Name (A-Z)'
                selected: false,
                onSelected: (selected) {
                  setState(() {
                    items.sort((a, b) => a['name'].compareTo(b['name']));
                  });
                  Navigator.pop(context);
                },
              ),
              FilterChip(
                label: Text(context.tr('name_desc')), // Thay vì 'Name (Z-A)'
                selected: false,
                onSelected: (selected) {
                  setState(() {
                    items.sort((a, b) => b['name'].compareTo(a['name']));
                  });
                  Navigator.pop(context);
                },
              ),
              FilterChip(
                label: Text(
                  context.tr('latest_update'),
                ), // Thay vì 'Latest Update'
                selected: false,
                onSelected: (selected) {
                  setState(() {
                    items.sort(
                      (a, b) => b['updatedAt'].compareTo(a['updatedAt']),
                    );
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedCategory = category;
                });
              },
              backgroundColor: Colors.grey[200],
              selectedColor: Colors.blue,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrendingManga(List<dynamic> filteredItems) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.tr('trending_manga'), // Thay vì 'Trending Manga'
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child:
              filteredItems.isEmpty
                  ? Center(
                    child: Text(context.tr('no_manga_found')),
                  ) // Thay vì 'No manga found'
                  : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: filteredItems.length,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return GestureDetector(
                        onTap: () {
                          // Extract data before async operation
                          final String mangaId = item['_id'] ?? '';
                          final String? slug = item['slug'];
                          _navigateToMangaDetail(item, mangaId, slug);
                        },
                        child: Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  getImageUrl(item['thumb_url']),
                                  width: 120,
                                  height: 150,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 120,
                                      height: 150,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.error),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: 120,
                                child: Text(
                                  item['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '${context.tr('from_category')} ${item['category']?[0]?['name'] ?? context.tr('unknown')}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildTopReaders() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('top_readers'), // Thay vì 'Top Readers'
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: items.length > 5 ? 5 : items.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                          getImageUrl(items[index]['thumb_url']),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        items[index]['slug'].toString().substring(0, 8),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueReading() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('continue_reading'), // Thay vì 'Continue Reading'
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (readingHistory.isNotEmpty)
                TextButton(
                  onPressed: () async {
                    await _historyService.clearHistory();
                    if (mounted) {
                      _loadReadingHistory();
                    }
                  },
                  child: Text(
                    context.tr('clear'), // Thay vì 'Clear'
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (readingHistory.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  context.tr(
                    'no_reading_history',
                  ), // Thay vì 'No reading history yet'
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            Column(
              children:
                  readingHistory.map((manga) {
                    return GestureDetector(
                      onTap: () {
                        // Extract data before async operation
                        final String mangaId = manga['_id'] ?? '';
                        final String? slug = manga['slug'];
                        _navigateToMangaDetail(manga, mangaId, slug);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(
                                getImageUrl(manga['thumb_url']),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    manga['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'Chapter ${manga['chaptersLatest']?[0]?['chapter_name'] ?? 'Unknown'}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.play_arrow, size: 30),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),
        ],
      ),
    );
  }
}
