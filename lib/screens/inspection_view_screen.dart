import 'package:flutter/material.dart';
import '../core/responsive.dart';
import '../data/models.dart';
import '../theme/app_colors.dart';
import '../widgets/section_card.dart';
import '../widgets/status_chip.dart';

class InspectionViewScreen extends StatelessWidget {
  const InspectionViewScreen({super.key, required this.inspection});
  final Inspection inspection;

  @override
  Widget build(BuildContext context) {
    final pad = Responsive.isTablet(context) ? 32.0 : 16.0;
    final ins = inspection;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ins.asset.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700)),
            Text('${ins.id} · ${ins.kind.label.toLowerCase()}',
                style:
                    const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        leading: const BackButton(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(child: StatusChip(status: ins.status)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(pad),
        child: ContentColumn(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionCard(
                child: Column(children: [
                  const Text('Site conditions',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 8),
                  _SiteRow(
                      icon: Icons.cloud_outlined,
                      label: 'Weather',
                      value: ins.weather?.label ?? '—'),
                  _SiteRow(
                      icon: Icons.event_outlined,
                      label: 'Started',
                      value: _fmt(ins.started)),
                  _SiteRow(
                      icon: Icons.send_outlined,
                      label: 'Submitted',
                      value: ins.submitted != null
                          ? _fmt(ins.submitted!)
                          : '—'),
                  _SiteRow(
                      icon: Icons.shield_outlined,
                      label: 'Access',
                      value: ins.accessRestricted
                          ? 'Restricted${ins.accessNotes.isEmpty ? '' : ' · ${ins.accessNotes}'}'
                          : 'Unrestricted'),
                ]),
              ),
              const SizedBox(height: 18),
              const Text('Elements',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 10),
              for (final el in ins.elements) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: el.rating != null
                            ? el.rating!.color.withOpacity(0.18)
                            : const Color(0xFFEEF1F4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                          el.rating != null
                              ? Icons.check_circle_outline
                              : Icons.radio_button_unchecked,
                          size: 18,
                          color: el.rating != null
                              ? el.rating!.color
                              : AppColors.textTertiary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(el.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700)),
                          Text(el.description,
                              style: const TextStyle(
                                  color: AppColors.textTertiary,
                                  fontSize: 12.5)),
                        ],
                      ),
                    ),
                    if (el.rating != null) RatingChip(rating: el.rating!),
                  ]),
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 18),
              const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline,
                        size: 14, color: AppColors.textTertiary),
                    SizedBox(width: 6),
                    Text('Inspection submitted · read-only',
                        style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 12.5)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _fmt(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}, ${two(d.hour)}:${two(d.minute)}:${two(d.second)}';
  }
}

class _SiteRow extends StatelessWidget {
  const _SiteRow(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(color: AppColors.textSecondary)),
        const Spacer(),
        Flexible(
          child: Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }
}
