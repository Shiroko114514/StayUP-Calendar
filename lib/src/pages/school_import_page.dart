import 'package:flutter/material.dart';

import '../common_widgets.dart';

part 'widgets/school_import_widgets.dart';

class SchoolImportPage extends StatefulWidget {
  const SchoolImportPage({super.key});
  @override
  State<SchoolImportPage> createState() => _SchoolImportPageState();
}

class _SchoolImportPageState extends State<SchoolImportPage> {
  // 支持的学校列表（拼音首字母 → 显示名称）
  static const List<Map<String, String>> _allSchools = [
    {'name': '华中科技大学', 'pinyin': 'H'},
    {'name': '江西师范大学', 'pinyin': 'J'},
    {'name': '上海交通大学', 'pinyin': 'S'},
    {'name': '武汉大学',     'pinyin': 'W'},
    {'name': '香港中文大学（深圳）', 'pinyin': 'X'},
    {'name': '中国人民大学', 'pinyin': 'Z'},
  ];

  // 按首字母分组
  static Map<String, List<String>> get _grouped {
    final map = <String, List<String>>{};
    for (final s in _allSchools) {
      final letter = s['pinyin']!;
      map.putIfAbsent(letter, () => []).add(s['name']!);
    }
    return map;
  }

  // 字母索引列表（已排序）
  static List<String> get _letters {
    final keys = _grouped.keys.toList()..sort();
    return keys;
  }

  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  String _query = '';

  // 每个字母 section 的 ScrollController key → offset 映射（按索引跳转）
  // 用 GlobalKey 计算各 section 高度
  final Map<String, GlobalKey> _sectionKeys = {};

  @override
  void initState() {
    super.initState();
    for (final l in _letters) {
      _sectionKeys[l] = GlobalKey();
    }
    _searchCtrl.addListener(() => setState(() => _query = _searchCtrl.text.trim()));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // 过滤结果
  List<Map<String, String>> get _filtered {
    if (_query.isEmpty) return _allSchools;
    return _allSchools.where((s) => s['name']!.contains(_query)).toList();
  }

  // 按字母分组（过滤后）
  Map<String, List<String>> get _filteredGrouped {
    final map = <String, List<String>>{};
    for (final s in _filtered) {
      final letter = s['pinyin']!;
      map.putIfAbsent(letter, () => []).add(s['name']!);
    }
    return map;
  }

  List<String> get _filteredLetters {
    final keys = _filteredGrouped.keys.toList()..sort();
    return keys;
  }

  // 跳转到某字母 section
  void _jumpToLetter(String letter) {
    final grouped = _filteredGrouped;
    final letters = _filteredLetters;
    if (!letters.contains(letter)) return;
    // 计算该字母前所有 section 的高度偏移量
    // 每个 section = header(36) + items*56
    double offset = 0;
    for (final l in letters) {
      if (l == letter) break;
      final count = grouped[l]!.length;
      offset += 36 + count * 56.0;
    }
    _scrollCtrl.animateTo(
      offset.clamp(0, _scrollCtrl.position.maxScrollExtent),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _onSchoolTap(String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: ac(context).card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(children: [
          const Icon(Icons.school_outlined, color: Color(0xFF6C6C70), size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(name, style: const TextStyle(color: const Color(0xFF1C1C1E), fontSize: 16, fontWeight: FontWeight.w600))),
        ]),
        content: const Text(
          '该学校的课程导入功能正在开发中，敬请期待。',
          style: TextStyle(color: Color(0xFF6C6C70), fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('好的', style: TextStyle(color: Color(0xFFFF3B5C), fontSize: 15)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _filteredGrouped;
    final letters = _filteredLetters;
    final allLetters = _letters; // 全部字母，用于右侧索引条

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Column(
          children: [
            // ── 顶部搜索栏 ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Text('返回', style: TextStyle(color: Color(0xFFFF3B5C), fontSize: 16)),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        style: const TextStyle(color: const Color(0xFF1C1C1E), fontSize: 15),
                        decoration: const InputDecoration(
                          hintText: '搜索学校',
                          hintStyle: TextStyle(color: Color(0xFF6C6C70), fontSize: 15),
                          prefixIcon: Icon(Icons.search, color: Color(0xFF6C6C70), size: 20),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── 提示文字 ──
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Text(
                '在搜索框输入学校全称以快速定位',
                style: TextStyle(color: Color(0xFF6C6C70), fontSize: 13),
              ),
            ),

            // ── 列表 + 右侧字母索引条 ──
            Expanded(
              child: Stack(
                children: [
                  // 主列表
                  ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.only(right: 28, bottom: 20),
                    itemCount: letters.fold<int>(0, (sum, l) => sum + 1 + grouped[l]!.length),
                    itemBuilder: (context, index) {
                      // 映射 index → section header 或 item
                      int cursor = 0;
                      for (final letter in letters) {
                        if (index == cursor) {
                          // section header
                          return _SectionHeader(letter: letter);
                        }
                        cursor++;
                        final items = grouped[letter]!;
                        if (index < cursor + items.length) {
                          final itemIdx = index - cursor;
                          final name = items[itemIdx];
                          final isLast = itemIdx == items.length - 1;
                          return _SchoolRow(
                            name: name,
                            showDivider: !isLast,
                            onTap: () => _onSchoolTap(name),
                          );
                        }
                        cursor += items.length;
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  // 右侧字母索引条
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: _AlphaIndexBar(
                      letters: allLetters,
                      onLetterTap: _jumpToLetter,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
