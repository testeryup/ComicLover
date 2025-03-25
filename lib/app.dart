import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:getting_started/core/services/localization_service.dart';
import 'package:getting_started/presentation/screens/user/authors.dart';
import 'package:provider/provider.dart';
import 'package:getting_started/core/services/auth_service.dart';
import 'package:getting_started/presentation/screens/auth/login_screen.dart';
import 'package:getting_started/presentation/screens/auth/register_screen.dart';
import 'package:getting_started/presentation/screens/splash/splash_screen.dart';
import 'package:getting_started/presentation/screens/home/home_screen.dart';
import 'package:getting_started/presentation/screens/manga/manga_detail_screen.dart';
import 'package:getting_started/presentation/screens/manga/chapter_view_screen.dart';
import 'package:getting_started/presentation/screens/user/saved.dart';
import 'package:getting_started/presentation/screens/user/user_screen.dart';
import 'package:getting_started/presentation/widgets/bottom_nav.dart';

class ComicApp extends StatelessWidget {
  const ComicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => LocalizationService()),
      ],
      child: Consumer<LocalizationService>(
        builder: (context, localizationService, child) {
          return MaterialApp(
            title: 'ComicLover',
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
            ),
            locale: localizationService.currentLocale,
            supportedLocales: LocalizationService.supportedLocales,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            initialRoute: '/splash',
            routes: {
              '/': (context) => const NavigationApp(),
              '/home': (context) => const HomeScreen(),
              '/splash': (context) => const SplashScreen(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/saved': (context) => const SavedScreen(),
              '/profile': (context) => const UserScreen(),
              '/authors': (context) => const Authors(),
            },
            onGenerateRoute: (settings) {
              print(
                "Đang xử lý route: ${settings.name} với arguments: ${settings.arguments}",
              );

              if (settings.name == '/manga-detail') {
                final args = settings.arguments;
                if (args is String) {
                  return MaterialPageRoute(
                    builder: (context) => MangaDetailScreen(mangaId: args),
                  );
                } else if (args is Map<String, dynamic>) {
                  return MaterialPageRoute(
                    builder:
                        (context) => MangaDetailScreen(
                          mangaId: args['mangaId'] ?? '',
                          slug: args['slug'],
                        ),
                  );
                }
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
              }
              return null;
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
