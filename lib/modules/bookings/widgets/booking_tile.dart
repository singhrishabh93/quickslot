import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:swades_hackathon_app/data/models/booking.dart';
import 'package:swades_hackathon_app/data/models/venue.dart';

class BookingTile extends StatelessWidget {
  const BookingTile({
    super.key,
    required this.booking,
    required this.isCancelling,
    required this.onCancel,
  });

  final Booking booking;
  final bool isCancelling;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final venueName = booking.venue?.name ?? 'Unknown venue';
    final local = booking.slotStartUtc.toLocal();
    final dateLabel = DateFormat('EEE, d MMM').format(local);
    final timeLabel =
        '${DateFormat('HH:mm').format(local)} – ${DateFormat('HH:mm').format(local.add(const Duration(hours: 1)))}';
    final isCancelled = booking.status == BookingStatus.cancelled;
    final venue = booking.venue;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _SportIcon(sport: venue?.sport ?? Sport.unknown),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        venueName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          decoration: isCancelled
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      if (venue != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          venue.location,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                _StatusPill(status: booking.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.event, size: 16,
                    color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(dateLabel, style: theme.textTheme.bodyMedium),
                const SizedBox(width: 16),
                Icon(Icons.schedule, size: 16,
                    color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(timeLabel, style: theme.textTheme.bodyMedium),
              ],
            ),
            if (!isCancelled) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: isCancelling ? null : onCancel,
                  icon: isCancelling
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.cancel_outlined, size: 18),
                  label: Text(isCancelling ? 'Cancelling…' : 'Cancel booking'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SportIcon extends StatelessWidget {
  const _SportIcon({required this.sport});
  final Sport sport;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = switch (sport) {
      Sport.badminton => Icons.sports_tennis,
      Sport.turf => Icons.sports_soccer,
      Sport.unknown => Icons.place,
    };
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: theme.colorScheme.onPrimaryContainer),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, bg, fg) = switch (status) {
      BookingStatus.confirmed => (
          'Confirmed',
          theme.colorScheme.primaryContainer,
          theme.colorScheme.onPrimaryContainer,
        ),
      BookingStatus.cancelled => (
          'Cancelled',
          theme.colorScheme.surfaceContainerHighest,
          theme.colorScheme.onSurfaceVariant,
        ),
      BookingStatus.unknown => (
          '—',
          theme.colorScheme.surfaceContainerHighest,
          theme.colorScheme.onSurfaceVariant,
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
