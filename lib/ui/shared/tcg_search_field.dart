import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/tcg_card.dart';
import '../../services/pokemon_tcg_service.dart';
import '../theme/app_theme.dart';

/// A reusable TCG API live-search field with thumbnail suggestions.
///
/// Calls the pokemontcg.io API as the user types (debounced 350 ms).
/// Shows a dropdown with card thumbnails, name, set and rarity.
/// Once a card is selected it displays a selected-card chip with a ×-clear.
///
/// [onSelected]  — fires with the chosen [TcgCard] when the user picks one.
/// [onCleared]   — fires when the user taps × to remove the selection.
/// [hintText]    — placeholder shown in the text field (optional override).
class TcgSearchField extends ConsumerStatefulWidget {
  const TcgSearchField({
    super.key,
    required this.onSelected,
    required this.onCleared,
    this.selectedCard,
    this.hintText = 'Name, set or card number…',
    this.label = 'Search card',
  });

  final TcgCard? selectedCard;
  final ValueChanged<TcgCard> onSelected;
  final VoidCallback onCleared;
  final String hintText;
  final String label;

  @override
  ConsumerState<TcgSearchField> createState() => _TcgSearchFieldState();
}

class _TcgSearchFieldState extends ConsumerState<TcgSearchField> {
  final _ctrl = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  List<TcgCard> _suggestions = [];
  bool _loading = false;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && mounted) {
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) setState(() => _showSuggestions = false);
        });
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    if (value.trim().length < 2) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
        _loading = false;
      });
      return;
    }
    setState(() => _loading = true);
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      final results = await ref
          .read(pokemonTcgServiceProvider)
          .searchCards(value.trim());
      if (mounted) {
        setState(() {
          _suggestions = results;
          _loading = false;
          _showSuggestions = results.isNotEmpty;
        });
      }
    });
  }

  void _selectCard(TcgCard card) {
    _ctrl.text = card.displayLabel;
    setState(() => _showSuggestions = false);
    _focusNode.unfocus();
    widget.onSelected(card);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedCard != null) {
      return _SelectedCardChip(
        card: widget.selectedCard!,
        onClear: () {
          _ctrl.clear();
          setState(() {
            _suggestions = [];
            _showSuggestions = false;
          });
          widget.onCleared();
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: _ctrl,
          focusNode: _focusNode,
          onChanged: _onChanged,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hintText,
            labelStyle: const TextStyle(
                color: AppColors.textSecondary, fontSize: 13),
            hintStyle: const TextStyle(
                color: AppColors.textDisabled, fontSize: 14),
            filled: true,
            fillColor: AppColors.surface,
            prefixIcon: _loading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.accent),
                    ),
                  )
                : const Icon(Icons.search_rounded,
                    color: AppColors.textSecondary, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.accent, width: 1.5),
            ),
          ),
        ),
        if (_showSuggestions)
          _SuggestionsList(
            suggestions: _suggestions,
            onTap: _selectCard,
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Suggestions dropdown
// ---------------------------------------------------------------------------

class _SuggestionsList extends StatelessWidget {
  const _SuggestionsList({
    required this.suggestions,
    required this.onTap,
  });

  final List<TcgCard> suggestions;
  final ValueChanged<TcgCard> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: suggestions.length,
          separatorBuilder: (_, __) => const Divider(
            height: 1,
            color: AppColors.border,
            indent: 12,
            endIndent: 12,
          ),
          itemBuilder: (context, i) {
            final card = suggestions[i];
            return InkWell(
              onTap: () => onTap(card),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    _CardThumbnail(url: card.smallImageUrl),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            card.name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${card.setName}  ·  #${card.number}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          if (card.rarity != null &&
                              card.rarity!.isNotEmpty)
                            Text(
                              card.rarity!,
                              style: const TextStyle(
                                color: AppColors.textDisabled,
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Selected card chip
// ---------------------------------------------------------------------------

class _SelectedCardChip extends StatelessWidget {
  const _SelectedCardChip({required this.card, required this.onClear});

  final TcgCard card;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          _CardThumbnail(url: card.smallImageUrl, width: 42, height: 58),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${card.setName}  ·  #${card.number}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                if (card.rarity != null && card.rarity!.isNotEmpty)
                  Text(
                    card.rarity!,
                    style: const TextStyle(
                      color: AppColors.textDisabled,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClear,
            icon: const Icon(Icons.close_rounded,
                color: AppColors.textDisabled, size: 20),
            tooltip: 'Change card',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared thumbnail
// ---------------------------------------------------------------------------

class _CardThumbnail extends StatelessWidget {
  const _CardThumbnail({
    required this.url,
    this.width = 36,
    this.height = 50,
  });

  final String url;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: url.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: url,
              width: width,
              height: height,
              fit: BoxFit.cover,
              placeholder: (_, __) => _placeholder(),
              errorWidget: (_, __, ___) => _placeholder(),
            )
          : _placeholder(),
    );
  }

  Widget _placeholder() => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(Icons.style_rounded,
            size: 16, color: AppColors.textDisabled),
      );
}
