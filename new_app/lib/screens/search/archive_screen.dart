import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/routes.dart';
import '../../providers/matches_provider.dart';
import '../../widgets/match_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';

/// Archive Screen - shows finished matches
class ArchiveScreen extends StatefulWidget {
  final int? leagueId;
  final int? seasonYear;

  const ArchiveScreen({
    super.key,
    this.leagueId,
    this.seasonYear,
  });

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  @override
  void initState() {
    super.initState();
    _loadArchive();
  }

  Future<void> _loadArchive() async {
    if (widget.leagueId == null) return;
    
    final provider = Provider.of<MatchesProvider>(context, listen: false);
    await provider.loadArchivedMatches(
      widget.leagueId!,
      seasonYear: widget.seasonYear,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Архив матчей'),
      ),
      body: widget.leagueId == null
          ? const EmptyStateWidget(
              title: 'Лига не выбрана',
              subtitle: 'Вернитесь на экран поиска и выберите лигу',
              icon: Icons.info_outline,
            )
          : Consumer<MatchesProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const LoadingWidget(message: 'Загрузка архива...');
                }

                if (provider.error != null && provider.archivedMatches.isEmpty) {
                  return NetworkErrorWidget(
                    message: provider.error,
                    onRetry: _loadArchive,
                  );
                }

                if (provider.archivedMatches.isEmpty) {
                  return const EmptyStateWidget(
                    title: 'Нет завершенных матчей',
                    subtitle: 'В этой лиге пока нет завершенных матчей',
                    icon: Icons.history,
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadArchive,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: provider.archivedMatches.length,
                    itemBuilder: (context, index) {
                      final match = provider.archivedMatches[index];
                      return MatchCard(
                        match: match,
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            AppRoutes.matchDetail,
                            arguments: match.id,
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
