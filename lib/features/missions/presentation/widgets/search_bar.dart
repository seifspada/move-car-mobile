// lib/features/missions/presentation/widgets/search_bar.dart

import 'package:convoyeur_mobile/features/missions/data/models/mission_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/mission_providers.dart';

class SearchBarWidget extends ConsumerStatefulWidget {
  final Function(String)? onSearch;

  const SearchBarWidget({
    super.key,
    this.onSearch,
  });

  @override
  ConsumerState<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends ConsumerState<SearchBarWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() {
      setState(() {}); // pour afficher/cacher le bouton clear
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    // ✅ Connecte au provider → déclenche SEARCH_MISSIONS
    ref.read(searchQueryProvider.notifier).state = value;
    ref.read(searchModeProvider.notifier).state = SearchMode.text;
    ref.read(currentPageProvider.notifier).state = 1;

    widget.onSearch?.call(value);
  }

  void _clearSearch() {
    _controller.clear();

    // ✅ Reset les providers
    ref.read(searchQueryProvider.notifier).state = '';
    ref.read(searchModeProvider.notifier).state = SearchMode.text;
    ref.read(currentPageProvider.notifier).state = 1;

    widget.onSearch?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[800]!,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // 🔍 Icône recherche
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Icon(
              Icons.search,
              color: Colors.grey[600],
              size: 20,
            ),
          ),
          // 📝 Champ de texte
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Rechercher une mission...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          // ❌ Bouton clear
          if (_controller.text.isNotEmpty)
            GestureDetector(
              onTap: _clearSearch,
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  Icons.close,
                  color: Colors.grey[600],
                  size: 18,
                ),
              ),
            ),
        ],
      ),
    );
  }
}