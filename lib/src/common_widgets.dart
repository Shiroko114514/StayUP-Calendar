import 'package:flutter/material.dart';
import 'models.dart';
import 'l10n.dart';

// ─────────────────────────────────────────────
// 常量定义
// ─────────────────────────────────────────────

const Color kAccent = Color(0xFFFF3B5C);
const Color kHint = Color(0xFF6C6C70);
const Color kDivider = Color(0xFFE5E5EA);

// ─────────────────────────────────────────────
// 便捷访问函数
// ─────────────────────────────────────────────

AppColors ac(BuildContext context) =>
    Theme.of(context).extension<AppColors>() ?? AppColors.light;

// ─────────────────────────────────────────────
// 通用 Widget 组件
// ─────────────────────────────────────────────

/// 子页面 Scaffold
class SubPageScaffold extends StatelessWidget {
  final String title;
  final String? centerTitle;
  final List<Widget> children;

  const SubPageScaffold({
    super.key,
    required this.title,
    this.centerTitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ac(context).bg,
      appBar: AppBar(
  backgroundColor: ac(context).card,
  elevation: 0,
  scrolledUnderElevation: 0,

  leading: GestureDetector(
    onTap: () => Navigator.pop(context),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 8),
        const Icon(Icons.arrow_back_ios, color: kAccent, size: 17),
        Text(
          context.l10n.backAction,
          style: const TextStyle(color: kAccent, fontSize: 15),
        ),
      ],
    ),
  ),
  leadingWidth: 80,

  title: Text(
    centerTitle ?? title,
    style: TextStyle(
      color: ac(context).primaryText,
      fontSize: 17,
      fontWeight: FontWeight.w600,
    ),
  ),

  centerTitle: true,

  bottom: PreferredSize(
    preferredSize: const Size.fromHeight(0.5),
    child: Container(height: 0.5, color: ac(context).divider),
  ),
),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: children,
      ),
    );
  }
}

/// 设置卡片容器
Widget settingCard(BuildContext context, List<Widget> items) {
  return Container(
    decoration: BoxDecoration(
      color: ac(context).card,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(children: items),
  );
}

/// 设置行组件
class SettingRow extends StatelessWidget {
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;

  const SettingRow({
    super.key,
    required this.label,
    this.trailing,
    this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: ac(context).primaryText, fontSize: 15),
            ),
          ),
          if (trailing != null) trailing!,
          if (onTap != null && trailing == null)
            Icon(Icons.chevron_right, color: ac(context).hint, size: 18),
        ],
      ),
    );

    return Column(
      children: [
        onTap != null
            ? GestureDetector(
                onTap: onTap,
                behavior: HitTestBehavior.opaque,
                child: content,
              )
            : content,
        if (showDivider)
          Container(
            height: 0.5,
            color: ac(context).divider,
            margin: const EdgeInsets.only(left: 16),
          ),
      ],
    );
  }
}