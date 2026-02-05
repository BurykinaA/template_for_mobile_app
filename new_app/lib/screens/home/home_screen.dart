import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../config/routes.dart';
import '../../providers/matches_provider.dart';
import '../../widgets/match_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/cached_data_banner.dart';

/// Home Screen - displays matches for the next 2 days
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Defer loading to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMatches();
    });
  }

  Future<void> _loadMatches() async {
    if (!mounted) return;
    final provider = Provider.of<MatchesProvider>(context, listen: false);
    await provider.loadUpcomingMatches();
  }
  
  String _getDateRangeText() {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final format = DateFormat('d MMM', 'ru');
    return '${format.format(now)} - ${format.format(tomorrow)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Матчи'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMatches,
          ),
        ],
      ),
      body: Consumer<MatchesProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.upcomingMatches.isEmpty) {
            return const LoadingWidget(message: 'Загрузка матчей...');
          }

          if (provider.error != null && provider.upcomingMatches.isEmpty && !provider.isFromCache) {
            return NetworkErrorWidget(
              message: provider.error,
              onRetry: _loadMatches,
            );
          }

          if (provider.upcomingMatches.isEmpty) {
            return EmptyStateWidget(
              title: 'Нет матчей',
              subtitle: 'На ближайшие 2 дня (${_getDateRangeText()}) матчей не найдено',
              icon: Icons.sports_soccer_outlined,
            );
          }

          return RefreshIndicator(
            onRefresh: _loadMatches,
            color: AppTheme.primaryColor,
            child: Column(
              children: [
                // Cache banner
                if (provider.isFromCache)
                  CachedDataBanner(onRefresh: _loadMatches),
                
                // Header with date range
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 20,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Матчи на ближайшие 2 дня',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const SizedBox(width: 28),
                          Text(
                            _getDateRangeText(),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${provider.upcomingMatches.length} матчей',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Matches list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: provider.upcomingMatches.length,
                    itemBuilder: (context, index) {
                      final match = provider.upcomingMatches[index];
                      return MatchCard(
                        match: match,
                        showLeague: true,
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            AppRoutes.matchDetail,
                            arguments: match.id,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
