import 'package:flutter/material.dart';
import 'package:swades_hackathon_app/app/theme/app_theme.dart';
import 'package:swades_hackathon_app/data/models/venue.dart';

class VenueHeader extends StatelessWidget {
  const VenueHeader({super.key, required this.venue});

  final Venue venue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sportLabel = switch (venue.sport) {
      Sport.badminton => 'BADMINTON',
      Sport.turf => 'TURF',
      Sport.unknown => 'VENUE',
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sportLabel,
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.courtGreen,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            venue.name,
            style: theme.textTheme.displaySmall?.copyWith(
              fontSize: 40,
              height: 0.95,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            venue.location,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.subtle,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.ink, width: 1),
                bottom: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _Stat(
                    label: 'RATE',
                    value: '₹${venue.pricePerHour}',
                    suffix: '/HR',
                  ),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: AppColors.border,
                ),
                Expanded(
                  child: _Stat(
                    label: 'HOURS',
                    value:
                        '${venue.opensAtHour.toString().padLeft(2, '0')}–${venue.closesAtHour.toString().padLeft(2, '0')}',
                  ),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: AppColors.border,
                ),
                Expanded(
                  child: _Stat(
                    label: 'SLOTS',
                    value:
                        '${venue.closesAtHour - venue.opensAtHour}',
                    suffix: '/DAY',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.suffix});

  final String label;
  final String value;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(height: 6),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: AppTheme.mono(
              context,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
            children: [
              TextSpan(text: value),
              if (suffix != null)
                TextSpan(
                  text: suffix,
                  style: AppTheme.mono(
                    context,
                    fontSize: 10,
                    color: AppColors.subtle,
                    letterSpacing: 1,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
