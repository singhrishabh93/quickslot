import 'package:flutter/material.dart';
import 'package:swades_hackathon_app/data/models/venue.dart';

class VenueHeader extends StatelessWidget {
  const VenueHeader({super.key, required this.venue});

  final Venue venue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, sportLabel) = switch (venue.sport) {
      Sport.badminton => (Icons.sports_tennis, 'Badminton'),
      Sport.turf => (Icons.sports_soccer, 'Turf'),
      Sport.unknown => (Icons.place, 'Venue'),
    };
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sportLabel, style: theme.textTheme.labelMedium),
                    const SizedBox(height: 2),
                    Text(venue.location, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    Text(
                      '₹${venue.pricePerHour}/hr · ${venue.opensAtHour}:00 – ${venue.closesAtHour}:00',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
