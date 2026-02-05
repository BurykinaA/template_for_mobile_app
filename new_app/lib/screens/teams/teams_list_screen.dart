import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/routes.dart';
import '../../models/league.dart';
import '../../providers/leagues_provider.dart';
import '../../providers/teams_provider.dart';
import '../../widgets/team_logo.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';

/// Teams List Screen with league filter (+3 points)
class TeamsListScreen extends StatefulWidget {
  const TeamsListScreen({super.key});

  @override
  State<TeamsListScreen> createState() => _TeamsListScreenState();
}

class _TeamsListScreenState extends State<TeamsListScreen> {
  League? _selectedLeague;

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
    
    // Auto-select first league
    if (mounted && provider.leagues.isNotEmpty && _selectedLeague == null) {
      await _selectLeague(provider.leagues.first);
    }
  }

  Future<void> _selectLeague(League league) async {
    if (!mounted) return;
    setState(() {
      _selectedLeague = league;
    });
    
    if (league.currentSeason != null) {
      await _loadTeams();
    }
  }

  Future<void> _loadTeams() async {
    if (_selectedLeague == null || _selectedLeague!.currentSeason == null) return;
    
    final teamsProvider = Provider.of<TeamsProvider>(context, listen: false);
    await teamsProvider.loadTeamsByLeague(
      _selectedLeague!.id, 
      _selectedLeague!.currentSeason!.year,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Команды'),
      ),
      body: Column(
        children: [
          // League filter
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
            child: Consumer<LeaguesProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.leagues.isEmpty) {
                  return const LinearProgressIndicator();
                }

                return DropdownButtonFormField<League>(
                  value: _selectedLeague,
                  decoration: const InputDecoration(
                    labelText: 'Выберите лигу',
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
                  onChanged: (league) {
                    if (league != null) {
                      _selectLeague(league);
                    }
                  },
                );
              },
            ),
          ),

          // Teams list / Standings
          Expanded(
            child: Consumer<TeamsProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const LoadingWidget(message: 'Загрузка команд...');
                }

                if (provider.error != null && provider.teams.isEmpty) {
                  return NetworkErrorWidget(
                    message: provider.error,
                    onRetry: _loadTeams,
                  );
                }

                if (provider.teams.isEmpty) {
                  return const EmptyStateWidget(
                    title: 'Команды не найдены',
                    subtitle: 'Выберите лигу для просмотра команд',
                    icon: Icons.groups_outlined,
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadTeams,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: provider.standings.length,
                    itemBuilder: (context, index) {
                      final standing = provider.standings[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Container(
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _getRankColor(standing.rank),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${standing.rank}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          title: Text(
                            standing.teamName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            '${standing.wins}В ${standing.draws}Н ${standing.loss}П  '
                            'Голы: ${standing.goalsScored}:${standing.goalsMissed}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${standing.points}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              AppRoutes.teamDetail,
                              arguments: {
                                'teamId': standing.teamId,
                                'teamName': standing.teamName,
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    if (rank <= 4) return Colors.green;
    if (rank <= 6) return Colors.blue;
    if (rank >= 18) return Colors.red;
    return Colors.grey;
  }
}
