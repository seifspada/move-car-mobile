// lib/features/missions/presentation/widgets/city_autocomplete.dart

import 'package:convoyeur_mobile/features/missions/data/models/mission_model.dart';
import 'package:convoyeur_mobile/features/missions/data/repositories/city_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CityAutocompleteField extends ConsumerStatefulWidget {
  final String label;
  final String placeholder;
  // ✅ CORRIGÉ: Utiliser SelectedCityModel
  final Function(SelectedCityModel) onCitySelected;
  final SelectedCityModel? initialCity;

  const CityAutocompleteField({
    super.key,
    required this.label,
    required this.placeholder,
    required this.onCitySelected,
    this.initialCity,
  });

  @override
  ConsumerState<CityAutocompleteField> createState() =>
      _CityAutocompleteFieldState();
}

class _CityAutocompleteFieldState extends ConsumerState<CityAutocompleteField> {
  late TextEditingController _controller;
  // ✅ CORRIGÉ: Utiliser SelectedCityModel
  SelectedCityModel? _selectedCity;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _selectedCity = widget.initialCity;
    if (widget.initialCity != null) {
      _controller.text = widget.initialCity!.name;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = ref.watch(searchCommunesProvider(_controller.text));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            color: Colors.grey[300],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey[700]!,
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: _controller,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: widget.placeholder,
              hintStyle: TextStyle(color: Colors.grey[600]),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              suffixIcon: _selectedCity != null
                  ? GestureDetector(
                      onTap: () {
                        _controller.clear();
                        setState(() {
                          _selectedCity = null;
                          _showSuggestions = false;
                        });
                      },
                      child: Icon(
                        Icons.close,
                        color: Colors.grey[600],
                        size: 18,
                      ),
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {
                _showSuggestions = value.length >= 2;
                if (_selectedCity != null &&
                    value != _selectedCity!.name) {
                  _selectedCity = null;
                }
              });
            },
            onSubmitted: (value) {
              setState(() => _showSuggestions = false);
            },
          ),
        ),
        // 💡 Suggestions
        if (_showSuggestions && _controller.text.length >= 2)
          suggestions.when(
            loading: () => Padding(
              padding: EdgeInsets.only(top: 8),
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation(Colors.orange[600]),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Chargement...',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            error: (error, stack) => Padding(
              padding: EdgeInsets.only(top: 8),
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Erreur lors de la recherche',
                  style: TextStyle(
                    color: Colors.red[300],
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            // ✅ CORRIGÉ: communes est List<CommuneModel>
            data: (communes) => communes.isEmpty
                ? Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Aucun résultat',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  )
                : Container(
                    margin: EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: communes
                          .map((commune) =>
                              _buildSuggestionItem(commune))
                          .toList(),
                    ),
                  ),
          ),
      ],
    );
  }

  // ✅ CORRIGÉ: commune est CommuneModel
  Widget _buildSuggestionItem(CommuneModel commune) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (commune.latitude != null && commune.longitude != null) {
            // ✅ CORRIGÉ: Créer SelectedCityModel
            final selectedCity = SelectedCityModel(
              name: commune.nom,
              lat: commune.latitude!,
              lon: commune.longitude!,
            );
            setState(() {
              _selectedCity = selectedCity;
              _controller.text = commune.nom;
              _showSuggestions = false;
            });
            widget.onCitySelected(selectedCity);
          }
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                Icons.location_on,
                size: 14,
                color: Colors.orange[600],
              ),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    commune.nom,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (commune.codesPostaux?.isNotEmpty ?? false)
                    Text(
                      commune.codesPostaux!.first,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}