import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../common_widgets.dart';
import '../l10n.dart';
import '../models.dart';

class GlobalSettingsPage extends StatefulWidget {
  const GlobalSettingsPage({super.key});
  @override
  State<GlobalSettingsPage> createState() => _GlobalSettingsPageState();
}

class _GlobalSettingsPageState extends State<GlobalSettingsPage> {
  final bool _notification = false;
  final bool _widgetSync = false;
  bool _isExitingForLocaleChange = false;

  void _showRestartAndExitNotice(BuildContext context) {
    if (_isExitingForLocaleChange) return;
    _isExitingForLocaleChange = true;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: ac(ctx).card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          ctx.l10n.languageChangedRestartTitle,
          style: TextStyle(
            color: ac(ctx).primaryText,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          ctx.l10n.languageChangedRestartMessage,
          style: const TextStyle(color: kHint, fontSize: 14),
        ),
      ),
    );

    Future.delayed(const Duration(milliseconds: 1200), () {
      SystemNavigator.pop();
    });
  }

  void _showWip(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ac(ctx).card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          ctx.l10n.featureInDevelopmentTitle,
          style: TextStyle(
            color: ac(ctx).primaryText,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          ctx.l10n.featureInDevelopmentMessage,
          style: TextStyle(color: kHint, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              ctx.l10n.okAction,
              style: const TextStyle(color: kAccent),
            ),
          ),
        ],
      ),
    );
  }

  String _localeModeLabel(BuildContext context, String mode) {
    final l10n = context.l10n;
    switch (mode) {
      case kLocaleModeChineseSimplified:
        return l10n.languageForceChineseSimplified;
      case kLocaleModeChineseTraditional:
        return l10n.languageForceChineseTraditional;
      case kLocaleModeEnglish:
        return l10n.languageForceEnglish;
      case kLocaleModeJapanese:
        return l10n.languageForceJapanese;
      default:
        return l10n.languageFollowSystem;
    }
  }

  String _datePatternLabel(BuildContext context, String pattern) {
    final sample = DateFormat(pattern).format(DateTime.now());
    return '$pattern  ($sample)';
  }

  void _showDateFormatPicker(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ac(context).card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        final options = [
          kDateFormatYmdSlash,
          kDateFormatYmdDash,
          kDateFormatMdySlash,
          kDateFormatDmySlash,
        ];
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.dateFormatSettingLabel,
                style: TextStyle(
                  color: ac(context).primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ...options.map(
                (pattern) => GestureDetector(
                  onTap: () {
                    appState.updateDateFormatPattern(pattern);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 4,
                    ),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: kDivider, width: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          _datePatternLabel(context, pattern),
                          style: TextStyle(
                            color: pattern == appState.dateFormatPattern
                                ? const Color(0xFF4ECDC4)
                                : ac(context).primaryText,
                            fontSize: 15,
                          ),
                        ),
                        const Spacer(),
                        if (pattern == appState.dateFormatPattern)
                          const Icon(
                            Icons.check,
                            color: Color(0xFF4ECDC4),
                            size: 18,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLanguagePicker(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ac(context).card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        final options = [
          kLocaleModeSystem,
          kLocaleModeChineseSimplified,
          kLocaleModeChineseTraditional,
          kLocaleModeEnglish,
          kLocaleModeJapanese,
        ];
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.languageSettingLabel,
                style: TextStyle(
                  color: ac(context).primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ...options.map(
                (mode) => GestureDetector(
                  onTap: () {
                    final changed = mode != appState.localeMode;
                    appState.updateLocaleMode(mode);
                    Navigator.pop(context);
                    if (changed) {
                      _showRestartAndExitNotice(context);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 4,
                    ),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: kDivider, width: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          _localeModeLabel(context, mode),
                          style: TextStyle(
                            color: mode == appState.localeMode
                                ? const Color(0xFF4ECDC4)
                                : ac(context).primaryText,
                            fontSize: 15,
                          ),
                        ),
                        const Spacer(),
                        if (mode == appState.localeMode)
                          const Icon(
                            Icons.check,
                            color: Color(0xFF4ECDC4),
                            size: 18,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    return SubPageScaffold(
      title: context.l10n.globalSettingsTitle,
      children: [
        // ── 第一组：外观 & 通知 ──
        settingCard(context, [
          _WideSettingRow(
            label: context.l10n.darkMode,
            trailing: Switch(
              value: appState.isDarkMode,
              onChanged: (v) => appState.updateDarkMode(v),
              activeThumbColor: const Color(0xFF4ECDC4),
            ),
          ),
          _WideSettingRow(
            label: context.l10n.languageSettingLabel,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _localeModeLabel(context, appState.localeMode),
                  style: const TextStyle(color: kHint, fontSize: 13),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, color: kHint, size: 18),
              ],
            ),
            onTap: () => _showLanguagePicker(context, appState),
          ),
          _WideSettingRow(
            label: context.l10n.dateFormatSettingLabel,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _datePatternLabel(context, appState.dateFormatPattern),
                  style: const TextStyle(color: kHint, fontSize: 13),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, color: kHint, size: 18),
              ],
            ),
            onTap: () => _showDateFormatPicker(context, appState),
          ),
          _WideSettingRow(
            label: context.l10n.courseReminder,
            trailing: Switch(
              value: _notification,
              onChanged: (v) => _showWip(context),
              activeThumbColor: const Color(0xFF4ECDC4),
            ),
          ),
          _WideSettingRow(
            label: context.l10n.widgetSync,
            showDivider: false,
            trailing: Switch(
              value: _widgetSync,
              onChanged: (v) => _showWip(context),
              activeThumbColor: const Color(0xFF4ECDC4),
            ),
          ),
        ]),

        const SizedBox(height: 28),

        // ── 第二组：背景格式 ──
        settingCard(context, [
          _WideSettingRow(
            label: context.l10n.setBackgroundFormat,
            showDivider: false,
            onTap: () => _showWip(context),
            trailing: const Icon(Icons.chevron_right, color: kHint, size: 18),
          ),
        ]),

        const SizedBox(height: 28),

        // ── 第三组：使用帮助 ──
        settingCard(context, [
          _WideSettingRow(
            label: context.l10n.helpUsage,
            showDivider: false,
            trailing: const Icon(Icons.open_in_new, color: kHint, size: 16),
            onTap: () async {
              final uri = Uri.parse(
                'https://blog.lucas04.top/docs/stayup-schedule',
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

/// 行高更大的 SettingRow，vertical padding 从 14 加大到 20
class _WideSettingRow extends StatelessWidget {
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;

  const _WideSettingRow({
    required this.label,
    this.trailing,
    this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = ac(context);
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        children: [
          Text(label,
              style: TextStyle(color: colors.primaryText, fontSize: 15)),
          const Spacer(),
          onTap != null
              ? IgnorePointer(
                  child: trailing ??
                      Icon(Icons.chevron_right, color: colors.hint, size: 18),
                )
              : (trailing ??
                  Icon(Icons.chevron_right, color: colors.hint, size: 18)),
        ],
      ),
    );

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: content,
        ),
        if (showDivider)
          Container(
            height: 0.5,
            color: colors.divider,
            margin: const EdgeInsets.only(left: 16),
          ),
      ],
    );
  }
}
