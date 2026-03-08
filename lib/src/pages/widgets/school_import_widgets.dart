part of '../school_import_page.dart';

class _SectionHeader extends StatelessWidget {
  final String letter;
  const _SectionHeader({required this.letter});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
    child: Text(
      letter,
      style: const TextStyle(
        color: Color(0xFF6C6C70),
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class _SchoolRow extends StatelessWidget {
  final String name;
  final bool showDivider;
  final VoidCallback onTap;
  const _SchoolRow({required this.name, required this.showDivider, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(color: Color(0xFF1C1C1E), fontSize: 16),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFFD1D1D6), size: 20),
                ],
              ),
            ),
            if (showDivider)
              const Divider(height: 1, indent: 16, endIndent: 0, color: Color(0xFFE5E5EA)),
          ],
        ),
      ),
    );
  }
}

class _AlphaIndexBar extends StatelessWidget {
  final List<String> letters;
  final ValueChanged<String> onLetterTap;
  const _AlphaIndexBar({required this.letters, required this.onLetterTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: letters
            .map(
              (l) => GestureDetector(
                onTap: () => onLetterTap(l),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    l,
                    style: const TextStyle(
                      color: Color(0xFF6C6C70),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
