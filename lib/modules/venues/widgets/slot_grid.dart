import 'package:flutter/material.dart';
import 'package:swades_hackathon_app/data/models/slot.dart';
import 'package:swades_hackathon_app/modules/venues/widgets/slot_tile.dart';

class SlotGrid extends StatelessWidget {
  const SlotGrid({
    super.key,
    required this.slots,
    required this.onSlotTap,
  });

  final List<Slot> slots;
  final ValueChanged<Slot> onSlotTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.35,
      ),
      itemCount: slots.length,
      itemBuilder: (_, i) => SlotTile(
        slot: slots[i],
        onTap: () => onSlotTap(slots[i]),
      ),
    );
  }
}
