import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:swades_hackathon_app/app/theme/app_theme.dart';
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
    final venue = booking.venue;
    final venueName = venue?.name ?? 'Unknown venue';
    final sportLabel = switch (venue?.sport ?? Sport.unknown) {
      Sport.badminton => 'BADMINTON',
      Sport.turf => 'TURF',
      Sport.unknown => 'VENUE',
    };
    final local = booking.slotStartUtc.toLocal();
    final isCancelled = booking.status == BookingStatus.cancelled;
    final statusLabel = isCancelled ? 'CANCELLED' : 'CONFIRMED';
    final statusColor = isCancelled ? AppColors.clay : AppColors.courtGreen;
    final dateStr = DateFormat('d MMM').format(local).toUpperCase();
    final dayStr = DateFormat('EEE').format(local).toUpperCase();
    final timeStr =
        '${DateFormat('HH:mm').format(local)} → ${DateFormat('HH:mm').format(local.add(const Duration(hours: 1)))}';

    return Material(
      color: AppColors.paper,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
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
                _StatusPill(label: statusLabel, color: statusColor),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              venueName,
              style: theme.textTheme.headlineSmall?.copyWith(
                height: 1.0,
                color: isCancelled ? AppColors.subtle : AppColors.ink,
                decoration: isCancelled ? TextDecoration.lineThrough : null,
                decorationColor: AppColors.subtle,
              ),
            ),
            if (venue != null) ...[
              const SizedBox(height: 4),
              Text(
                venue.location,
                style: theme.textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.border, width: 1),
                  bottom: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('DATE', style: theme.textTheme.labelSmall),
                        const SizedBox(height: 4),
                        Text(
                          '$dayStr · $dateStr',
                          style: AppTheme.mono(
                            context,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 32, color: AppColors.border),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('TIME', style: theme.textTheme.labelSmall),
                        const SizedBox(height: 4),
                        Text(
                          timeStr,
                          style: AppTheme.mono(
                            context,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (!isCancelled) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: isCancelling ? null : onCancel,
                  child: isCancelling
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.ink,
                          ),
                        )
                      : const Text('CANCEL BOOKING'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              letterSpacing: 1.5,
            ),
      ),
    );
  }
}
