import 'package:go_router/go_router.dart';

import '../features/home/presentation/pages/home_page.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) {
          return const HomePage();
        },
      ),
    ],
  );
}