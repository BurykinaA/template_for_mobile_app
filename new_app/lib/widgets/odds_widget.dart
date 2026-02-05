import 'package:flutter/material.dart';
import '../models/match.dart';
import '../config/app_theme.dart';

/// Widget to display match odds/coefficients
class OddsWidget extends StatelessWidget {
  final OddsMarket? odds;
  final bool compact;

  const OddsWidget({
    super.key,
    this.odds,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (odds == null) {
      return const SizedBox.shrink();
    }

    if (compact) {
      return _buildCompactOdds();
    }

    return _buildFullOdds();
  }

  Widget _buildCompactOdds() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (odds!.homeWin != null)
          _buildOddChip('1', odds!.homeWin!, AppTheme.primaryColor),
        if (odds!.draw != null) ...[
          const SizedBox(width: 6),
          _buildOddChip('X', odds!.draw!, Colors.grey),
        ],
        if (odds!.awayWin != null) ...[
          const SizedBox(width: 6),
          _buildOddChip('2', odds!.awayWin!, AppTheme.accentColor),
        ],
      ],
    );
  }

  Widget _buildOddChip(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$label: ${value.toStringAsFixed(2)}',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildFullOdds() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_outlined, size: 18, color: AppTheme.textSecondary),
              const SizedBox(width: 8),
              const Text(
                'Коэффициенты',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                odds!.marketName,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildOddCard(
                  'Победа 1',
                  odds!.homeWin,
                  AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOddCard(
                  'Ничья',
                  odds!.draw,
                  Colors.grey[600]!,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOddCard(
                  'Победа 2',
                  odds!.awayWin,
                  AppTheme.accentColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOddCard(String label, double? value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value != null ? value.toStringAsFixed(2) : '-',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: value != null ? color : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget to display Glicko ratings for a match
class GlickoWidget extends StatelessWidget {
  final Map<String, dynamic>? glicko;

  const GlickoWidget({
    super.key,
    this.glicko,
  });

  @override
  Widget build(BuildContext context) {
    if (glicko == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, size: 18, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Text(
                'Glicko-2 Рейтинг',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildRatingCard(
                  'Хозяева',
                  glicko!['homeRating']?.toDouble(),
                  glicko!['homeWinProbability']?.toDouble(),
                  AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRatingCard(
                  'Гости',
                  glicko!['awayRating']?.toDouble(),
                  glicko!['awayWinProbability']?.toDouble(),
                  AppTheme.accentColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingCard(String label, double? rating, double? probability, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            rating != null ? rating.toStringAsFixed(0) : '-',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (probability != null) ...[
            const SizedBox(height: 4),
            Text(
              '${(probability * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
