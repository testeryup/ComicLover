import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  } else {
    // Assume it's just a filename
    imageUrl = 'https://img.otruyenapi.com/uploads/comics/$thumbUrl';
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

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      final response = await http.get(Uri.parse('https://otruyenapi.com/v1/api/home'));
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
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
    final filteredResults = items.where((manga) {
      return manga['name'].toString().toLowerCase().contains(query.toLowerCase());
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
      bool matchesSearch = searchQuery.isEmpty || 
          item['name'].toString().toLowerCase().contains(searchQuery.toLowerCase());
      
      bool matchesCategory = selectedCategory == 'All' || 
          (item['category'] != null && 
           item['category'].any((cat) => cat['name'] == selectedCategory));
      
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.purple[100],
              child: const Text('3', style: TextStyle(color: Colors.blue)),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Stay trending!', style: TextStyle(fontSize: 12)),
                const Text('Manga Reader', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.grid_view),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search manga...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.tune),
                  onPressed: () {},
                ),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  isSearching = value.isNotEmpty;
                });
                if (value.isNotEmpty) {
                  filterManga(value);
                } else {
                  setState(() {
                    searchResults = List.from(items);
                  });
                }
              },
            ),
          ),
          
          // Main content area - takes all remaining space
          Expanded(
            child: isSearching
                ? _buildSearchResults()
                : isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildMainContent(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Bookmark',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.blue,
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
      return const Center(child: Text('No results found'));
    }
    
    // Simplified search results list that takes full height
    return ListView.builder(
      itemCount: searchResults.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final manga = searchResults[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 50,
            height: 50,
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
            'Latest: Chapter ${manga['chaptersLatest']?[0]?['chapter_name'] ?? 'Unknown'}',
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              manga['status'] == 'ongoing' ? 'Ongoing' : 'Completed',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MangaDetailScreen(manga: manga),
              ),
            );
          },
        );
      },
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
                _buildSearchBar(),
                const SizedBox(height: 16),
                _buildCategoryFilter(),
                const SizedBox(height: 24),
                if (!isSearching) ...[
                  _buildTrendingManga(filteredItems),
                  const SizedBox(height: 24),
                  _buildTopReaders(),
                  const SizedBox(height: 24),
                  _buildContinueReading(),
                  const SizedBox(height: 50),
                ],
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
                  backgroundImage: items.isNotEmpty 
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
                const Text(
                  'Stay trending!',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const Text(
                  'Manga Reader',
                  style: TextStyle(
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
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Search manga',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15),
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
          const Text(
            'Sort by',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('Name (A-Z)'),
                selected: false,
                onSelected: (selected) {
                  setState(() {
                    items.sort((a, b) => a['name'].compareTo(b['name']));
                  });
                  Navigator.pop(context);
                },
              ),
              FilterChip(
                label: const Text('Name (Z-A)'),
                selected: false,
                onSelected: (selected) {
                  setState(() {
                    items.sort((a, b) => b['name'].compareTo(a['name']));
                  });
                  Navigator.pop(context);
                },
              ),
              FilterChip(
                label: const Text('Latest Update'),
                selected: false,
                onSelected: (selected) {
                  setState(() {
                    items.sort((a, b) => b['updatedAt'].compareTo(a['updatedAt']));
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
            const Text(
              'Trending Manga',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: filteredItems.isEmpty
              ? const Center(child: Text('No manga found'))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
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
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            'From ${item['category']?[0]?['name'] ?? 'Unknown'}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
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
              const Text(
                'Top Readers',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz),
                onPressed: () {},
              ),
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
                        backgroundImage: NetworkImage(getImageUrl(items[index]['thumb_url'])),
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
          const Text(
            'Continue Reading',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          if (items.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(getImageUrl(items[0]['thumb_url'])),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          items[0]['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Chapter ${items[0]['chaptersLatest']?[0]?['chapter_name'] ?? 'Unknown'}',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.play_arrow, size: 30),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// Add this new screen for manga details
class MangaDetailScreen extends StatefulWidget {
  final dynamic manga;
  
  const MangaDetailScreen({Key? key, required this.manga}) : super(key: key);
  
  @override
  State<MangaDetailScreen> createState() => _MangaDetailScreenState();
}

class _MangaDetailScreenState extends State<MangaDetailScreen> {
  List<dynamic> chapters = [];
  bool isLoading = true;
  
  @override
  void initState() {
    super.initState();
    // Extract chapters from the manga data
    if (widget.manga['chapters'] != null && 
        widget.manga['chapters'].isNotEmpty && 
        widget.manga['chapters'][0]['server_data'] != null) {
      chapters = widget.manga['chapters'][0]['server_data'];
    }
    isLoading = false;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.manga['name']),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {},
          ),
        ],
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Manga cover and info
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cover image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            getImageUrl(widget.manga['thumb_url']),
                            width: 120,
                            height: 180,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 120,
                                height: 180,
                                color: Colors.grey[300],
                                child: const Icon(Icons.error),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Manga details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.manga['name'],
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Status: ${widget.manga['status'] == 'ongoing' ? 'Ongoing' : 'Completed'}',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Author: ${widget.manga['author']?.join(', ') ?? 'Unknown'}',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Categories
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: (widget.manga['category'] as List?)?.map<Widget>((category) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[100],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      category['name'],
                                      style: TextStyle(
                                        color: Colors.blue[800],
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                                }).toList() ?? [],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Chapter list
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Chapters',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Chapter list
                        chapters.isEmpty
                            ? const Center(child: Text('No chapters available'))
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: chapters.length,
                                itemBuilder: (context, index) {
                                  final chapter = chapters[index];
                                  return ListTile(
                                    title: Text(
                                      'Chapter ${chapter['chapter_name']}${chapter['chapter_title'].isNotEmpty ? ': ${chapter['chapter_title']}' : ''}',
                                    ),
                                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                    onTap: () {
                                      // Navigate to chapter reader
                                      print('Opening chapter: ${chapter['chapter_api_data']}');
                                    },
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
