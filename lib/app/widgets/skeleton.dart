import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:swades_hackathon_app/app/theme/app_theme.dart';

class Skeleton extends StatelessWidget {
  const Skeleton({
    super.key,
    required this.width,
    required this.height,
    this.radius = 4,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class ShimmerScope extends StatelessWidget {
  const ShimmerScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceMuted,
      highlightColor: AppColors.paper,
      period: const Duration(milliseconds: 1400),
      child: child,
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.label, {super.key, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color ?? AppColors.subtle,
            letterSpacing: 2,
          ),
    );
  }
}
