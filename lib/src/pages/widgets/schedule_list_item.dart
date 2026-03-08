part of '../manage_schedule_page.dart';

class _ScheduleListItem extends StatelessWidget {
  final String name;
  final bool isActive;
  final bool isEditing;
  final int index;
  final bool isLast;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _ScheduleListItem({
    super.key,
    required this.name,
    required this.isActive,
    required this.isEditing,
    required this.index,
    required this.isLast,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: ac(context).card,
            borderRadius: BorderRadius.vertical(
              top: index == 0 ? const Radius.circular(12) : Radius.zero,
              bottom: isLast ? const Radius.circular(12) : Radius.zero,
            ),
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: isEditing ? null : onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              child: Row(children: [
                if (isEditing) ...[
                  GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: onDelete != null
                            ? const Color(0xFFFF3B5C)
                            : const Color(0xFFD1D1D6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.remove, color: Color(0xFF1C1C1E), size: 14),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      color: isActive && !isEditing ? const Color(0xFF4ECDC4) : ac(context).primaryText,
                      fontSize: 16,
                      fontWeight: isActive && !isEditing ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                if (isEditing)
                  ReorderableDragStartListener(
                    index: index,
                    child: Icon(Icons.drag_handle, color: ac(context).hint, size: 20),
                  )
                else if (isActive)
                  const Icon(Icons.check, color: Color(0xFF4ECDC4), size: 18)
                else
                  Icon(Icons.chevron_right, color: ac(context).hint, size: 20),
              ]),
            ),
          ),
        ),
        if (!isLast)
          Container(
            height: 0.5,
            color: ac(context).divider,
            margin: EdgeInsets.only(left: isEditing ? 50 : 16),
          ),
      ],
    );
  }
}
