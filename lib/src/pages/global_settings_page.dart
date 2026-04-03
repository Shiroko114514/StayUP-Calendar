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
  // BottomSheet 中“自定义日期格式”这一项的哨兵值。
  static const String _customDateFormatOption = '__custom_date_format_option__';

  final bool _notification = false;
  final bool _widgetSync = false;
  bool _isExitingForLocaleChange = false;

  void _showRestartAndExitNotice(BuildContext context) {
    // 语言切换后当前页面可能仍保留旧文案，统一提示并退出以重启生效。
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

  String _themeModeLabel(BuildContext context, String mode) {
    final l10n = context.l10n;
    switch (mode) {
      case kThemeModeLight:
        return l10n.themeModeLight;
      case kThemeModeDark:
        return l10n.themeModeDark;
      default:
        return l10n.themeModeFollowSystem;
    }
  }

  String _datePatternLabel(BuildContext context, String pattern) {
    // 在候选项中同时显示格式串和示例，便于用户直观看到效果。
    final sample = _datePatternSample(pattern);
    if (sample == null) return pattern;
    return '$pattern  ($sample)';
  }

  String? _datePatternSample(String pattern) {
    try {
      return DateFormat(pattern).format(DateTime.now());
    } catch (_) {
      return null;
    }
  }

  bool _isPresetDatePattern(String pattern) {
    const presets = {
      kDateFormatYmdSlash,
      kDateFormatYmdDash,
      kDateFormatMdySlash,
      kDateFormatDmySlash,
      kDateFormatDMonY,
      kDateFormatMonDY,
    };
    return presets.contains(pattern);
  }

  bool _isValidDatePattern(String pattern) {
    final trimmed = pattern.trim();
    if (trimmed.isEmpty) return false;
    return _datePatternSample(trimmed) != null;
  }

  Future<void> _showCustomDateFormatDialog(
    BuildContext context,
    AppState appState,
  ) async {
    final l10n = context.l10n;
    final isCurrentCustom = !_isPresetDatePattern(appState.dateFormatPattern);
    final controller = TextEditingController(
      text: isCurrentCustom ? appState.dateFormatPattern : '',
    );
    String? errorText;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: ac(ctx).card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text(
            l10n.dateFormatCustomDialogTitle,
            style: TextStyle(
              color: ac(ctx).primaryText,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.dateFormatCustomDialogHelper,
                style: const TextStyle(color: kHint, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                style: TextStyle(color: ac(ctx).primaryText),
                decoration: InputDecoration(
                  hintText: l10n.dateFormatCustomDialogHint,
                  hintStyle: const TextStyle(color: kHint),
                  errorText: errorText,
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: kAccent),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: kAccent, width: 2),
                  ),
                ),
                onChanged: (_) {
                  if (errorText != null) {
                    setS(() => errorText = null);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancelAction, style: const TextStyle(color: kHint)),
            ),
            TextButton(
              onPressed: () {
                final input = controller.text.trim();
                if (input.isEmpty) {
                  setS(() => errorText = l10n.dateFormatCustomDialogEmpty);
                  return;
                }
                if (!_isValidDatePattern(input)) {
                  setS(() => errorText = l10n.dateFormatCustomDialogInvalid);
                  return;
                }
                appState.updateDateFormatPattern(input);
                Navigator.pop(ctx);
              },
              child: Text(
                l10n.saveAction,
                style: const TextStyle(color: kAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDateFormatPicker(BuildContext context, AppState appState) {
    // 预设格式 + 自定义入口共用一个选择面板。
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
          kDateFormatDMonY,
          kDateFormatMonDY,
          _customDateFormatOption,
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
                (pattern) {
                  final isCustomOption = pattern == _customDateFormatOption;
                  final isSelected = isCustomOption
                      ? !_isPresetDatePattern(appState.dateFormatPattern)
                      : pattern == appState.dateFormatPattern;

                  final label = isCustomOption
                      ? context.l10n.dateFormatCustomOptionLabel
                      : _datePatternLabel(context, pattern);

                  return GestureDetector(
                  onTap: () {
                    if (isCustomOption) {
                      Navigator.pop(context);
                      _showCustomDateFormatDialog(context, appState);
                      return;
                    }
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
                          label,
                          style: TextStyle(
                            color: isSelected
                                ? const Color(0xFF4ECDC4)
                                : ac(context).primaryText,
                            fontSize: 15,
                          ),
                        ),
                        const Spacer(),
                        if (isSelected)
                          const Icon(
                            Icons.check,
                            color: Color(0xFF4ECDC4),
                            size: 18,
                          ),
                      ],
                    ),
                  ),
                  );
                },
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
                    // 切换语言后提示重启，避免局部缓存文案造成体验不一致。
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

  void _showThemeModePicker(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ac(context).card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        final options = [
          kThemeModeSystem,
          kThemeModeLight,
          kThemeModeDark,
        ];
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.darkMode,
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
                    appState.updateThemeMode(mode);
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
                          _themeModeLabel(context, mode),
                          style: TextStyle(
                            color: mode == appState.themeMode
                                ? const Color(0xFF4ECDC4)
                                : ac(context).primaryText,
                            fontSize: 15,
                          ),
                        ),
                        const Spacer(),
                        if (mode == appState.themeMode)
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
        // ── 第一组：主题、语言、日期显示格式 ──
        settingCard(context, [
          _WideSettingRow(
            label: context.l10n.darkMode,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _themeModeLabel(context, appState.themeMode),
                  style: const TextStyle(color: kHint, fontSize: 13),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, color: kHint, size: 18),
              ],
            ),
            onTap: () => _showThemeModePicker(context, appState),
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
        ]),

        const SizedBox(height: 28),

        settingCard(context, [
          _WideSettingRow(
            label: context.l10n.courseReminder,
            trailing: Transform.scale(
              scale: 0.92,
              child: Switch(
                value: _notification,
                onChanged: (v) => _showWip(context),
                activeThumbColor: const Color(0xFF4ECDC4),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          _WideSettingRow(
            label: context.l10n.widgetSync,
            showDivider: false,
            trailing: Transform.scale(
              scale: 0.92,
              child: Switch(
                value: _widgetSync,
                onChanged: (v) => _showWip(context),
                activeThumbColor: const Color(0xFF4ECDC4),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
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
                'https://blog.lucas04.top/docs/stayup-schedule/usage-guide/',
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

/// 固定高度的 SettingRow，保证各项视觉高度一致
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
    final content = SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
      ],
    );
  }
}
