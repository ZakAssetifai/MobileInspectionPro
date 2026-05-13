import 'package:flutter/material.dart';
import '../core/responsive.dart';
import '../data/models.dart';
import '../theme/app_colors.dart';
import '../widgets/primary_button.dart';
import 'inspection_view_screen.dart';

/// Brief "submitted" confirmation that bridges into the read-only view.
class InspectionSummaryScreen extends StatelessWidget {
  const InspectionSummaryScreen({super.key, required this.inspection});
  final Inspection inspection;

  @override
  Widget build(BuildContext context) {
    final pad = Responsive.isTablet(context) ? 32.0 : 16.0;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(pad),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: AppColors.statusSyncedBg,
                      borderRadius: BorderRadius.circular(42),
                    ),
                    child: const Icon(Icons.check,
                        color: AppColors.statusSynced, size: 44),
                  ),
                  const SizedBox(height: 20),
                  const Text('Inspection submitted',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 24)),
                  const SizedBox(height: 6),
                  Text(
                    '${inspection.asset.name} · ${inspection.kind.label.toLowerCase()}',
                    style: const TextStyle(
                        color: AppColors.textTertiary, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Open inspection',
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            InspectionViewScreen(inspection: inspection),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.popUntil(
                        context, (r) => r.isFirst),
                    child: const Text('Back to home'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
