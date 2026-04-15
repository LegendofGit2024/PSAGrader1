import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/card.dart';
import '../../models/collection_item.dart';
import '../../services/auth_service.dart';
import '../../providers/connect_provider.dart';
import '../../providers/collection_provider.dart';
import '../../services/firestore_service.dart';
import '../theme/app_theme.dart';

/// A friend's "Public Cabinet" — same bento feel, midnight-blue tint so you
/// always know you're looking at someone else's assets.
///
/// Accepts a [friendUid] path parameter. Opens directly to vault; if the
/// query param `tab=wishlist` is present, shows the wishlist tab instead.
class FriendVaultScreen extends ConsumerWidget {
  const FriendVaultScreen({
    super.key,
    required this.friendUid,
    this.initialTab = 0,
  });

  final String friendUid;
  final int initialTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      initialIndex: initialTab,
      child: Scaffold(
        backgroundColor: const Color(0xFF0D1525), // midnight-blue tint
        body: _FriendVaultBody(friendUid: friendUid),
      ),
    );
  }
}

class _FriendVaultBody extends ConsumerWidget {
  const _FriendVaultBody({required this.friendUid});
  final String friendUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NestedScrollView(
      headerSliverBuilder: (_, __) => [
        _FriendAppBar(friendUid: friendUid),
      ],
      body: ProviderScope(
        overrides: [
          _friendUidScopeProvider.overrideWithValue(friendUid),
        ],
        child: const TabBarView(
          children: [
            _PublicVaultTab(),
            _WishlistTab(),
            _DnaTab(),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// App bar with friend profile info + tabs
// ---------------------------------------------------------------------------

class _FriendAppBar extends ConsumerWidget {
  const _FriendAppBar({required this.friendUid});
  final String friendUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: const Color(0xFF0D1525),
      foregroundColor: Colors.white70,
      flexibleSpace: FlexibleSpaceBar(
        background: _FriendProfileHeader(friendUid: friendUid),
      ),
      bottom: const TabBar(
        indicatorColor: AppColors.accent,
        labelColor: AppColors.accent,
        unselectedLabelColor: Colors.white38,
        labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        tabs: [
          Tab(text: 'Vault'),
          Tab(text: 'Wishlist'),
          Tab(text: 'Compare'),
        ],
      ),
    );
  }
}

class _FriendProfileHeader extends ConsumerWidget {
  const _FriendProfileHeader({required this.friendUid});
  final String friendUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(friendUid)
          .get(),
      builder: (_, snap) {
        final data = snap.data?.data() as Map<String, dynamic>? ?? {};
        final name = data['displayName'] as String? ?? 'User';
        final avatar = data['avatarUrl'] as String?;

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0D1525), Color(0xFF162038)],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 52, 20, 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor:
                    AppColors.accentSoft.withOpacity(0.2),
                backgroundImage: avatar != null && avatar.isNotEmpty
                    ? NetworkImage(avatar)
                    : null,
                child: avatar == null || avatar.isEmpty
                    ? Text(
                        name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.accentSoft,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'Public Vault',
                    style: TextStyle(
                        fontSize: 12, color: Colors.white38),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Public Vault tab — friend's for-sale + public items
// ---------------------------------------------------------------------------

class _PublicVaultTab extends ConsumerWidget {
  const _PublicVaultTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _FriendItemsLoader(
      builder: (items, cards) {
        if (items.isEmpty) {
          return const Center(
            child: Text(
              'This vault is empty.',
              style: TextStyle(color: Colors.white38),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(14),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.62,
          ),
          itemCount: items.length,
          itemBuilder: (_, i) {
            final item = items[i];
            final card = cards[item.cardRef.id];
            return _FriendCardTile(item: item, card: card);
          },
        );
      },
    );
  }
}

class _FriendItemsLoader extends ConsumerWidget {
  const _FriendItemsLoader({required this.builder});
  final Widget Function(
      List<CollectionItem> items, Map<String, CardDocument?> cards) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This is a simplified view — in production query
    // user_collection/{friendUid}/items where isPublic == true
    return FutureBuilder<List<CollectionItem>>(
      future: _loadItems(ref),
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snap.data ?? [];
        return FutureBuilder<Map<String, CardDocument?>>(
          future: _loadCards(items, ref),
          builder: (_, cardSnap) {
            final cards = cardSnap.data ?? {};
            return builder(items, cards);
          },
        );
      },
    );
  }

  Future<List<CollectionItem>> _loadItems(WidgetRef ref) async {
    final snap = await FirebaseFirestore.instance
        .collection('user_collection')
        .doc(_friendUid(ref))
        .collection('items')
        .limit(60)
        .get();

    return snap.docs.map((d) {
      try {
        return CollectionItem.fromJson({'id': d.id, ...d.data()});
      } catch (_) {
        return null;
      }
    }).whereType<CollectionItem>().toList();
  }

  Future<Map<String, CardDocument?>> _loadCards(
    List<CollectionItem> items,
    WidgetRef ref,
  ) async {
    final fs = ref.read(firestoreServiceProvider);
    final result = <String, CardDocument?>{};
    for (final item in items) {
      final id = item.cardRef.id;
      result[id] ??= await fs.getCard(id);
    }
    return result;
  }

  // Extract friendUid from the provider — delegated via InheritedWidget trick.
  // In practice this is passed via the route parameter stored in
  // [_FriendUidScope] higher in the tree.
  String _friendUid(WidgetRef ref) =>
      ref.read(_friendUidScopeProvider);
}

// Simple provider that holds the currently-viewed friend UID
// (set by FriendVaultScreen via ProviderScope override).
final _friendUidScopeProvider = Provider<String>((_) => '');

class _FriendCardTile extends StatelessWidget {
  const _FriendCardTile({required this.item, this.card});
  final CollectionItem item;
  final CardDocument? card;

  @override
  Widget build(BuildContext context) {
    final isSlab = item.condition.type == ConditionType.slab;
    final grade = item.condition.slab?.grade;
    final imageUrl = card?.meta.imageUrl ?? '';

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        fit: StackFit.expand,
        children: [
          imageUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: imageUrl, fit: BoxFit.cover)
              : Container(
                  color: const Color(0xFF162038),
                  child: const Icon(Icons.style_rounded,
                      color: Colors.white12, size: 24),
                ),
          // Grade overlay
          if (isSlab && grade != null)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  grade == grade.truncateToDouble()
                      ? grade.toInt().toString()
                      : grade.toString(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms);
  }
}

// ---------------------------------------------------------------------------
// Wishlist tab
// ---------------------------------------------------------------------------

class _WishlistTab extends ConsumerWidget {
  const _WishlistTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendUid = ref.read(_friendUidScopeProvider);

    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(friendUid)
          .collection('wishlist')
          .get(),
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(
            child: Text(
              'Wishlist is empty or private.',
              style: TextStyle(color: Colors.white38),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(14),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final name = data['cardName'] as String? ?? docs[i].id;
            final imageUrl = data['imageUrl'] as String? ?? '';

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF162038),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  if (imageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: 36,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      width: 36,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.style_rounded,
                          color: Colors.white24, size: 16),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Icon(Icons.favorite_rounded,
                      size: 14, color: Colors.white24),
                ],
              ),
            ).animate(delay: Duration(milliseconds: 40 * i)).fadeIn();
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Compare / DNA tab
// ---------------------------------------------------------------------------

class _DnaTab extends ConsumerWidget {
  const _DnaTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendUid = ref.read(_friendUidScopeProvider);
    final dnaAsync = ref.watch(portfolioDnaProvider(friendUid));

    return dnaAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(
        child: Text('Could not load comparison.',
            style: TextStyle(color: Colors.white38)),
      ),
      data: (dna) => dna == null
          ? const Center(
              child: Text('No comparison data.',
                  style: TextStyle(color: Colors.white38)),
            )
          : _DnaBody(dna: dna),
    );
  }
}

class _DnaBody extends StatelessWidget {
  const _DnaBody({required this.dna});
  final PortfolioDna dna;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header
        Row(
          children: [
            const Icon(Icons.compare_arrows_rounded,
                size: 16, color: AppColors.accent),
            const SizedBox(width: 8),
            const Text(
              'Portfolio DNA',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'How your vault compares to ${dna.friendDisplayName}',
          style: const TextStyle(fontSize: 12, color: Colors.white38),
        ),
        const SizedBox(height: 16),

        // DNA lines
        ...dna.dnaLines.asMap().entries.map((e) => _DnaLine(
              line: e.value,
              delay: Duration(milliseconds: 100 * e.key),
            )),
      ],
    );
  }
}

class _DnaLine extends StatelessWidget {
  const _DnaLine({required this.line, required this.delay});
  final String line;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF162038),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•',
              style: TextStyle(
                  fontSize: 16,
                  color: AppColors.accent,
                  fontWeight: FontWeight.w800)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              line,
              style: const TextStyle(
                  fontSize: 13, color: Colors.white70, height: 1.4),
            ),
          ),
        ],
      ),
    )
        .animate(delay: delay)
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.05, end: 0);
  }
}
