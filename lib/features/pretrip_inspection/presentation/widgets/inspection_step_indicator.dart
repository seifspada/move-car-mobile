// lib/features/pretrip_inspection/presentation/widgets/inspection_step_indicator.dart

import 'package:convoyeur_mobile/features/pretrip_inspection/data/models/pretrip_model.dart';
import 'package:flutter/material.dart';
import '../theme/pretrip_theme.dart';

class InspectionStepIndicator extends StatelessWidget {
  final EtapeInspection currentStep;

  const InspectionStepIndicator({super.key, required this.currentStep});

  static const _steps = [
    EtapeInspection.exterieur,
    EtapeInspection.interieur,
    EtapeInspection.tableauBord,
    EtapeInspection.documents,
    EtapeInspection.identite,
    EtapeInspection.conditions,
  ];

  @override
  Widget build(BuildContext context) {
    final currentIdx = currentStep.stepIndex.clamp(0, _steps.length - 1);

    return Container(
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 12),
      // ✅ Couleur dans BoxDecoration
      decoration: BoxDecoration(
        color: PreTripTheme.surface1,
        border: Border(
          bottom: BorderSide(color: PreTripTheme.border, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: List.generate(_steps.length * 2 - 1, (i) {
                if (i.isOdd) {
                  final stepIdx = i ~/ 2;
                  final isDone = stepIdx < currentIdx;
                  return _StepConnector(isDone: isDone);
                }
                final stepIdx = i ~/ 2;
                final step = _steps[stepIdx];
                final isDone = stepIdx < currentIdx;
                final isCurrent = stepIdx == currentIdx;
                return _StepItem(
                  step: step,
                  stepNumber: stepIdx + 1,
                  isDone: isDone,
                  isCurrent: isCurrent,
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Étape ${currentIdx + 1}/${_steps.length} — ${currentStep.label}',
              style: const TextStyle(
                color: PreTripTheme.textHint,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepConnector extends StatelessWidget {
  final bool isDone;
  const _StepConnector({required this.isDone});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 20,
      height: 2,
      margin: const EdgeInsets.only(bottom: 20),
      // ✅ Couleur dans BoxDecoration
      decoration: BoxDecoration(
        color: isDone
            ? PreTripTheme.success.withOpacity(0.5)
            : PreTripTheme.border,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final EtapeInspection step;
  final int stepNumber;
  final bool isDone;
  final bool isCurrent;

  const _StepItem({
    required this.step,
    required this.stepNumber,
    required this.isDone,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final Color circleColor;
    final Color labelColor;
    final Widget circleChild;
    List<BoxShadow>? shadows;

    if (isDone) {
      circleColor = PreTripTheme.success.withOpacity(0.15);
      labelColor = PreTripTheme.success;
      circleChild = const Icon(
        Icons.check,
        size: 13,
        color: PreTripTheme.success,
      );
    } else if (isCurrent) {
      circleColor = PreTripTheme.primaryDim;
      labelColor = PreTripTheme.primaryLight;
      circleChild = Text(
        '$stepNumber',
        style: const TextStyle(
          color: PreTripTheme.primaryLight,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      );
      shadows = [
        BoxShadow(
          color: PreTripTheme.primary.withOpacity(0.5),
          blurRadius: 12,
          spreadRadius: 1,
        ),
      ];
    } else {
      circleColor = PreTripTheme.surface2;
      labelColor = PreTripTheme.textHint;
      circleChild = Text(
        '$stepNumber',
        style: const TextStyle(
          color: PreTripTheme.textHint,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return SizedBox(
      width: 58,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: isCurrent ? 28 : 24,
            height: isCurrent ? 28 : 24,
            // ✅ Couleur dans BoxDecoration
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDone
                    ? PreTripTheme.success.withOpacity(0.5)
                    : isCurrent
                    ? PreTripTheme.primary
                    : PreTripTheme.border,
                width: 1.5,
              ),
              boxShadow: shadows,
            ),
            child: Center(child: circleChild),
          ),
          const SizedBox(height: 6),
          Text(
            step.label,
            style: TextStyle(
              color: labelColor,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
