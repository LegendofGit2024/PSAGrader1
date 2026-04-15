import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../models/binder.dart';
import '../../models/card.dart';
import '../../models/collection_item.dart';
import '../../models/tcg_card.dart';
import '../../providers/collection_provider.dart' show bindersProvider;
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/pokemon_tcg_service.dart';
import '../theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Add Item Screen
// ---------------------------------------------------------------------------

class AddItemScreen extends ConsumerStatefulWidget {
  const AddItemScreen({super.key, this.preselectedBinderId, this.preselectedSlot});

  /// Pre-fill binder + slot when tapping an empty binder slot
  final String? preselectedBinderId;
  final int? preselectedSlot;

  @override
  ConsumerState<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends ConsumerState<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _costCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _certCtrl = TextEditingController();
  final _labelColorCtrl = TextEditingController();
  final _centeringCtrl = TextEditingController();
  final _cornersCtrl = TextEditingController();
  final _edgesCtrl = TextEditingController();
  final _surfaceCtrl = TextEditingController();

  TcgCard? _selectedCard;
  String _printVariant = 'Normal';
  ConditionType _conditionType = ConditionType.raw;
  RawCondition _rawCondition = RawCondition.nm;
  Grader _grader = Grader.psa;
  double _grade = 10;
  String? _selectedBinderId;
  bool _submitting = false;

  static const _printVariants = [
    'Normal',
    'Reverse Holo',
    'Holo',
    'Full Art',
    'Alt Art',
    'Secret Rare',
    'Promo',
    'Gold',
  ];

  @override
  void initState() {
    super.initState();
    _selectedBinderId = widget.preselectedBinderId;
    if (widget.preselectedSlot != null && widget.preselectedBinderId != null) {
      _locationCtrl.text =
          'Binder, Page ${widget.preselectedSlot! ~/ 9 + 1}, Slot ${widget.preselectedSlot! % 9 + 1}';
    }
  }

  @override
  void dispose() {
    for (final c in [
      _costCtrl, _locationCtrl, _certCtrl,
      _labelColorCtrl, _centeringCtrl, _cornersCtrl, _edgesCtrl, _surfaceCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _hasSubgrades =>
      _grader == Grader.bgs || _grader == Grader.cgc;

  Subgrades? _buildSubgrades() {
    if (!_hasSubgrades) return null;
    final c = double.tryParse(_centeringCtrl.text);
    final co = double.tryParse(_cornersCtrl.text);
    final e = double.tryParse(_edgesCtrl.text);
    final s = double.tryParse(_surfaceCtrl.text);
    if (c == null || co == null || e == null || s == null) return null;
    return Subgrades(centering: c, corners: co, edges: e, surface: s);
  }

  Future<void> _submit() async {
    if (_selectedCard == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please search and select a card first.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    // Read all providers BEFORE any await — Riverpod 3 disallows ref.read
    // after an async gap on auto-dispose providers.
    final uid = ref.read(currentUidProvider);
    final db  = ref.read(firestoreServiceProvider);

    try {
      // 1. Upsert the card into /cards so resolvedCardProvider can find it.
      //    merge:true means existing pricing rows are never overwritten.
      final cardDoc = CardDocument(
        id: _selectedCard!.id,
        meta: CardMeta(
          name: _selectedCard!.name,
          setId: _selectedCard!.setId,
          setNumber: _selectedCard!.number,
          language: CardLanguage.en,
          variant: _printVariant,
          imageUrl: _selectedCard!.largeImageUrl ?? _selectedCard!.smallImageUrl,
        ),
        pricing: const CardPricing(),
      );
      await db.upsertCard(cardDoc);

      // 2. Build the collection item and write it directly via the service.
      DocumentReference? binderRef;
      if (_selectedBinderId != null) {
        binderRef = FirebaseFirestore.instance
            .collection('binders')
            .doc(_selectedBinderId);
      }

      final locationTag = _locationCtrl.text.trim().isEmpty
          ? 'Unorganized'
          : _locationCtrl.text.trim();

      final condition = _conditionType == ConditionType.raw
          ? ItemCondition(type: ConditionType.raw, rawCondition: _rawCondition)
          : ItemCondition(
              type: ConditionType.slab,
              slab: SlabCondition(
                grader: _grader,
                certNumber: _certCtrl.text.trim(),
                grade: _grade,
                labelColor: _labelColorCtrl.text.trim().isEmpty
                    ? null
                    : _labelColorCtrl.text.trim(),
                subgrades: _buildSubgrades(),
              ),
            );

      final item = CollectionItem(
        id: '',
        cardRef: FirebaseFirestore.instance
            .collection('cards')
            .doc(_selectedCard!.id),
        acquisition: Acquisition(
          costBasis: double.parse(_costCtrl.text),
          acquiredDate: DateTime.now(),
        ),
        condition: condition,
        location: ItemLocation(
          locationTag: locationTag,
          binderId: binderRef,
          slotIndex: widget.preselectedSlot,
        ),
        flags: const ItemFlags(),
      );

      await db.addItem(uid, item);

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Add Card'),
        actions: [
          if (_submitting)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            TextButton(
              onPressed: _submit,
              child: const Text('Save',
                  style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 16)),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          children: [
            // ── Card search ────────────────────────────────────────────────
            _SectionLabel('Card'),
            _CardSearchField(
              selectedCard: _selectedCard,
              onSelected: (card) => setState(() {
                _selectedCard = card;
                // Pre-select variant hint from TCG subtypes if possible
                if (card.subtypes.any((s) =>
                    s.toLowerCase().contains('v') ||
                    s.toLowerCase().contains('ex') ||
                    s.toLowerCase().contains('gx'))) {
                  _printVariant = 'Normal';
                }
              }),
              onCleared: () => setState(() {
                _selectedCard = null;
                _printVariant = 'Normal';
              }),
            ),

            // ── Print / Variant ────────────────────────────────────────────
            if (_selectedCard != null) ...[
              const SizedBox(height: 16),
              _SectionLabel('Print / Variant'),
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _printVariants.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final v = _printVariants[i];
                    final active = _printVariant == v;
                    return GestureDetector(
                      onTap: () => setState(() => _printVariant = v),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.accent
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: active
                                  ? AppColors.accent
                                  : AppColors.border),
                        ),
                        child: Text(
                          v,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: active
                                ? AppColors.background
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 20),

            // ── Acquisition ────────────────────────────────────────────────
            _SectionLabel('Acquisition'),
            _Field(
              controller: _costCtrl,
              label: 'Cost Basis (USD)',
              hint: '0.00',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
              ],
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (double.tryParse(v) == null) return 'Invalid number';
                return null;
              },
            ),
            const SizedBox(height: 20),

            // ── Condition ──────────────────────────────────────────────────
            _SectionLabel('Condition'),
            _SegmentedPicker<ConditionType>(
              values: ConditionType.values,
              selected: _conditionType,
              labelOf: (t) => t.name.toUpperCase(),
              onChanged: (t) => setState(() => _conditionType = t),
            ),
            const SizedBox(height: 12),

            if (_conditionType == ConditionType.raw) ...[
              _SegmentedPicker<RawCondition>(
                values: RawCondition.values,
                selected: _rawCondition,
                labelOf: (c) => c.name.toUpperCase(),
                onChanged: (c) => setState(() => _rawCondition = c),
              ),
            ] else ...[
              // Grader
              _DropdownField<Grader>(
                label: 'Grader',
                value: _grader,
                items: Grader.values,
                labelOf: (g) => g.name.toUpperCase(),
                onChanged: (g) => setState(() => _grader = g),
              ),
              const SizedBox(height: 12),

              // Grade slider
              Row(
                children: [
                  const Text('Grade',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13)),
                  const Spacer(),
                  Text(
                    _grade == _grade.truncateToDouble()
                        ? _grade.toInt().toString()
                        : _grade.toString(),
                    style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 20,
                        fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              Slider(
                value: _grade,
                min: 1,
                max: 10,
                divisions: 18,
                activeColor: AppColors.accent,
                inactiveColor: AppColors.surface,
                onChanged: (v) => setState(() => _grade = v),
              ),
              const SizedBox(height: 12),

              // Cert number
              _Field(
                controller: _certCtrl,
                label: 'Cert Number',
                hint: '12345678',
              ),
              const SizedBox(height: 12),

              // ACE label color
              if (_grader == Grader.ace) ...[
                _Field(
                  controller: _labelColorCtrl,
                  label: 'Label Color (hex, e.g. #334155)',
                  hint: '#334155',
                ),
                const SizedBox(height: 12),
              ],

              // BGS/CGC subgrades
              if (_hasSubgrades) ...[
                _SectionLabel('Subgrades'),
                Row(
                  children: [
                    _MiniField(controller: _centeringCtrl, label: 'Ctr'),
                    _MiniField(controller: _cornersCtrl, label: 'Cor'),
                    _MiniField(controller: _edgesCtrl, label: 'Edg'),
                    _MiniField(controller: _surfaceCtrl, label: 'Sur'),
                  ],
                ),
              ],
            ],
            const SizedBox(height: 20),

            // ── Location ───────────────────────────────────────────────────
            _SectionLabel('Location'),
            _BinderDropdown(
              binderId: _selectedBinderId,
              onChanged: (id) => setState(() => _selectedBinderId = id),
            ),
            const SizedBox(height: 12),
            _Field(
              controller: _locationCtrl,
              label: 'Location Tag',
              hint: 'Binder A, Page 1, Slot 3',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card search widget
// ---------------------------------------------------------------------------

class _CardSearchField extends ConsumerStatefulWidget {
  const _CardSearchField({
    required this.selectedCard,
    required this.onSelected,
    required this.onCleared,
  });

  final TcgCard? selectedCard;
  final ValueChanged<TcgCard> onSelected;
  final VoidCallback onCleared;

  @override
  ConsumerState<_CardSearchField> createState() => _CardSearchFieldState();
}

class _CardSearchFieldState extends ConsumerState<_CardSearchField> {
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
        // Small delay so tapping a suggestion registers before hiding the list
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
    // If a card is already selected, show a chip instead of the search field
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
      children: [
        TextFormField(
          controller: _ctrl,
          focusNode: _focusNode,
          onChanged: _onChanged,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
          decoration: InputDecoration(
            labelText: 'Search card',
            hintText: 'Name, set or card number…',
            labelStyle:
                const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            hintStyle:
                const TextStyle(color: AppColors.textDisabled, fontSize: 14),
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
        if (_showSuggestions) _SuggestionsList(
          suggestions: _suggestions,
          onTap: _selectCard,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Suggestion drop-down list
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
              endIndent: 12),
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
                          if (card.rarity != null && card.rarity!.isNotEmpty)
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
// Selected card chip (shown after a card is picked)
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
// Shared thumbnail widget
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
        color: AppColors.border,
        child: const Icon(Icons.style_rounded,
            size: 16, color: AppColors.textDisabled),
      );
}

// ---------------------------------------------------------------------------
// Binder dropdown
// ---------------------------------------------------------------------------

class _BinderDropdown extends ConsumerWidget {
  const _BinderDropdown({required this.binderId, required this.onChanged});
  final String? binderId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(bindersProvider);
    final binders = async.asData?.value ?? [];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButton<String?>(
        value: binderId,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        dropdownColor: AppColors.surface,
        hint: const Text('No binder (unorganized)',
            style: TextStyle(color: AppColors.textDisabled, fontSize: 14)),
        items: [
          const DropdownMenuItem(
            value: null,
            child: Text('No binder',
                style:
                    TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          ),
          ...binders.map((b) => DropdownMenuItem(
                value: b.id,
                child: Text(b.name,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 14)),
              )),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared form widgets
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.textDisabled,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle:
            const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        hintStyle:
            const TextStyle(color: AppColors.textDisabled, fontSize: 14),
        filled: true,
        fillColor: AppColors.surface,
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
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
      ),
    );
  }
}

class _MiniField extends StatelessWidget {
  const _MiniField({required this.controller, required this.label});
  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: TextFormField(
          controller: controller,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          style:
              const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(
                color: AppColors.textSecondary, fontSize: 11),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: AppColors.accent, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ),
    );
  }
}

class _SegmentedPicker<T> extends StatelessWidget {
  const _SegmentedPicker({
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
  });
  final List<T> values;
  final T selected;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: values
            .map((v) => Expanded(
                  child: GestureDetector(
                    onTap: () => onChanged(v),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected == v
                            ? AppColors.accent
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Text(
                        labelOf(v),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: selected == v
                              ? AppColors.background
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.labelOf,
    required this.onChanged,
  });
  final String label;
  final T value;
  final List<T> items;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
          const Spacer(),
          DropdownButton<T>(
            value: value,
            underline: const SizedBox.shrink(),
            dropdownColor: AppColors.surface,
            items: items
                .map((i) => DropdownMenuItem(
                      value: i,
                      child: Text(labelOf(i),
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600)),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ],
      ),
    );
  }
}
