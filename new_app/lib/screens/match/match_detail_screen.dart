import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../providers/matches_provider.dart';
import '../../widgets/team_logo.dart';
import '../../widgets/odds_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';

/// Match Detail Screen with odds (+3 points)
class MatchDetailScreen extends StatefulWidget {
  final int matchId;

  const MatchDetailScreen({
    super.key,
    required this.matchId,
  });

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadMatchDetails();
  }

  Future<void> _loadMatchDetails() async {
    final provider = Provider.of<MatchesProvider>(context, listen: false);
    await provider.loadMatchDetails(widget.matchId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Матч'),
      ),
      body: Consumer<MatchesProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.selectedMatch == null) {
            return const LoadingWidget(message: 'Загрузка...');
          }

          if (provider.error != null && provider.selectedMatch == null) {
            return NetworkErrorWidget(
              message: provider.error,
              onRetry: _loadMatchDetails,
            );
          }

          final match = provider.selectedMatch;
          if (match == null) {
            return const EmptyStateWidget(
              title: 'Матч не найден',
              icon: Icons.sports_soccer_outlined,
            );
          }

          return RefreshIndicator(
            onRefresh: _loadMatchDetails,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Match header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Date and time
                        Text(
                          _formatDateTime(match.dateTime),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Status
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(match),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            match.statusText,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Teams and score
                        Row(
                          children: [
                            // Home team
                            Expanded(
                              child: Column(
                                children: [
                                  TeamLogo(
                                    logoUrl: match.homeTeam.logoUrl,
                                    size: 64,
                                    teamName: match.homeTeam.name,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    match.homeTeam.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            
                            // Score
                            Column(
                              children: [
                                if (match.isFinished || match.isLive)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        match.homeResult?.toString() ?? '0',
                                        style: const TextStyle(
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 12),
                                        child: Text(
                                          ':',
                                          style: TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        match.awayResult?.toString() ?? '0',
                                        style: const TextStyle(
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  Text(
                                    'VS',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white.withValues(alpha: 0.8),
                                    ),
                                  ),
                              ],
                            ),
                            
                            // Away team
                            Expanded(
                              child: Column(
                                children: [
                                  TeamLogo(
                                    logoUrl: match.awayTeam.logoUrl,
                                    size: 64,
                                    teamName: match.awayTeam.name,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    match.awayTeam.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Glicko ratings
                  if (provider.matchGlicko != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GlickoWidget(glicko: provider.matchGlicko),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Odds section (+3 points)
                  if (match.mainOdds != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: OddsWidget(odds: match.mainOdds),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Match info
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoSection(
                          title: 'Информация о матче',
                          children: [
                            if (match.roundName != null)
                              _buildInfoRow(
                                Icons.format_list_numbered,
                                'Тур',
                                match.roundName!,
                              ),
                            if (match.leagueName != null)
                              _buildInfoRow(
                                Icons.emoji_events_outlined,
                                'Лига',
                                match.leagueName!,
                              ),
                            if (match.countryName != null)
                              _buildInfoRow(
                                Icons.flag_outlined,
                                'Страна',
                                match.countryName!,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('d MMMM yyyy, HH:mm', 'ru').format(dateTime);
  }

  Color _getStatusColor(dynamic match) {
    if (match.isLive) {
      return AppTheme.liveMatchColor;
    } else if (match.isFinished) {
      return Colors.grey;
    }
    return AppTheme.upcomingMatchColor;
  }

  Widget _buildInfoSection({
    required String title,
    required List<Widget> children,
  }) {
    if (children.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textSecondary),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
