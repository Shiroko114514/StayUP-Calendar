import 'package:flutter/material.dart';

import '../common_widgets.dart';
import '../l10n.dart';
import '../models.dart';
import 'new_schedule_page.dart';
import '../schedule_settings.dart';

part 'widgets/schedule_list_item.dart';

class ManageSchedulePage extends StatefulWidget {
  const ManageSchedulePage({super.key});
  @override
  State<ManageSchedulePage> createState() => _ManageSchedulePageState();
}

class _ManageSchedulePageState extends State<ManageSchedulePage> {
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    final s = AppStateScope.of(context);
    final schedules = s.scheduleNames;

    return Scaffold(
      backgroundColor: ac(context).bg,
      appBar: AppBar(
        backgroundColor: ac(context).bg,
        elevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            context.l10n.backAction,
            style: const TextStyle(color: kAccent, fontSize: 15),
          ),
        ),
        leadingWidth: 60,
        title: Text(
          context.l10n.manageScheduleTitle,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => setState(() => _isEditing = !_isEditing),
            child: Text(
              _isEditing ? context.l10n.doneAction : context.l10n.editAction,
              style: const TextStyle(color: kAccent, fontSize: 15),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          ReorderableListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
            buildDefaultDragHandles: false,
            onReorder: _isEditing
                ? (oldIndex, newIndex) {
                    if (newIndex > oldIndex) newIndex--;
                    final idxList = List<int>.generate(
                      schedules.length,
                      (i) => i,
                    );
                    final item = idxList.removeAt(oldIndex);
                    idxList.insert(newIndex, item);
                    s.reorderSchedules(idxList);
                  }
                : (_, __) {},
            header: Padding(
              padding: const EdgeInsets.only(left: 2, bottom: 10),
              child: Text(
                context.l10n.manageScheduleHint,
                style: const TextStyle(color: kHint, fontSize: 13),
              ),
            ),
            itemCount: schedules.length,
            itemBuilder: (ctx, i) {
              final name = schedules[i];
              final isActive = i == s.activeScheduleIndex;
              return _ScheduleListItem(
                key: ValueKey(name + i.toString()),
                name: name,
                isActive: isActive,
                isEditing: _isEditing,
                index: i,
                isLast: i == schedules.length - 1,
                onTap: () {
                  s.switchSchedule(i);
                  if (_isEditing) {
                    Navigator.pop(context);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ScheduleDataPage(),
                      ),
                    );
                  }
                },
                onDelete: schedules.length > 1
                    ? () => _confirmDelete(ctx, s, i, name)
                    : null,
              );
            },
          ),
          Positioned(
            bottom: 24,
            right: 20,
            child: GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (_) => const NewSchedulePage(),
                  ),
                );
                setState(() {});
              },
              child: Text(
                context.l10n.newScheduleButton,
                style: const TextStyle(
                  color: kAccent,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext ctx, AppState s, int i, String name) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: ac(context).card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          context.l10n.deleteScheduleTitle,
          style: const TextStyle(fontSize: 16),
        ),
        content: Text(
          context.l10n.deleteScheduleMessage(name),
          style: const TextStyle(color: kHint, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              context.l10n.cancelAction,
              style: const TextStyle(color: kHint),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              s.removeSchedule(i);
              setState(() {});
            },
            child: Text(
              context.l10n.deleteAction,
              style: const TextStyle(color: Color(0xFFFF3B5C)),
            ),
          ),
        ],
      ),
    );
  }
}