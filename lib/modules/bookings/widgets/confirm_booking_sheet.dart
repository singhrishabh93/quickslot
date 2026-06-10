import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:swades_hackathon_app/app/theme/app_theme.dart';
import 'package:swades_hackathon_app/data/di/service_locator.dart';
import 'package:swades_hackathon_app/data/models/slot.dart';
import 'package:swades_hackathon_app/data/models/venue.dart';
import 'package:swades_hackathon_app/data/utils/failure.dart';
import 'package:swades_hackathon_app/modules/bookings/cubit/create_booking_cubit.dart';
import 'package:swades_hackathon_app/modules/bookings/cubit/create_booking_state.dart';

enum BookingSheetResult { success, slotTaken, failed, cancelled }

class ConfirmBookingSheet extends StatelessWidget {
  const ConfirmBookingSheet({
    super.key,
    required this.venue,
    required this.slot,
  });

  final Venue venue;
  final Slot slot;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateBookingCubit>(
      create: (_) => getIt<CreateBookingCubit>(),
      child: _SheetBody(venue: venue, slot: slot),
    );
  }
}

class _SheetBody extends StatelessWidget {
  const _SheetBody({required this.venue, required this.slot});

  final Venue venue;
  final Slot slot;

  void _onConfirmStateChange(BuildContext context, CreateBookingState state) {
    switch (state) {
      case CreateBookingSuccess():
        Navigator.of(context).pop(BookingSheetResult.success);
      case CreateBookingFailureState(:final failure):
        Navigator.of(context).pop(
          failure is SlotTakenFailure
              ? BookingSheetResult.slotTaken
              : BookingSheetResult.failed,
        );
      case CreateBookingInitial() || CreateBookingSubmitting():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final local = slot.slotStartUtc.toLocal();
    final dateLabel = DateFormat('EEE, d MMM').format(local).toUpperCase();
    final timeLabel =
        '${DateFormat('HH:mm').format(local)} → ${DateFormat('HH:mm').format(local.add(const Duration(hours: 1)))}';

    return BlocConsumer<CreateBookingCubit, CreateBookingState>(
      listener: _onConfirmStateChange,
      builder: (context, state) {
        final isSubmitting = state is CreateBookingSubmitting;
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 8,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CONFIRM',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.courtGreen,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'BOOK THIS SLOT',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontSize: 40,
                  height: 1,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.paper,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  children: [
                    _Row(label: 'VENUE', value: venue.name.toUpperCase()),
                    const Divider(height: 18),
                    _Row(label: 'DATE', value: dateLabel),
                    const Divider(height: 18),
                    _Row(label: 'TIME', value: timeLabel, mono: true),
                    const Divider(height: 18),
                    _Row(
                      label: 'PRICE',
                      value: '₹${venue.pricePerHour}',
                      mono: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: isSubmitting
                    ? null
                    : () => context.read<CreateBookingCubit>().book(
                          venueId: venue.id,
                          slotStartUtc: slot.slotStartUtc.toIso8601String(),
                        ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.cream,
                        ),
                      )
                    : const Text('CONFIRM BOOKING'),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: isSubmitting
                    ? null
                    : () => Navigator.of(context)
                        .pop(BookingSheetResult.cancelled),
                child: const Text('CANCEL'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.mono = false,
  });

  final String label;
  final String value;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        SizedBox(
          width: 64,
          child: Text(label, style: theme.textTheme.labelSmall),
        ),
        Expanded(
          child: Text(
            value,
            style: mono
                ? AppTheme.mono(
                    context,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  )
                : theme.textTheme.titleSmall,
          ),
        ),
      ],
    );
  }
}
