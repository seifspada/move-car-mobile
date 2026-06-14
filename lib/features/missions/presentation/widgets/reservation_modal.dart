// lib/features/missions/presentation/widgets/reservation_modal.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/reservation_entity.dart';
import '../providers/reservation_providers.dart';
// Adaptez ce chemin à votre MissionDetail entity
import '../../domain/entities/mission_entity.dart';

class ReservationModal extends ConsumerStatefulWidget {
  final MissionDetail mission;
  final VoidCallback onClose;
  final void Function(ReservationResponseEntity response)? onConfirm;
  final int estimatedDurationMinutes;

  const ReservationModal({
    super.key,
    required this.mission,
    required this.onClose,
    this.onConfirm,
    this.estimatedDurationMinutes = 0,
  });

  static Future<void> show(
    BuildContext context, {
    required MissionDetail mission,
    void Function(ReservationResponseEntity)? onConfirm,
    int estimatedDurationMinutes = 0,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReservationModal(
        mission: mission,
        onClose: () => Navigator.of(context).pop(),
        onConfirm: onConfirm,
        estimatedDurationMinutes: estimatedDurationMinutes,
      ),
    );
  }

  @override
  ConsumerState<ReservationModal> createState() => _ReservationModalState();
}

class _ReservationModalState extends ConsumerState<ReservationModal> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  String? _dateError;
  String? _timeError;

  // ── Computed arrival ──────────────────────────────────────────────────────

  DateTime? get _arrivalDateTime {
    if (_selectedDate == null || _selectedTime == null) return null;
    final depart = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
    final durationMin = widget.estimatedDurationMinutes > 0
        ? widget.estimatedDurationMinutes
        : (((widget.mission.calculs?.distanceKm ?? 0) / 80) * 60).round();
    return depart.add(Duration(minutes: durationMin));
  }

  // ── Date/time bounds from mission ─────────────────────────────────────────

  DateTime? get _dateMin {
    final s = widget.mission.disponibilite?.dateDebut;
    return s != null ? DateTime.tryParse(s) : null;
  }

  DateTime? get _dateMax {
    final s = widget.mission.disponibilite?.dateDepartMax ??
        widget.mission.disponibilite?.dateFin;
    return s != null ? DateTime.tryParse(s) : null;
  }

  // ── Validation ────────────────────────────────────────────────────────────

  bool _validate() {
    String? dErr, tErr;

    if (_selectedDate == null) {
      dErr = 'Veuillez sélectionner une date';
    } else {
      final d = _selectedDate!;
      if (_dateMin != null && d.isBefore(_stripTime(_dateMin!))) {
        dErr = 'Date trop tôt (min: ${_fmt(_dateMin!)})';
      } else if (_dateMax != null && d.isAfter(_stripTime(_dateMax!))) {
        dErr = 'Date trop tard (max: ${_fmt(_dateMax!)})';
      }
    }

    if (_selectedTime == null) {
      tErr = 'Veuillez sélectionner une heure';
    } else if (_selectedDate != null) {
      final dt = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
      if (_dateMin != null && dt.isBefore(_dateMin!)) {
        tErr = 'Heure trop tôt (min: ${_fmtTime(_dateMin!)})';
      } else if (_dateMax != null && dt.isAfter(_dateMax!)) {
        tErr = 'Heure trop tard (max: ${_fmtTime(_dateMax!)})';
      }
    }

    setState(() {
      _dateError = dErr;
      _timeError = tErr;
    });

    return dErr == null && tErr == null;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  DateTime _stripTime(DateTime d) => DateTime(d.year, d.month, d.day);

  String _fmt(DateTime d) =>
      DateFormat('dd/MM/yyyy à HH:mm', 'fr').format(d);

  String _fmtTime(DateTime d) => DateFormat('HH:mm').format(d);

  String _dateLabel(DateTime d) => DateFormat('dd/MM/yyyy').format(d);

  String _timeLabel(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  // ── Actions ───────────────────────────────────────────────────────────────

Future<void> _pickDate() async {
  final now = DateTime.now();
  final first = _dateMin ?? now;
  final last = _dateMax ?? now.add(const Duration(days: 365));

  final picked = await showDatePicker(
    context: context,
    initialDate: _selectedDate ?? (first.isAfter(now) ? first : now),
    firstDate: first,
    lastDate: last,
    // ✅ pas de locale ici — géré globalement dans MaterialApp
  );
  if (picked != null) {
    setState(() {
      _selectedDate = picked;
      _dateError = null;
    });
  }
}

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _timeError = null;
      });
    }
  }

  Future<void> _handleConfirm() async {
    if (!_validate()) return;

    final input = CreateReservationInput(
      missionId: widget.mission.id,
      dateDepart: DateFormat('yyyy-MM-dd').format(_selectedDate!),
      heureDepart: _timeLabel(_selectedTime!),
    );

    final notifier = ref.read(createReservationProvider.notifier);
    final response = await notifier.createReservation(input);

    if (!mounted) return;

    _handleResponse(response);
  }

  void _handleResponse(ReservationResponseEntity response) {
    if (response.success && response.reservation != null) {
      _showSnack(
        '✅ Réservation créée — N° ${response.reservation!.numeroReservation}',
        Colors.green,
      );
      widget.onConfirm?.call(response);
      widget.onClose();
      return;
    }

    switch (response.errorCode) {
      case ReservationErrorCode.reservationAlreadyExists:
        _showSnack(
          '📋 Demande déjà envoyée pour cette mission',
          Colors.blue,
        );
        widget.onClose();
        break;
      case ReservationErrorCode.missionNotAvailable:
        _showSnack('Mission indisponible', Colors.red);
        widget.onClose();
        break;
      case ReservationErrorCode.adherentNotAuthorized:
        _showSnack('Compte non autorisé — activez votre compte', Colors.red);
        break;
      case ReservationErrorCode.invalidDepartureDate:
        _showSnack(response.message, Colors.orange);
        break;
      case ReservationErrorCode.missionNotFound:
        _showSnack('Cette mission n\'existe plus', Colors.red);
        widget.onClose();
        break;
      default:
        _showSnack(response.message, Colors.red);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createReservationProvider);
    final loading = state.loading;

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1E293B), // slate-900
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(
            top: BorderSide(color: Color(0x4DF97316)), // orange-500/30
          ),
        ),
        child: Column(
          children: [
            // ── Handle ──────────────────────────────────────────────────────
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today,
                      color: Color(0xFFF97316), size: 22),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Réserver cette mission',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Sélectionnez votre date et heure de départ',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: loading ? null : widget.onClose,
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
            ),

            const Divider(color: Color(0x4DF97316)),

            // ── Scrollable body ──────────────────────────────────────────────
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                children: [
                  // Mission info card
                  _InfoCard(mission: widget.mission),
                  const SizedBox(height: 20),

                  // Date picker
                  _SectionLabel(label: 'Date de départ *'),
                  const SizedBox(height: 8),
                  _PickerTile(
                    icon: Icons.calendar_today_outlined,
                    label: _selectedDate != null
                        ? _dateLabel(_selectedDate!)
                        : 'Choisir une date',
                    error: _dateError,
                    onTap: loading ? null : _pickDate,
                  ),
                  if (_dateMin != null && _dateMax != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Période : ${_fmt(_dateMin!)} — ${_fmt(_dateMax!)}',
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 11),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Time picker
                  _SectionLabel(label: 'Heure de départ *'),
                  const SizedBox(height: 8),
                  _PickerTile(
                    icon: Icons.access_time_outlined,
                    label: _selectedTime != null
                        ? _timeLabel(_selectedTime!)
                        : 'Choisir une heure',
                    error: _timeError,
                    onTap: loading ? null : _pickTime,
                  ),

                  // Estimated arrival
                  if (_arrivalDateTime != null) ...[
                    const SizedBox(height: 20),
                    _ArrivalCard(
                      arrival: _arrivalDateTime!,
                      durationMin: widget.estimatedDurationMinutes > 0
                          ? widget.estimatedDurationMinutes
                          : (((widget.mission.calculs?.distanceKm ?? 0) / 80) *
                                  60)
                              .round(),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Info alert
                  _InfoAlert(
                    text:
                        'La réservation sera confirmée après validation. Vous recevrez une notification avec tous les détails de votre mission.',
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),

            // ── Footer ──────────────────────────────────────────────────────
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                border: Border(
                  top: BorderSide(color: Color(0x4DF97316)),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: loading ? null : widget.onClose,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed:
                          loading || _selectedDate == null || _selectedTime == null
                              ? null
                              : _handleConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF97316),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            const Color(0xFFF97316).withOpacity(0.4),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Confirmer la réservation',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sous-widgets internes
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      );
}

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? error;
  final VoidCallback? onTap;

  const _PickerTile({
    required this.icon,
    required this.label,
    this.error,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = error != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: hasError
                    ? Colors.red
                    : const Color(0x4DF97316),
              ),
            ),
            child: Row(
              children: [
                Icon(icon,
                    color: hasError
                        ? Colors.red
                        : const Color(0xFFF97316),
                    size: 20),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color:
                        hasError ? Colors.red[300] : Colors.white,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right,
                    color: Colors.grey, size: 20),
              ],
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.error_outline,
                  color: Colors.red, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  error!,
                  style: const TextStyle(
                      color: Colors.red, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final MissionDetail mission;
  const _InfoCard({required this.mission});

  @override
  Widget build(BuildContext context) {
    // ✅ Utilisation sécurisée avec ?. et ??
    final departCity = mission.adresseDepart?.villeNom ?? 'Départ';
    final arriveeCity = mission.adresseArrivee?.villeNom ?? 'Arrivée';
    
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x33F97316)),
      ),
      child: Row(
        children: [
          const Icon(Icons.navigation,
              color: Color(0xFFF97316), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$departCity → $arriveeCity',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (mission.calculs != null)
                  Text(
                    '${mission.calculs!.distanceKm.toStringAsFixed(0)} km',
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ArrivalCard extends StatelessWidget {
  final DateTime arrival;
  final int durationMin;
  const _ArrivalCard(
      {required this.arrival, required this.durationMin});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline,
              color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Arrivée estimée',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _ArrivalField(
                      label: 'Date',
                      value: DateFormat('dd/MM/yyyy').format(arrival),
                    ),
                    const SizedBox(width: 20),
                    _ArrivalField(
                      label: 'Heure',
                      value: DateFormat('HH:mm').format(arrival),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Durée estimée : $durationMin min',
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ArrivalField extends StatelessWidget {
  final String label;
  final String value;
  const _ArrivalField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.grey, fontSize: 11)),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _InfoAlert extends StatelessWidget {
  final String text;
  const _InfoAlert({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline,
              color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Information importante',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}