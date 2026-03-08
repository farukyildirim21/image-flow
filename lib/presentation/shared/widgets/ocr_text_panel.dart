import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:imageflow/app/theme/app_colors.dart';
import 'package:imageflow/app/theme/app_radius.dart';
import 'package:imageflow/app/theme/app_spacing.dart';
import 'package:imageflow/app/theme/app_text_styles.dart';


//OCR Text Extraction panel
//Shows extracted text from document scans
//Copy all text to clipboard
//Search within extracted text with highlight
class OcrTextPanel extends StatefulWidget {
  const OcrTextPanel({super.key, required this.text});

  final String text;

  @override
  State<OcrTextPanel> createState() => _OcrTextPanelState();
}

class _OcrTextPanelState extends State<OcrTextPanel> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String _query = '';
  bool _copied = false;

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _copyAll() async {
    await Clipboard.setData(ClipboardData(text: widget.text));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  String _filtered() {
    if (_query.isEmpty) return widget.text;
    return widget.text
        .split('\n')
        .where((l) => l.toLowerCase().contains(_query.toLowerCase()))
        .join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          //Header 
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.sm, AppSpacing.xs, 0,
            ),
            child: Row(
              children: [
                Text('Extracted Text', style: AppTextStyles.titleSmall),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    _copied ? Icons.check_rounded : Icons.copy_outlined,
                    size: 18,
                    color: _copied
                        ? AppColors.success
                        : AppColors.textMuted,
                  ),
                  onPressed: _copyAll,
                  tooltip: 'Copy all',
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          //Search bar 
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search in text…',
                hintStyle: AppTextStyles.bodyMedium,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                filled: true,
                fillColor: AppColors.bgSecondary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  size: 16,
                  color: AppColors.textMuted,
                ),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 14),
                        color: AppColors.textMuted,
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
              ),
            ),
          ),

          const Divider(
            color: Color.fromRGBO(72, 76, 109, 0.3),
            height: 1,
          ),

          //Text content
          Expanded(
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(AppSpacing.md),
                child: filtered.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Text(
                            'No matches for "$_query"',
                            style: AppTextStyles.labelSmall,
                          ),
                        ),
                      )
                    : _query.isEmpty
                        ? Text(
                            filtered,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          )
                        : _HighlightedText(text: filtered, query: _query),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//Highlighted text 
class _HighlightedText extends StatelessWidget {
  const _HighlightedText({required this.text, required this.query});

  final String text;
  final String query;

  @override
  Widget build(BuildContext context) {
    final spans = <TextSpan>[];
    final lower = text.toLowerCase();
    final lq = query.toLowerCase();
    var start = 0;

    while (start < text.length) {
      final idx = lower.indexOf(lq, start);
      if (idx == -1) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }
      if (idx > start) {
        spans.add(TextSpan(text: text.substring(start, idx)));
      }
      spans.add(TextSpan(
        text: text.substring(idx, idx + query.length),
        style: AppTextStyles.highlight
      ));
      start = idx + query.length;
    }

    return RichText(
      text: TextSpan(
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        children: spans,
      ),
    );
  }
}
