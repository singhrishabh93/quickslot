import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
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
    final dateLabel =
        DateFormat('EEE, d MMM').format(slot.slotStartUtc.toLocal());

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
              Text('Confirm booking', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              _Row(label: 'Venue', value: venue.name),
              _Row(label: 'Date', value: dateLabel),
              _Row(label: 'Time', value: slot.displayRange),
              _Row(label: 'Price', value: '₹${venue.pricePerHour}'),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: isSubmitting
                    ? null
                    : () => context.read<CreateBookingCubit>().book(
                          venueId: venue.id,
                          slotStartUtc: slot.slotStartUtc.toIso8601String(),
                        ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : const Text('Confirm'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: isSubmitting
                    ? null
                    : () => Navigator.of(context)
                        .pop(BookingSheetResult.cancelled),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.titleSmall),
          ),
        ],
      ),
    );
  }
}
