import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/routes.dart';
import '../../models/league.dart';
import '../../models/team.dart';
import '../../providers/leagues_provider.dart';
import '../../providers/matches_provider.dart';
import '../../providers/teams_provider.dart';
import '../../widgets/match_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';

/// Time period filter enum
enum TimePeriod {
  day,
  week,
  month,
}

extension TimePeriodExtension on TimePeriod {
  String get label {
    switch (this) {
      case TimePeriod.day:
        return 'День';
      case TimePeriod.week:
        return 'Неделя';
      case TimePeriod.month:
        return 'Месяц';
    }
  }

  int get days {
    switch (this) {
      case TimePeriod.day:
        return 1;
      case TimePeriod.week:
        return 7;
      case TimePeriod.month:
        return 30;
    }
  }
}

/// Search Screen with filters
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  League? _selectedLeague;
  Team? _selectedTeam;
  TimePeriod _selectedPeriod = TimePeriod.week;
  List<Team> _availableTeams = [];
  bool _loadingTeams = false;

  @override
  void initState() {
    super.initState();
    // Defer loading to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLeagues();
    });
  }

  Future<void> _loadLeagues() async {
    final provider = Provider.of<LeaguesProvider>(context, listen: false);
    await provider.loadLeagues();
  }

  Future<void> _loadTeamsForLeague(int leagueId, int year) async {
    if (!mounted) return;
    setState(() => _loadingTeams = true);
    
    try {
      final teamsProvider = Provider.of<TeamsProvider>(context, listen: false);
      await teamsProvider.loadTeamsByLeague(leagueId, year);
      if (!mounted) return;
      setState(() {
        _availableTeams = teamsProvider.teams;
      });
    } catch (_) {
      // Ignore errors
    } finally {
      if (mounted) {
        setState(() => _loadingTeams = false);
      }
    }
  }

  Future<void> _search() async {
    if (_selectedLeague == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите лигу')),
      );
      return;
    }

    final now = DateTime.now();
    final toDate = now.add(Duration(days: _selectedPeriod.days));

    final matchesProvider = Provider.of<MatchesProvider>(context, listen: false);
    await matchesProvider.searchMatches(
      leagueId: _selectedLeague!.id,
      fromDate: now,
      toDate: toDate,
      teamId: _selectedTeam?.id,
    );
  }

  void _goToArchive() {
    if (_selectedLeague == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите лигу')),
      );
      return;
    }

    Navigator.of(context).pushNamed(
      AppRoutes.archive,
      arguments: {
        'leagueId': _selectedLeague?.id,
        'seasonYear': _selectedLeague?.currentSeason?.year,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Поиск матчей'),
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // League filter
                Consumer<LeaguesProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const LinearProgressIndicator();
                    }

                    return DropdownButtonFormField<League>(
                      value: _selectedLeague,
                      decoration: const InputDecoration(
                        labelText: 'Лига',
                        prefixIcon: Icon(Icons.emoji_events_outlined),
                      ),
                      items: provider.leagues.map((league) {
                        return DropdownMenuItem(
                          value: league,
                          child: Text(
                            league.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (league) async {
                        setState(() {
                          _selectedLeague = league;
                          _selectedTeam = null;
                          _availableTeams = [];
                        });

                        if (league != null && league.currentSeason != null) {
                          await _loadTeamsForLeague(league.id, league.currentSeason!.year);
                        }
                      },
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Time period filter
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 20, color: AppTheme.textSecondary),
                    const SizedBox(width: 8),
                    const Text('Период:', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SegmentedButton<TimePeriod>(
                        segments: TimePeriod.values.map((period) {
                          return ButtonSegment(
                            value: period,
                            label: Text(period.label),
                          );
                        }).toList(),
                        selected: {_selectedPeriod},
                        onSelectionChanged: (selection) {
                          setState(() {
                            _selectedPeriod = selection.first;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Team filter (+2 points)
                if (_availableTeams.isNotEmpty || _loadingTeams)
                  _loadingTeams
                      ? const LinearProgressIndicator()
                      : DropdownButtonFormField<Team?>(
                          value: _selectedTeam,
                          decoration: const InputDecoration(
                            labelText: 'Команда (необязательно)',
                            prefixIcon: Icon(Icons.groups_outlined),
                          ),
                          items: [
                            const DropdownMenuItem<Team?>(
                              value: null,
                              child: Text('Все команды'),
                            ),
                            ..._availableTeams.map((team) {
                              return DropdownMenuItem<Team?>(
                                value: team,
                                child: Text(
                                  team.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }),
                          ],
                          onChanged: (team) {
                            setState(() {
                              _selectedTeam = team;
                            });
                          },
                        ),

                const SizedBox(height: 16),

                // Buttons row
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _search,
                        icon: const Icon(Icons.search),
                        label: const Text('Найти'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: _goToArchive,
                      icon: const Icon(Icons.history),
                      label: const Text('Архив'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Results
          Expanded(
            child: Consumer<MatchesProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const LoadingWidget(message: 'Поиск матчей...');
                }

                if (provider.error != null && provider.searchResults.isEmpty) {
                  return NetworkErrorWidget(
                    message: provider.error,
                    onRetry: _search,
                  );
                }

                if (provider.searchResults.isEmpty) {
                  return const EmptyStateWidget(
                    title: 'Матчи не найдены',
                    subtitle: 'Выберите фильтры и нажмите "Найти"',
                    icon: Icons.search_off,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: provider.searchResults.length,
                  itemBuilder: (context, index) {
                    final match = provider.searchResults[index];
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
