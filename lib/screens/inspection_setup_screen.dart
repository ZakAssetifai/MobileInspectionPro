import 'package:flutter/material.dart';
import '../core/responsive.dart';
import '../data/dummy_data.dart';
import '../data/models.dart';
import '../theme/app_colors.dart';
import '../widgets/section_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/status_chip.dart';
import 'inspection_routine_screen.dart';

class InspectionSetupScreen extends StatefulWidget {
  const InspectionSetupScreen({super.key, required this.asset});
  final Asset asset;

  @override
  State<InspectionSetupScreen> createState() => _InspectionSetupScreenState();
}

class _InspectionSetupScreenState extends State<InspectionSetupScreen> {
  InspectionKind _kind = InspectionKind.routine;

  @override
  Widget build(BuildContext context) {
    final pad = Responsive.isTablet(context) ? 32.0 : 16.0;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: AppColors.surface,
              padding: EdgeInsets.fromLTRB(pad, 12, pad, 16),
              child: const StepHeader(
                title: 'Inspection setup',
                subtitle: 'Step 2 of 2 · Configure',
                totalSteps: 2,
                currentStep: 2,
                trailing: Icon(Icons.arrow_back, color: AppColors.primary),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(pad),
                child: ContentColumn(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.asset.id,
                                style: const TextStyle(
                                    color: AppColors.textTertiary,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.6)),
                            const SizedBox(height: 4),
                            Text(widget.asset.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 18)),
                            const SizedBox(height: 6),
                            Row(children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 14, color: AppColors.textTertiary),
                              const SizedBox(width: 4),
                              Text(widget.asset.region,
                                  style: const TextStyle(
                                      color: AppColors.textTertiary,
                                      fontSize: 13)),
                            ]),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text('Inspection type',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16)),
                      const SizedBox(height: 10),
                      for (final k in InspectionKind.values) ...[
                        _KindOption(
                          kind: k,
                          selected: _kind == k,
                          onTap: () => setState(() => _kind = k),
                        ),
                        const SizedBox(height: 10),
                      ],
                      const SizedBox(height: 8),
                      PrimaryButton(
                        label: 'Continue',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => InspectionRoutineScreen(
                                inspection: Inspection(
                                  id: 'INS-${DateTime.now().millisecondsSinceEpoch}',
                                  asset: widget.asset,
                                  kind: _kind,
                                  status: InspectionStatus.draft,
                                  elements: DummyData.defaultElements(),
                                  started: DateTime.now(),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F0F0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date · ${_formatDate(DateTime.now())}',
                              style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            const Text('Inspector · You',
                                style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}, ${two(d.hour)}:${two(d.minute)}:${two(d.second)}';
  }
}

class _KindOption extends StatelessWidget {
  const _KindOption(
      {required this.kind, required this.selected, required this.onTap});
  final InspectionKind kind;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(children: [
          KindChip(kind: kind),
          const SizedBox(width: 12),
          Expanded(
            child: Text(kind.description,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
          ),
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? AppColors.primary : Colors.transparent,
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: 1.4,
              ),
            ),
            child: selected
                ? const Icon(Icons.check, color: Colors.white, size: 14)
                : null,
          ),
        ]),
      ),
    );
  }
}
