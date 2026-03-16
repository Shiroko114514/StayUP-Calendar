
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../common_widgets.dart';
import '../l10n.dart';
import '../models.dart';
import 'crawler/hust.dart';
import 'widgets/school_importers.dart';

part 'widgets/school_import_widgets.dart';

class _SchoolEntry {
  final String id;
  final String pinyin;
  const _SchoolEntry({required this.id, required this.pinyin});
}

final Map<String, SchoolImporter> kSchoolImporters = {
  'hust': HustImporter(),
};

// ══════════════════════════════════════════════════════════
// 学校列表页
// ══════════════════════════════════════════════════════════
class SchoolImportPage extends StatefulWidget {
  const SchoolImportPage({super.key});
  @override
  State<SchoolImportPage> createState() => _SchoolImportPageState();
}

class _SchoolImportPageState extends State<SchoolImportPage> {
  static List<_SchoolEntry> get _allSchools => kSchoolImporters.entries
      .map((e) => _SchoolEntry(id: e.key, pinyin: e.value.pinyin))
      .toList();

  String _schoolName(BuildContext context, String id) {
    final importer = kSchoolImporters[id];
    return importer?.displayName(context) ?? id.toUpperCase();
  }

  static Map<String, List<_SchoolEntry>> get _grouped {
    final map = <String, List<_SchoolEntry>>{};
    for (final s in _allSchools) {
      map.putIfAbsent(s.pinyin, () => []).add(s);
    }
    return map;
  }

  static List<String> get _letters => _grouped.keys.toList()..sort();

  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final WebViewCookieManager _cookieManager = WebViewCookieManager();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() => _query = _searchCtrl.text.trim()));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  List<_SchoolEntry> get _filtered {
    if (_query.isEmpty) return _allSchools;
    return _allSchools.where((s) => _schoolName(context, s.id).contains(_query)).toList();
  }

  Map<String, List<_SchoolEntry>> get _filteredGrouped {
    final map = <String, List<_SchoolEntry>>{};
    for (final s in _filtered) {
      map.putIfAbsent(s.pinyin, () => []).add(s);
    }
    return map;
  }

  List<String> get _filteredLetters => _filteredGrouped.keys.toList()..sort();

  void _jumpToLetter(String letter) {
    final grouped = _filteredGrouped;
    final letters = _filteredLetters;
    if (!letters.contains(letter)) return;
    double offset = 0;
    for (final l in letters) {
      if (l == letter) break;
      offset += 36 + grouped[l]!.length * 56.0;
    }
    _scrollCtrl.animateTo(
      offset.clamp(0, _scrollCtrl.position.maxScrollExtent),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<void> _confirmResetLogin() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ac(context).card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          context.l10n.schoolImportResetLoginTitle,
          style: TextStyle(
            color: ac(context).primaryText,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          context.l10n.schoolImportResetLoginMessage,
          style: TextStyle(color: ac(context).hint, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              context.l10n.cancelAction,
              style: TextStyle(color: ac(context).hint, fontSize: 15),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              context.l10n.schoolImportResetLoginAction,
              style: const TextStyle(
                color: Color(0xFFFF3B5C),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    await _clearCookiesAndResetSessions();
  }

  Future<void> _clearCookiesAndResetSessions() async {
    FocusScope.of(context).unfocus();
    try {
      for (final importer in kSchoolImporters.values) {
        importer.resetSession();
      }
      await _cookieManager.clearCookies();
      if (!mounted) return;
      await showAppToast(context, context.l10n.schoolImportResetLoginSuccess);
    } catch (error) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: ac(context).card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text(
            context.l10n.schoolImportErrorTitle,
            style: TextStyle(color: ac(context).primaryText, fontSize: 16),
          ),
          content: Text(
            context.l10n.schoolImportResetLoginFailed(error),
            style: TextStyle(color: ac(context).hint, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                context.l10n.confirmAction,
                style: const TextStyle(color: Color(0xFFFF3B5C)),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _filteredGrouped;
    final letters = _filteredLetters;
    final allLetters = _letters;

    return Scaffold(
      backgroundColor: ac(context).bg,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Text(context.l10n.backAction,
                      style: const TextStyle(color: Color(0xFFFF3B5C), fontSize: 16)),
                ),
              ),
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: ac(context).card,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    style: TextStyle(color: ac(context).primaryText, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: context.l10n.searchSchoolHint,
                      hintStyle: TextStyle(color: ac(context).hint, fontSize: 15),
                      prefixIcon: Icon(Icons.search, color: ac(context).hint, size: 20),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                onPressed: _confirmResetLogin,
                tooltip: context.l10n.schoolImportResetLoginAction,
                icon: const Icon(Icons.delete_outline_rounded),
                color: const Color(0xFFFF3B5C),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Text(context.l10n.schoolImportTip,
                style: TextStyle(color: ac(context).hint, fontSize: 13)),
          ),
          Expanded(
            child: Stack(children: [
              ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.only(right: 28, bottom: 20),
                itemCount: letters.fold<int>(0, (s, l) => s + 1 + grouped[l]!.length) + 1,
                itemBuilder: (context, index) {
                  final total = letters.fold<int>(0, (s, l) => s + 1 + grouped[l]!.length);
                  if (index == total) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                      child: Text(context.l10n.schoolImportMoreSchools,
                          style: TextStyle(color: ac(context).hint, fontSize: 13),
                          textAlign: TextAlign.center),
                    );
                  }
                  int cursor = 0;
                  for (final letter in letters) {
                    if (index == cursor) return _SectionHeader(letter: letter);
                    cursor++;
                    final items = grouped[letter]!;
                    if (index < cursor + items.length) {
                      final itemIdx = index - cursor;
                      final entry = items[itemIdx];
                      final name = _schoolName(context, entry.id);
                      return _SchoolRow(
                        name: name,
                        showDivider: itemIdx != items.length - 1,
                        onTap: () {
                          final importer = kSchoolImporters[entry.id]!;
                          Navigator.push(context, MaterialPageRoute(
                            builder: (_) => _SchoolWebViewPage(
                              title: name,
                              importer: importer,
                            ),
                          ));
                        },
                      );
                    }
                    cursor += items.length;
                  }
                  return const SizedBox.shrink();
                },
              ),
              Positioned(
                right: 0, top: 0, bottom: 0,
                child: _AlphaIndexBar(letters: allLetters, onLetterTap: _jumpToLetter),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// 内建浏览器页面
// ══════════════════════════════════════════════════════════
class _SchoolWebViewPage extends StatefulWidget {
  final String title;
  final SchoolImporter importer;
  const _SchoolWebViewPage({required this.title, required this.importer});

  @override
  State<_SchoolWebViewPage> createState() => _SchoolWebViewPageState();
}

class _SchoolWebViewPageState extends State<_SchoolWebViewPage> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _crawling = false;
  String _currentUrl = '';

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.importer.webUrl;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) '
        'AppleWebKit/537.36 (KHTML, like Gecko) '
        'Chrome/120.0.0.0 Safari/537.36',
      )
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) => setState(() {
          _loading = true;
          _currentUrl = url;
        }),
        onPageFinished: (url) => setState(() {
          _loading = false;
          _currentUrl = url;
        }),
      ))
      ..loadRequest(Uri.parse(widget.importer.webUrl));

    WidgetsBinding.instance.addPostFrameCallback((_) => _showNotice());
  }

  void _showNotice() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: ac(context).card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(context.l10n.schoolImportNoticeTitle,
            style: TextStyle(
                color: ac(context).primaryText,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        content: Text(widget.importer.noticeText(context),
            style: TextStyle(
                color: ac(context).hint, fontSize: 14, height: 1.6)),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (widget.importer is HustImporter) {
                await _prepareHustTermAfterNotice(widget.importer as HustImporter);
              }
            },
          child: Text(context.l10n.okAction,
                style: TextStyle(
                    color: Color(0xFFFF3B5C),
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> _prepareHustTermAfterNotice(HustImporter importer) async {
    if (!mounted) return;
    setState(() => _loading = true);

    await importer.prepareTermAndLoad(
      context,
      _controller,
      _showError,
    );

    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _startCrawl() async {
    setState(() => _crawling = true);
    final appState = AppStateScope.of(context);
    final courses = await widget.importer.onPageLoaded(
      context,
      _controller,
      appState,
      (e) {
        setState(() => _crawling = false);
        _showError(e);
      },
    );
    setState(() => _crawling = false);
    if (courses != null && courses.isNotEmpty) {
      _showConfirmDialog(courses);
    }
  }

  Future<void> _refreshCurrentPage() async {
    if (!mounted) return;
    setState(() => _loading = true);
    await _controller.reload();
  }

  void _showConfirmDialog(List<Course> courses) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ac(context).card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(context.l10n.schoolImportParseDoneTitle,
            style: TextStyle(
                color: ac(context).primaryText,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(context.l10n.schoolImportParseDoneMessage(courses.length),
                style: TextStyle(
                    color: ac(context).hint, fontSize: 14, height: 1.5)),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: courses.length,
                separatorBuilder: (_, _) =>
                    Divider(height: 1, color: ac(context).divider),
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(children: [
                    Container(
                      width: 10, height: 10,
                      decoration: BoxDecoration(
                          color: courses[i].effectiveColor,
                          shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(courses[i].name,
                          style: TextStyle(
                              color: ac(context).primaryText, fontSize: 14),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ]),
                ),
              ),
            ),
          ]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.cancelAction,
                style: TextStyle(color: ac(context).hint, fontSize: 15)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _importCourses(courses);
            },
            child: Text(context.l10n.schoolImportAction,
                style: TextStyle(
                    color: Color(0xFFFF3B5C),
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _importCourses(List<Course> courses) {
    final appState = AppStateScope.of(context);
    final cfg = ScheduleConfig(
      name: widget.importer.newScheduleName(context),
      firstWeekDay: appState.config.firstWeekDay,
      sectionsPerDay: appState.config.sectionsPerDay,
      totalWeeks: appState.config.totalWeeks,
    );
    appState.addSchedule(cfg);
    appState.switchSchedule(appState.allConfigs.length - 1);
    appState.replaceCourses(courses);

    showAppToast(context, context.l10n.schoolImportSuccess(courses.length));

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _showError(String msg) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ac(context).card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(context.l10n.schoolImportErrorTitle,
            style: TextStyle(color: ac(context).primaryText, fontSize: 16)),
        content: Text(msg,
            style: TextStyle(color: ac(context).hint, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
          child: Text(context.l10n.confirmAction,
                style: TextStyle(color: Color(0xFFFF3B5C))),
          ),
        ],
      ),
    );
  }

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
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(width: 8),
            const Icon(Icons.arrow_back_ios, color: Color(0xFFFF3B5C), size: 17),
            Text(context.l10n.backAction,
                style: const TextStyle(color: Color(0xFFFF3B5C), fontSize: 15)),
          ]),
        ),
        leadingWidth: 64,
        title: Text(widget.title,
            style: TextStyle(
                color: ac(context).primaryText,
                fontSize: 17,
                fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _refreshCurrentPage,
            tooltip: MaterialLocalizations.of(context).refreshIndicatorSemanticLabel,
            icon: const Icon(Icons.refresh_rounded),
            color: const Color(0xFFFF3B5C),
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: double.infinity,
              color: ac(context).bg,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: ac(context).card,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _currentUrl,
                  style: TextStyle(color: ac(context).hint, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Container(height: 0.5, color: ac(context).divider),
          ]),
        ),
      ),
      body: Stack(children: [
        WebViewWidget(controller: _controller),
        if (_loading)
          const Center(child: CircularProgressIndicator(
              color: Color(0xFFFF3B5C), strokeWidth: 2)),
      ]),
      floatingActionButton: _loading ? null : FloatingActionButton.extended(
        onPressed: _crawling ? null : _startCrawl,
        backgroundColor: const Color(0xFFFF3B5C),
        icon: _crawling
            ? const SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.download_rounded, color: Colors.white),
        label: Text(
          _crawling
              ? context.l10n.schoolImportParsing
              : context.l10n.schoolImportScheduleAction,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}