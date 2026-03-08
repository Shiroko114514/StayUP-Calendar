import 'package:flutter/material.dart';

import '../common_widgets.dart';
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
          child: const Text('返回', style: TextStyle(color: kAccent, fontSize: 16)),
        ),
        leadingWidth: 60,
        title: const Text('多课表管理', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => setState(() => _isEditing = !_isEditing),
            child: Text(
              _isEditing ? '完成' : '编辑',
              style: const TextStyle(color: kAccent, fontSize: 16),
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
                    final idxList = List<int>.generate(schedules.length, (i) => i);
                    final item = idxList.removeAt(oldIndex);
                    idxList.insert(newIndex, item);
                    s.reorderSchedules(idxList);
                  }
                : (_, __) {},
            header: const Padding(
              padding: EdgeInsets.only(left: 2, bottom: 10),
              child: Text('点右上角的编辑以排序或删除', style: TextStyle(color: kHint, fontSize: 13)),
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
                      MaterialPageRoute(builder: (_) => const ScheduleDataPage()),
                    );
                  }
                },
                onDelete: schedules.length > 1 ? () => _confirmDelete(ctx, s, i, name) : null,
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
              child: const Text(
                '新建课表',
                style: TextStyle(color: kAccent, fontSize: 17, fontWeight: FontWeight.w500),
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
        title: const Text('删除课表', style: TextStyle(fontSize: 16)),
        content: Text(
          '确定删除「$name」？此操作不可恢复。',
          style: const TextStyle(color: kHint, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消', style: TextStyle(color: kHint)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              s.removeSchedule(i);
              setState(() {});
            },
            child: const Text('删除', style: TextStyle(color: Color(0xFFFF3B5C))),
          ),
        ],
      ),
    );
  }
}
