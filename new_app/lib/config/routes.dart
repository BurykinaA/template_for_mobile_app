import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/search/archive_screen.dart';
import '../screens/match/match_detail_screen.dart';
import '../screens/teams/teams_list_screen.dart';
import '../screens/teams/team_detail_screen.dart';
import '../screens/main_navigation_screen.dart';

/// App Routes Configuration
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  static const String home = '/home';
  static const String search = '/search';
  static const String archive = '/archive';
  static const String matchDetail = '/match';
  static const String teamsList = '/teams';
  static const String teamDetail = '/team';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case main:
        return MaterialPageRoute(builder: (_) => const MainNavigationScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case search:
        return MaterialPageRoute(builder: (_) => const SearchScreen());
      case archive:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ArchiveScreen(
            leagueId: args?['leagueId'] as int?,
            seasonYear: args?['seasonYear'] as int?,
          ),
        );
      case matchDetail:
        final matchId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => MatchDetailScreen(matchId: matchId),
        );
      case teamsList:
        return MaterialPageRoute(builder: (_) => const TeamsListScreen());
      case teamDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => TeamDetailScreen(
            teamId: args['teamId'] as int,
            teamName: args['teamName'] as String?,
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route not found: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
