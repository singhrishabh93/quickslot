import 'package:flutter/material.dart';
import 'package:swades_hackathon_app/app/theme/app_theme.dart';

class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.numeral,
    required this.label,
    required this.caption,
  });

  final String numeral;
  final String label;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            numeral,
            style: theme.textTheme.displayLarge?.copyWith(
              color: AppColors.surfaceMuted,
              fontSize: 140,
              height: 0.9,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(
              letterSpacing: 2,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(caption, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ERR',
            style: theme.textTheme.displayLarge?.copyWith(
              color: AppColors.clay,
              fontSize: 120,
              height: 0.9,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'SOMETHING BROKE',
            style: theme.textTheme.labelLarge?.copyWith(letterSpacing: 2),
          ),
          const SizedBox(height: 6),
          Text(message, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 24),
          SizedBox(
            width: 200,
            child: OutlinedButton(
              onPressed: onRetry,
              child: const Text('TRY AGAIN'),
            ),
          ),
        ],
      ),
    );
  }
}
