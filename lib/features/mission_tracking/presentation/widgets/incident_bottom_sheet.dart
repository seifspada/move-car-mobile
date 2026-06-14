import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/mission_incident_providers.dart';
import 'incident_photo_picker.dart';

const List<String> kIncidentTypes = [
  'DÉVIATION_GPS',
  'VITESSE_EXCESSIVE',
  'ARRÊT_PROLONGÉ',
  'DÉTOUR_INJUSTIFIÉ',
  'ANOMALIE_CARBURANT',
];

class IncidentBottomSheet extends ConsumerStatefulWidget {
  final String sessionId;
  final double latitude;
  final double longitude;

  const IncidentBottomSheet({
    super.key,
    required this.sessionId,
    required this.latitude,
    required this.longitude,
  });

  @override
  ConsumerState<IncidentBottomSheet> createState() => _IncidentBottomSheetState();
}

class _IncidentBottomSheetState extends ConsumerState<IncidentBottomSheet> {
  String _selectedType = kIncidentTypes[0];
  final _descController = TextEditingController();
  final List<String> _photos = [];

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_descController.text.trim().isEmpty) return;
    final success = await ref.read(incidentProvider(widget.sessionId).notifier).report(
      sessionId: widget.sessionId,
      typeIncident: _selectedType,
      description: _descController.text.trim(),
      latitude: widget.latitude,
      longitude: widget.longitude,
      photos: _photos.isEmpty ? null : _photos,
    );
    if (success && mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(incidentProvider(widget.sessionId));

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Signaler un incident',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedType,
            items: kIncidentTypes
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (v) => setState(() => _selectedType = v!),
            decoration: const InputDecoration(
              labelText: 'Type d\'incident',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          IncidentPhotoPicker(
            photos: _photos,
            onAdd: (b64) => setState(() => _photos.add(b64)),
            onRemove: (i) => setState(() => _photos.removeAt(i)),
          ),
          const SizedBox(height: 16),
          if (state.error != null)
            Text(state.error!, style: const TextStyle(color: Colors.red)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state.isSubmitting ? null : _submit,
              child: state.isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Envoyer'),
            ),
          ),
        ],
      ),
    );
  }
}