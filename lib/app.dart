import 'package:flutter/material.dart';
import 'package:getting_started/presentation/screens/auth/login_screen.dart';
import 'package:getting_started/presentation/screens/home/home_screen.dart';
import 'package:getting_started/presentation/screens/manga/manga_detail_screen.dart';
import 'package:getting_started/presentation/screens/manga/chapter_view_screen.dart';
import 'package:getting_started/presentation/screens/user/saved.dart';
import 'package:getting_started/presentation/widgets/bottom_nav.dart';
import 'package:provider/provider.dart';

class ComicApp extends StatelessWidget {
  const ComicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OTruyen',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
      ),
      routes: {
        '/': (context) => NavigationBottomBar(),
        '/home': (context) => HomeScreen(),
        '/saved': (context) => SavedScreen(),
        '/login': (context) => LoginScreen(),
      },
      // Trong phương thức build
      onGenerateRoute: (settings) {
        // Xử lý các route động
        if (settings.name == '/manga-detail') {
          final args = settings.arguments;
          if (args is String) {
            // Nếu argument là String, có thể là ID hoặc slug
            if (args.startsWith('slug:')) {
              // Nếu là slug
              final slug = args.substring(5); // Loại bỏ 'slug:'
              return MaterialPageRoute(
                builder:
                    (context) => MangaDetailScreen(mangaId: '', slug: slug),
              );
            } else {
              // Nếu là ID
              return MaterialPageRoute(
                builder: (context) => MangaDetailScreen(mangaId: args),
              );
            }
          } else if (args is Map<String, dynamic>) {
            // Nếu argument là Map
            return MaterialPageRoute(
              builder:
                  (context) => MangaDetailScreen(
                    mangaId: args['mangaId'] ?? '',
                    slug: args['slug'],
                  ),
            );
          }
          // Default
          return MaterialPageRoute(
            builder: (context) => MangaDetailScreen(mangaId: ''),
          );
        } else if (settings.name == '/chapter-view') {
          final args = settings.arguments;
          if (args is Map<String, dynamic>) {
            return MaterialPageRoute(
              builder:
                  (context) => ChapterViewScreen(
                    mangaId: args['mangaId'] ?? '',
                    chapterNumber: args['chapterNumber'] ?? 1,
                    chapterUrl: args['chapterUrl'],
                  ),
            );
          }
          // Default
          return MaterialPageRoute(
            builder:
                (context) => ChapterViewScreen(mangaId: '', chapterNumber: 1),
          );
        }

        // Xử lý URL SEO-friendly
        final uri = Uri.parse(settings.name ?? '');
        if (uri.pathSegments.length == 2 &&
            uri.pathSegments[0] == 'truyen-tranh') {
          // Pattern: /truyen-tranh/{slug}
          final slug = uri.pathSegments[1];
          return MaterialPageRoute(
            builder: (context) => MangaDetailScreen(mangaId: '', slug: slug),
          );
        }

        return null;
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
