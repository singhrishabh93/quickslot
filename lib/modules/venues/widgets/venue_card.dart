import 'package:flutter/material.dart';
import 'package:swades_hackathon_app/app/theme/app_theme.dart';
import 'package:swades_hackathon_app/data/models/venue.dart';

class VenueCard extends StatelessWidget {
  const VenueCard({
    super.key,
    required this.venue,
    required this.onTap,
  });

  final Venue venue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sportLabel = switch (venue.sport) {
      Sport.badminton => 'BADMINTON',
      Sport.turf => 'TURF',
      Sport.unknown => 'VENUE',
    };

    return Material(
      color: AppColors.paper,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    sportLabel,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.courtGreen,
                    ),
                  ),
                  Text(
                    '${venue.opensAtHour.toString().padLeft(2, '0')}–${venue.closesAtHour.toString().padLeft(2, '0')}',
                    style: AppTheme.mono(
                      context,
                      fontSize: 11,
                      color: AppColors.subtle,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                venue.name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  height: 1.0,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                venue.location,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.subtle,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  RichText(
                    text: TextSpan(
                      style: AppTheme.mono(
                        context,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                      children: [
                        const TextSpan(text: '₹'),
                        TextSpan(text: venue.pricePerHour.toString()),
                        TextSpan(
                          text: ' /HR',
                          style: AppTheme.mono(
                            context,
                            fontSize: 11,
                            color: AppColors.subtle,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: const BoxDecoration(
                      color: AppColors.ink,
                    ),
                    child: Text(
                      'BOOK →',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.cream,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
