import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:swades_hackathon_app/app/theme/app_theme.dart';

class DateChipsRow extends StatelessWidget {
  const DateChipsRow({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.daysAhead = 7,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final int daysAhead;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = List.generate(daysAhead, (i) {
      return DateTime(today.year, today.month, today.day + i);
    });
    return Container(
      height: 96,
      color: AppColors.cream,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 6),
            child: Text(
              'PICK A DAY',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              itemCount: days.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final d = days[i];
                final isSelected = d.year == selectedDate.year &&
                    d.month == selectedDate.month &&
                    d.day == selectedDate.day;
                return _DateChip(
                  date: d,
                  isSelected: isSelected,
                  onTap: () => onDateSelected(d),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.date,
    required this.isSelected,
    required this.onTap,
  });

  final DateTime date;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fg = isSelected ? AppColors.cream : AppColors.ink;
    final bg = isSelected ? AppColors.ink : AppColors.paper;
    final border = isSelected ? AppColors.ink : AppColors.border;

    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: border, width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 56,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat('EEE').format(date).toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isSelected ? AppColors.cream : AppColors.subtle,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                DateFormat('d').format(date),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: fg,
                  fontSize: 26,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
