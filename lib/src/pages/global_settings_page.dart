import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../common_widgets.dart';
import '../models.dart';

class GlobalSettingsPage extends StatefulWidget {
  const GlobalSettingsPage({super.key});
  @override
  State<GlobalSettingsPage> createState() => _GlobalSettingsPageState();
}

class _GlobalSettingsPageState extends State<GlobalSettingsPage> {
  bool _notification = false;
  bool _widgetSync = false;

  void _showWip(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ac(ctx).card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          '功能开发中',
          style: TextStyle(
            color: ac(ctx).primaryText,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          '该功能正在开发中，敬请期待。',
          style: TextStyle(color: kHint, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('好的', style: TextStyle(color: kAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    return SubPageScaffold(
      title: '全局设置',
      children: [
        settingCard(context, [
          SettingRow(
            label: '深色模式',
            trailing: Switch(
              value: appState.isDarkMode,
              onChanged: (v) => appState.updateDarkMode(v),
              activeColor: const Color(0xFF4ECDC4),
            ),
          ),
          SettingRow(
            label: '课程提醒',
            trailing: Switch(
              value: _notification,
              onChanged: (v) => _showWip(context),
              activeColor: const Color(0xFF4ECDC4),
            ),
          ),
          SettingRow(
            label: '桌面小组件同步',
            showDivider: false,
            trailing: Switch(
              value: _widgetSync,
              onChanged: (v) => _showWip(context),
              activeColor: const Color(0xFF4ECDC4),
            ),
          ),
        ]),
        settingCard(context, [
          SettingRow(
            label: '设置背景格式',
            showDivider: false,
            onTap: () => _showWip(context),
            trailing: const Icon(Icons.chevron_right, color: kHint, size: 18),
          ),
        ]),
        settingCard(context, [
          SettingRow(
            label: '使用帮助',
            showDivider: false,
            trailing: const Icon(Icons.open_in_new, color: kHint, size: 16),
            onTap: () async {
              final uri = Uri.parse(
                'https://github.com/Shiroko114514/StayUP-Calendar',
              );
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
        ]),
      ],
    );
  }
}
