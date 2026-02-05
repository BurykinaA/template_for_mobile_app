import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/match.dart';
import '../config/app_theme.dart';
import 'team_logo.dart';
import 'odds_widget.dart';

/// Match card widget
class MatchCard extends StatelessWidget {
  final Match match;
  final VoidCallback? onTap;
  final bool showOdds;
  final bool showLeague;

  const MatchCard({
    super.key,
    required this.match,
    this.onTap,
    this.showOdds = false,
    this.showLeague = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Date/Time and Status
              _buildHeader(),
              
              const SizedBox(height: 12),
              
              // Teams
              _buildTeams(),
              
              // League info
              if (showLeague && match.leagueName != null) ...[
                const SizedBox(height: 12),
                _buildLeagueInfo(),
              ],
              
              // Odds
              if (showOdds && match.mainOdds != null) ...[
                const SizedBox(height: 12),
                OddsWidget(odds: match.mainOdds, compact: true),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Date and time
        Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 14,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              _formatDate(),
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.access_time,
              size: 14,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              match.time,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        // Status badge
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildStatusBadge() {
    Color bgColor;
    Color textColor;
    String text = match.statusText;

    if (match.isLive) {
      bgColor = AppTheme.liveMatchColor;
      textColor = Colors.white;
    } else if (match.isFinished) {
      bgColor = Colors.grey[200]!;
      textColor = Colors.grey[700]!;
      text = 'Завершен';
    } else if (match.isUpcoming) {
      bgColor = AppTheme.upcomingMatchColor.withValues(alpha: 0.1);
      textColor = AppTheme.upcomingMatchColor;
      text = 'Предстоит';
    } else {
      bgColor = Colors.grey[200]!;
      textColor = Colors.grey[600]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (match.isLive) ...[
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeams() {
    return Column(
      children: [
        _buildTeamRow(
          match.homeTeam.name,
          match.homeTeam.logoUrl,
          match.isFinished || match.isLive ? match.homeResult?.toString() : null,
          isHome: true,
        ),
        const SizedBox(height: 8),
        _buildTeamRow(
          match.awayTeam.name,
          match.awayTeam.logoUrl,
          match.isFinished || match.isLive ? match.awayResult?.toString() : null,
          isHome: false,
        ),
      ],
    );
  }

  Widget _buildTeamRow(String name, String? logo, String? score, {required bool isHome}) {
    return Row(
      children: [
        TeamLogo(
          logoUrl: logo,
          size: 36,
          teamName: name,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (score != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              score,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLeagueInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              match.leagueName ?? '',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (match.countryName != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                match.countryName!,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate() {
    final date = match.dateTime;
    if (date == null) return match.formattedDate;
    
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Сегодня';
    } else if (date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day) {
      return 'Завтра';
    }
    
    return DateFormat('d MMM', 'ru').format(date);
  }
}
