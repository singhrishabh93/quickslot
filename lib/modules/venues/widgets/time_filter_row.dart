import 'package:flutter/material.dart';
import 'package:swades_hackathon_app/app/theme/app_theme.dart';
import 'package:swades_hackathon_app/modules/venues/cubit/venue_detail_state.dart';

class TimeFilterRow extends StatelessWidget {
  const TimeFilterRow({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final TimeOfDayFilter selected;
  final ValueChanged<TimeOfDayFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final filters = TimeOfDayFilter.values;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FILTER',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final f in filters)
                _Chip(
                  label: f.label,
                  isSelected: f == selected,
                  onTap: () => onChanged(f),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = isSelected ? AppColors.cream : AppColors.ink;
    final bg = isSelected ? AppColors.ink : AppColors.paper;
    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: isSelected ? AppColors.ink : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(2),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: fg,
                  letterSpacing: 1.4,
                ),
          ),
        ),
      ),
    );
  }
}
