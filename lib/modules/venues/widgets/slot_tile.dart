import 'package:flutter/material.dart';
import 'package:swades_hackathon_app/app/theme/app_theme.dart';
import 'package:swades_hackathon_app/data/models/slot.dart';

class SlotTile extends StatelessWidget {
  const SlotTile({
    super.key,
    required this.slot,
    required this.onTap,
  });

  final Slot slot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBooked = slot.isBooked;

    final borderColor = isBooked ? AppColors.border : AppColors.ink;
    final bg = isBooked ? AppColors.surfaceMuted : AppColors.paper;
    final fg = isBooked ? AppColors.subtle : AppColors.ink;
    final statusLabel = isBooked ? 'BOOKED' : 'OPEN';
    final statusColor = isBooked ? AppColors.subtle : AppColors.courtGreen;

    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: borderColor, width: isBooked ? 1 : 1.4),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      child: InkWell(
        onTap: isBooked ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    statusLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: statusColor,
                      letterSpacing: 1.8,
                    ),
                  ),
                  const Spacer(),
                  if (!isBooked)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.courtGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                slot.hour.toString().padLeft(2, '0'),
                style: theme.textTheme.displaySmall?.copyWith(
                  color: fg,
                  fontSize: 40,
                  height: 0.9,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${slot.hour.toString().padLeft(2, '0')}:00 → ${(slot.hour + 1).toString().padLeft(2, '0')}:00',
                style: AppTheme.mono(
                  context,
                  fontSize: 10,
                  color: AppColors.subtle,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
