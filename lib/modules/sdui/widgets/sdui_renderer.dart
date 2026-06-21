import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swades_hackathon_app/app/theme/app_theme.dart';
import 'package:swades_hackathon_app/data/sdui/sdui_component.dart';
import 'package:swades_hackathon_app/modules/sdui/widgets/sdui_action_handler.dart';

/// Renders a single SduiComponent — recursive.
///
/// The handler is threaded through every tap target.
class SduiRenderer extends StatelessWidget {
  const SduiRenderer({super.key, required this.tree, required this.handler});

  final SduiComponent tree;
  final SduiActionHandler handler;

  @override
  Widget build(BuildContext context) => render(context, tree, handler);

  static Widget render(
    BuildContext context,
    SduiComponent c,
    SduiActionHandler handler,
  ) {
    return switch (c) {
      SduiScreen(:final children) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final child in children) render(context, child, handler),
          ],
        ),
      SduiVerticalStack(:final spacing, :final children) =>
        _renderVerticalStack(context, spacing, children, handler),
      SduiHorizontalStack() => _renderHorizontalStack(context, c, handler),
      SduiGrid() => _renderGrid(context, c, handler),
      SduiSpacer(:final height) => SizedBox(height: height),
      SduiDivider() => const Divider(height: 1, thickness: 1),
      SduiText() => _renderText(context, c),
      SduiBanner() => _renderBanner(context, c),
      SduiPill() => _renderPill(context, c),
      SduiButton() => _renderButton(context, c, handler),
      SduiCard() => _renderCard(context, c, handler),
      SduiUserCard() => _renderUserCard(context, c, handler),
      SduiVenueRow() => _renderVenueRow(context, c, handler),
      SduiVenueHeader() => _renderVenueHeader(context, c),
      SduiDateChip() => _renderDateChip(context, c, handler),
      SduiSlotTile() => _renderSlotTile(context, c, handler),
      SduiBookingTile() => _renderBookingTile(context, c, handler),
      SduiUnknownComponent() => const SizedBox.shrink(),
    };
  }

  static Widget _renderVerticalStack(
    BuildContext context,
    double spacing,
    List<SduiComponent> children,
    SduiActionHandler handler,
  ) {
    final out = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      out.add(render(context, children[i], handler));
      if (i < children.length - 1 && spacing > 0) {
        out.add(SizedBox(height: spacing));
      }
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: out);
  }

  static Widget _renderHorizontalStack(
    BuildContext context,
    SduiHorizontalStack c,
    SduiActionHandler handler,
  ) {
    final main = switch (c.alignment) {
      SduiStackAlignment.center => MainAxisAlignment.center,
      SduiStackAlignment.end => MainAxisAlignment.end,
      SduiStackAlignment.spaceBetween => MainAxisAlignment.spaceBetween,
      SduiStackAlignment.start => MainAxisAlignment.start,
    };
    final children = <Widget>[];
    for (var i = 0; i < c.children.length; i++) {
      children.add(render(context, c.children[i], handler));
      if (i < c.children.length - 1 && c.spacing > 0) {
        children.add(SizedBox(width: c.spacing));
      }
    }
    final row = Row(mainAxisAlignment: main, children: children);
    final padded = c.padding > 0
        ? Padding(padding: EdgeInsets.symmetric(horizontal: c.padding), child: row)
        : row;
    if (c.scrollable) {
      return SizedBox(
        height: 64,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: padded,
        ),
      );
    }
    return padded;
  }

  static Widget _renderGrid(
    BuildContext context,
    SduiGrid c,
    SduiActionHandler handler,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: c.columns,
        mainAxisSpacing: c.spacing,
        crossAxisSpacing: c.spacing,
        childAspectRatio: c.aspectRatio,
      ),
      itemCount: c.children.length,
      itemBuilder: (_, i) => render(context, c.children[i], handler),
    );
  }

  static Widget _renderText(BuildContext context, SduiText c) {
    final theme = Theme.of(context);
    final base = switch (c.style) {
      SduiTextStyleVariant.display => theme.textTheme.displaySmall,
      SduiTextStyleVariant.title => theme.textTheme.headlineSmall,
      SduiTextStyleVariant.body => theme.textTheme.bodyMedium,
      SduiTextStyleVariant.caption => theme.textTheme.bodySmall,
      SduiTextStyleVariant.label => theme.textTheme.labelMedium,
    };
    final color = switch (c.color) {
      SduiTextColor.primary => AppColors.courtGreen,
      SduiTextColor.subtle => AppColors.subtle,
      SduiTextColor.danger => AppColors.clay,
      SduiTextColor.defaultColor => null,
    };
    final align = switch (c.alignment) {
      SduiTextAlignment.center => TextAlign.center,
      SduiTextAlignment.end => TextAlign.end,
      SduiTextAlignment.start => TextAlign.start,
    };
    return Text(c.value, style: base?.copyWith(color: color), textAlign: align);
  }

  static Widget _renderBanner(BuildContext context, SduiBanner c) {
    final (bg, fg) = switch (c.tone) {
      SduiBannerTone.warning => (AppColors.clayWash, AppColors.clay),
      SduiBannerTone.success => (AppColors.surfaceMuted, AppColors.courtGreen),
      SduiBannerTone.info => (AppColors.surfaceMuted, AppColors.ink),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        c.text,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: fg, fontWeight: FontWeight.w500),
      ),
    );
  }

  static Widget _renderPill(BuildContext context, SduiPill c) {
    final theme = Theme.of(context);
    final (bg, fg) = switch (c.tone) {
      SduiPillTone.success => (AppColors.surfaceMuted, AppColors.courtGreen),
      SduiPillTone.danger => (AppColors.clayWash, AppColors.clay),
      SduiPillTone.info => (AppColors.paper, AppColors.courtGreen),
      SduiPillTone.neutral => (AppColors.surfaceMuted, AppColors.subtle),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: fg),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        c.label,
        style: theme.textTheme.labelSmall
            ?.copyWith(color: fg, letterSpacing: 1.5),
      ),
    );
  }

  static Widget _renderButton(
    BuildContext context,
    SduiButton c,
    SduiActionHandler handler,
  ) {
    final onPressed =
        c.loading ? null : () => handler.dispatchAll(c.onTap);
    final child = c.loading
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.cream,
            ),
          )
        : Text(c.label);
    final button = switch (c.variant) {
      SduiButtonVariant.outlined =>
        OutlinedButton(onPressed: onPressed, child: child),
      SduiButtonVariant.text => TextButton(onPressed: onPressed, child: child),
      SduiButtonVariant.filled =>
        FilledButton(onPressed: onPressed, child: child),
    };
    return c.fullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }

  static Widget _renderCard(
    BuildContext context,
    SduiCard c,
    SduiActionHandler handler,
  ) {
    final inner = Padding(
      padding: EdgeInsets.all(c.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final child in c.children) render(context, child, handler),
        ],
      ),
    );
    final box = Material(
      color: AppColors.paper,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: c.onTap.isEmpty
          ? inner
          : InkWell(onTap: () => handler.dispatchAll(c.onTap), child: inner),
    );
    return box;
  }

  static Widget _renderUserCard(
    BuildContext context,
    SduiUserCard c,
    SduiActionHandler handler,
  ) {
    final theme = Theme.of(context);
    return Material(
      color: AppColors.paper,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: InkWell(
        onTap: () => handler.dispatchAll(c.onTap),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.name.toUpperCase(),
                      style: theme.textTheme.headlineMedium
                          ?.copyWith(height: 1, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      c.email,
                      style: AppTheme.mono(
                        context,
                        fontSize: 11,
                        color: AppColors.subtle,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                color: AppColors.ink,
                child: Text(
                  'ENTER →',
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: AppColors.cream, letterSpacing: 1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _renderVenueRow(
    BuildContext context,
    SduiVenueRow c,
    SduiActionHandler handler,
  ) {
    final theme = Theme.of(context);
    final sportLabel = switch (c.sport) {
      SduiSport.badminton => 'BADMINTON',
      SduiSport.turf => 'TURF',
      SduiSport.unknown => 'VENUE',
    };
    return Material(
      color: AppColors.paper,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: InkWell(
        onTap: c.onTap.isEmpty ? null : () => handler.dispatchAll(c.onTap),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(sportLabel,
                      style: theme.textTheme.labelMedium
                          ?.copyWith(color: AppColors.courtGreen)),
                  Text(
                    '${c.opensAtHour.toString().padLeft(2, '0')}–${c.closesAtHour.toString().padLeft(2, '0')}',
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
              Text(c.name,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(height: 1.0, letterSpacing: 0.5)),
              const SizedBox(height: 8),
              Text(c.location,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: AppColors.subtle)),
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
                        TextSpan(text: c.pricePerHour.toString()),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    color: AppColors.ink,
                    child: Text(
                      'BOOK →',
                      style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.cream, letterSpacing: 1.5),
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

  static Widget _renderVenueHeader(BuildContext context, SduiVenueHeader c) {
    final theme = Theme.of(context);
    final sportLabel = switch (c.sport) {
      SduiSport.badminton => 'BADMINTON',
      SduiSport.turf => 'TURF',
      SduiSport.unknown => 'VENUE',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(sportLabel,
            style: theme.textTheme.labelMedium
                ?.copyWith(color: AppColors.courtGreen)),
        const SizedBox(height: 8),
        Text(c.name,
            style: theme.textTheme.displaySmall
                ?.copyWith(fontSize: 40, height: 0.95)),
        const SizedBox(height: 8),
        Text(c.location,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: AppColors.subtle)),
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
                  child: _stat(context, 'RATE', '₹${c.pricePerHour}', '/HR')),
              Container(width: 1, height: 36, color: AppColors.border),
              Expanded(
                  child: _stat(
                      context,
                      'HOURS',
                      '${c.opensAtHour.toString().padLeft(2, '0')}–${c.closesAtHour.toString().padLeft(2, '0')}',
                      null)),
              Container(width: 1, height: 36, color: AppColors.border),
              Expanded(
                  child: _stat(context, 'SLOTS',
                      '${c.closesAtHour - c.opensAtHour}', '/DAY')),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _stat(
      BuildContext context, String label, String value, String? suffix) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 6),
        RichText(
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

  static Widget _renderDateChip(
    BuildContext context,
    SduiDateChip c,
    SduiActionHandler handler,
  ) {
    final theme = Theme.of(context);
    final fg = c.selected ? AppColors.cream : AppColors.ink;
    final bg = c.selected ? AppColors.ink : AppColors.paper;
    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: c.selected ? AppColors.ink : AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: InkWell(
        onTap: () => handler.dispatchAll(c.onTap),
        child: SizedBox(
          width: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  c.dayLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: c.selected ? AppColors.cream : AppColors.subtle,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  c.dateLabel,
                  style: GoogleFonts.bebasNeue(
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
      ),
    );
  }

  static Widget _renderSlotTile(
    BuildContext context,
    SduiSlotTile c,
    SduiActionHandler handler,
  ) {
    final theme = Theme.of(context);
    final isBooked = c.status == SduiSlotStatus.booked;
    final bg = isBooked ? AppColors.surfaceMuted : AppColors.paper;
    final fg = isBooked ? AppColors.subtle : AppColors.ink;
    final borderColor = isBooked ? AppColors.border : AppColors.ink;
    final statusLabel = isBooked ? 'BOOKED' : 'OPEN';
    final statusColor = isBooked ? AppColors.subtle : AppColors.courtGreen;

    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: borderColor, width: isBooked ? 1 : 1.4),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      child: InkWell(
        onTap: c.onTap.isEmpty ? null : () => handler.dispatchAll(c.onTap),
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
                c.hour.toString().padLeft(2, '0'),
                style: GoogleFonts.bebasNeue(
                  color: fg,
                  fontSize: 40,
                  height: 0.9,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${c.hour.toString().padLeft(2, '0')}:00 → ${(c.hour + 1).toString().padLeft(2, '0')}:00',
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

  static Widget _renderBookingTile(
    BuildContext context,
    SduiBookingTile c,
    SduiActionHandler handler,
  ) {
    final theme = Theme.of(context);
    final isCancelled = c.status == SduiBookingStatus.cancelled;
    final sportLabel = switch (c.sport) {
      SduiSport.badminton => 'BADMINTON',
      SduiSport.turf => 'TURF',
      _ => 'VENUE',
    };
    final statusLabel = isCancelled ? 'CANCELLED' : 'CONFIRMED';

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
                Text(sportLabel,
                    style: theme.textTheme.labelMedium
                        ?.copyWith(color: AppColors.courtGreen)),
                _renderPill(
                    context,
                    SduiPill(
                      label: statusLabel,
                      tone: isCancelled
                          ? SduiPillTone.danger
                          : SduiPillTone.success,
                    )),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              c.venueName,
              style: theme.textTheme.headlineSmall?.copyWith(
                height: 1.0,
                color: isCancelled ? AppColors.subtle : AppColors.ink,
                decoration: isCancelled ? TextDecoration.lineThrough : null,
                decorationColor: AppColors.subtle,
              ),
            ),
            if (c.location != null) ...[
              const SizedBox(height: 4),
              Text(c.location!,
                  style: theme.textTheme.bodySmall),
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
                        Text('DATE',
                            style: theme.textTheme.labelSmall),
                        const SizedBox(height: 4),
                        Text(c.dateLabel,
                            style: AppTheme.mono(
                              context,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                            )),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 32, color: AppColors.border),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('TIME',
                            style: theme.textTheme.labelSmall),
                        const SizedBox(height: 4),
                        Text(c.timeLabel,
                            style: AppTheme.mono(
                              context,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (!isCancelled && c.cancelAction.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => handler.dispatchAll(c.cancelAction),
                  child: const Text('CANCEL BOOKING'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
