import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/app_theme.dart';

/// Team logo widget with caching
class TeamLogo extends StatelessWidget {
  final String? logoUrl;
  final double size;
  final String? teamName;

  const TeamLogo({
    super.key,
    this.logoUrl,
    this.size = 40,
    this.teamName,
  });

  @override
  Widget build(BuildContext context) {
    if (logoUrl == null || logoUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    return CachedNetworkImage(
      imageUrl: logoUrl!,
      width: size,
      height: size,
      fit: BoxFit.contain,
      placeholder: (context, url) => _buildLoadingPlaceholder(),
      errorWidget: (context, url, error) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          teamName != null && teamName!.isNotEmpty
              ? teamName![0].toUpperCase()
              : '?',
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
        ),
      ),
    );
  }
}

/// League logo widget
class LeagueLogo extends StatelessWidget {
  final String? logoUrl;
  final double size;

  const LeagueLogo({
    super.key,
    this.logoUrl,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    if (logoUrl == null || logoUrl!.isEmpty) {
      return Icon(
        Icons.emoji_events_outlined,
        size: size,
        color: AppTheme.primaryColor,
      );
    }

    return CachedNetworkImage(
      imageUrl: logoUrl!,
      width: size,
      height: size,
      fit: BoxFit.contain,
      placeholder: (context, url) => SizedBox(
        width: size,
        height: size,
        child: const Center(
          child: SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 1.5),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Icon(
        Icons.emoji_events_outlined,
        size: size,
        color: AppTheme.primaryColor,
      ),
    );
  }
}

/// Country flag widget
class CountryFlag extends StatelessWidget {
  final String? countryCode;
  final String? flagUrl;
  final double size;

  const CountryFlag({
    super.key,
    this.countryCode,
    this.flagUrl,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    if (flagUrl != null && flagUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: flagUrl!,
        width: size,
        height: size * 0.67,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: size,
      height: size * 0.67,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
      child: Icon(
        Icons.flag_outlined,
        size: size * 0.5,
        color: Colors.grey[500],
      ),
    );
  }
}
