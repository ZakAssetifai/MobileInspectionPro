import 'package:flutter/material.dart';
import '../core/responsive.dart';
import '../data/models.dart';
import '../theme/app_colors.dart';
import '../widgets/section_card.dart';
import '../widgets/status_chip.dart';
import '../widgets/primary_button.dart';
import 'instance_editor_screen.dart';

/// Detail screen for an element. Combined view shows visual capture / AI / defects /
/// rating / risk in a single page. By-instance view lists individual instances.
class ElementDetailScreen extends StatefulWidget {
  const ElementDetailScreen({
    super.key,
    required this.element,
    required this.inspection,
    this.forceInstance = false,
  });
  final InspectionElement element;
  final Inspection inspection;
  final bool forceInstance;

  @override
  State<ElementDetailScreen> createState() => _ElementDetailScreenState();
}

class _ElementDetailScreenState extends State<ElementDetailScreen> {
  late bool _byInstance =
      widget.forceInstance || widget.element.byInstance;

  @override
  Widget build(BuildContext context) {
    final pad = Responsive.isTablet(context) ? 32.0 : 16.0;
    final el = widget.element;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(el.name,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700)),
            Text(
              _byInstance
                  ? 'By-instance · ${widget.inspection.asset.name}'
                  : widget.inspection.asset.name,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        leading: const BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(pad),
        child: ContentColumn(
          padding: EdgeInsets.zero,
          child: _byInstance ? _buildInstanceView() : _buildCombinedView(),
        ),
      ),
    );
  }

  /// Pushes the full-page Instance editor and rebuilds when it returns so
  /// the freshly-edited values show up in the list immediately.
  Future<bool?> _openInstanceEditor(Defect d, int instanceNumber) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => InstanceEditorScreen(
          element: widget.element,
          defect: d,
          instanceNumber: instanceNumber,
        ),
      ),
    );
    if (mounted) setState(() {});
    return saved;
  }

  Widget _buildCombinedView() {
    final el = widget.element;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionCard(
          child: Row(children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rating mode',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14)),
                  Text('One combined rating for this element',
                      style: TextStyle(
                          color: AppColors.textTertiary, fontSize: 12.5)),
                ],
              ),
            ),
            _ModeChip(
                label: 'COMBINED',
                icon: Icons.layers_outlined,
                selected: !_byInstance,
                onTap: () => setState(() => _byInstance = false)),
            const SizedBox(width: 6),
            _ModeChip(
                label: 'BY\nINSTANCE',
                icon: Icons.format_list_numbered,
                selected: _byInstance,
                onTap: () => setState(() => _byInstance = true)),
          ]),
        ),
        const SizedBox(height: 14),
        _LabeledSection(
          letter: 'A',
          title: 'Visual capture',
          trailing: '${el.defects.length} ITEMS',
          child: Column(children: [
            Container(
              height: 110,
              decoration: BoxDecoration(
                color: AppColors.aiAccentBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.aiAccent.withOpacity(0.4),
                    style: BorderStyle.solid),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.photo_camera_outlined,
                      color: AppColors.aiAccent, size: 26),
                  SizedBox(height: 6),
                  Text('Capture',
                      style: TextStyle(
                          color: AppColors.aiAccent,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(children: const [
              Expanded(
                  child: GhostButton(
                      label: 'Upload',
                      icon: Icons.file_upload_outlined,
                      onPressed: null)),
              SizedBox(width: 10),
              Expanded(
                  child: GhostButton(
                      label: '+ Annotate',
                      icon: Icons.edit_outlined,
                      onPressed: null)),
            ]),
          ]),
        ),
        const SizedBox(height: 14),
        _LabeledSection(
          letter: 'B',
          title: 'AI defect detection',
          trailing: 'HUMAN-CONFIRMED',
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                el.defects.add(Defect(
                  type: 'Corrosion / Rust Staining',
                  severity: DefectSeverity.medium,
                  notes: 'Detected by AI · awaiting confirmation',
                ));
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.aiAccent.withOpacity(0.55),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(46),
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.auto_awesome, size: 16),
                  SizedBox(width: 6),
                  Text('Analyze with AI'),
                ]),
          ),
        ),
        const SizedBox(height: 14),
        _LabeledSection(
          letter: 'C',
          title: 'Defects',
          trailing:
              '${el.defects.length} LOGGED',
          child: Column(children: [
            for (final d in el.defects) ...[
              _DefectEditor(
                  defect: d,
                  types: el.defectTypes,
                  onChanged: () => setState(() {}),
                  onDelete: () => setState(() => el.defects.remove(d))),
              const SizedBox(height: 10),
            ],
            DottedAddRow(
                label: '+ Add defect manually',
                onTap: () => setState(() {
                      el.defects.add(Defect(
                          type: el.defectTypes.first,
                          severity: DefectSeverity.medium));
                    })),
          ]),
        ),
        const SizedBox(height: 14),
        _LabeledSection(
          letter: 'D',
          title: 'Condition rating',
          trailing: '1=EXCELLENT · 4=CRITICAL',
          child: Row(children: [
            for (final r in ConditionRating.values) ...[
              Expanded(
                child: _RatingButton(
                  rating: r,
                  selected: el.rating == r,
                  onTap: () => setState(() => el.rating = r),
                ),
              ),
              if (r != ConditionRating.values.last)
                const SizedBox(width: 6),
            ],
          ]),
        ),
        const SizedBox(height: 14),
        _LabeledSection(
          letter: 'E',
          title: 'Risk & action',
          child: Column(children: [
            Row(children: [
              const Expanded(
                child: Text('Immediate risk',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              Switch(
                value: el.immediateRisk,
                activeColor: AppColors.severityHigh,
                onChanged: (v) => setState(() => el.immediateRisk = v),
              ),
            ]),
            const SizedBox(height: 8),
            TextField(
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Recommendation / follow-up action',
              ),
              onChanged: (v) => el.notes = v,
            ),
          ]),
        ),
        const SizedBox(height: 18),
        PrimaryButton(
          label: 'Save & return',
          icon: Icons.check,
          onPressed: () {
            widget.element.byInstance = _byInstance;
            Navigator.pop(context);
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildInstanceView() {
    final el = widget.element;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.aiAccentBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(children: [
            Icon(Icons.auto_awesome, size: 16, color: AppColors.aiAccent),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Record each defect instance separately. Element rollup uses the worst rating.',
                style: TextStyle(
                    color: AppColors.aiAccent,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 14),
        for (var i = 0; i < el.defects.length; i++) ...[
          _InstanceTile(
            index: i + 1,
            defect: el.defects[i],
            onEdit: () => _openInstanceEditor(el.defects[i], i + 1),
            onDelete: () => setState(() => el.defects.removeAt(i)),
          ),
          const SizedBox(height: 10),
        ],
        DottedAddRow(
          label: '+ Add instance',
          onTap: () async {
            // Create a fresh defect, push the editor immediately so the
            // inspector can fill it in. If they cancel via X (returns false /
            // null) we discard the empty draft.
            final draft = Defect(
                type: '',
                severity: DefectSeverity.low,
                label: 'Instance ${el.defects.length + 1}');
            el.defects.add(draft);
            final saved =
                await _openInstanceEditor(draft, el.defects.length);
            if (saved != true) {
              setState(() => el.defects.remove(draft));
            }
          },
        ),
        const SizedBox(height: 14),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Element condition rating',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 4),
              const Text(
                'AASHTO 1–4 · Saudi Highway Code (SHC). Final rating recorded for this element.',
                style: TextStyle(
                    color: AppColors.textTertiary, fontSize: 12.5),
              ),
              const SizedBox(height: 10),
              Row(children: [
                for (final r in ConditionRating.values) ...[
                  Expanded(
                    child: _RatingButton(
                      rating: r,
                      selected: el.rating == r,
                      onTap: () => setState(() => el.rating = r),
                    ),
                  ),
                  if (r != ConditionRating.values.last)
                    const SizedBox(width: 6),
                ],
              ]),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(
            child: GhostButton(
              label: 'Return without saving',
              icon: Icons.arrow_back,
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: PrimaryButton(
              label: 'Save & return (${el.defects.length})',
              icon: Icons.check,
              onPressed: () {
                widget.element.byInstance = true;
                Navigator.pop(context);
              },
            ),
          ),
        ]),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _LabeledSection extends StatelessWidget {
  const _LabeledSection({
    required this.letter,
    required this.title,
    required this.child,
    this.trailing,
  });
  final String letter;
  final String title;
  final Widget child;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(11),
              ),
              alignment: Alignment.center,
              child: Text(letter,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 11)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14)),
            ),
            if (trailing != null)
              Text(trailing!,
                  style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 11,
                      letterSpacing: 0.6,
                      fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip(
      {required this.label,
      required this.icon,
      required this.selected,
      required this.onTap});
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : AppColors.textSecondary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: fg, size: 13),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w700,
                  fontSize: 10.5,
                  height: 1.1,
                  letterSpacing: 0.4)),
        ]),
      ),
    );
  }
}

class _RatingButton extends StatelessWidget {
  const _RatingButton(
      {required this.rating,
      required this.selected,
      required this.onTap});
  final ConditionRating rating;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = rating.color;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.18) : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? color : Colors.transparent,
            width: selected ? 1.4 : 0,
          ),
        ),
        child: Column(children: [
          Text('${rating.value}',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: selected ? color : AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(rating.label,
              style: TextStyle(
                  fontSize: 9.5,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w700,
                  color: selected ? color : AppColors.textTertiary)),
        ]),
      ),
    );
  }
}

class _DefectEditor extends StatelessWidget {
  const _DefectEditor({
    required this.defect,
    required this.types,
    required this.onChanged,
    required this.onDelete,
  });
  final Defect defect;
  final List<String> types;
  final VoidCallback onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            SeverityChip(severity: defect.severity),
            const Spacer(),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline,
                  color: AppColors.severityHigh, size: 18),
              style: IconButton.styleFrom(
                backgroundColor:
                    AppColors.severityHigh.withOpacity(0.08),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                minimumSize: const Size(34, 34),
              ),
            ),
          ]),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: types.contains(defect.type) ? defect.type : null,
            isDense: true,
            decoration: const InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            items: [
              for (final t in types)
                DropdownMenuItem(value: t, child: Text(t)),
            ],
            onChanged: (v) {
              if (v != null) {
                defect.type = v;
                onChanged();
              }
            },
          ),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: DropdownButtonFormField<DefectSeverity>(
                value: defect.severity,
                decoration: const InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: [
                  for (final s in DefectSeverity.values)
                    DropdownMenuItem(value: s, child: Text(s.label)),
                ],
                onChanged: (v) {
                  if (v != null) {
                    defect.severity = v;
                    onChanged();
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 80,
              child: TextField(
                controller:
                    TextEditingController(text: defect.extent.toString()),
                keyboardType: TextInputType.number,
                onChanged: (v) {
                  defect.extent = int.tryParse(v) ?? 0;
                  onChanged();
                },
              ),
            ),
          ]),
          const SizedBox(height: 8),
          TextField(
            controller: TextEditingController(text: defect.notes),
            decoration:
                const InputDecoration(hintText: 'Notes…'),
            onChanged: (v) => defect.notes = v,
          ),
        ],
      ),
    );
  }
}

class DottedAddRow extends StatelessWidget {
  const DottedAddRow({super.key, required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.aiAccent.withOpacity(0.4)),
        ),
        child: Text(label,
            style: const TextStyle(
                color: AppColors.aiAccent, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _InstanceTile extends StatelessWidget {
  const _InstanceTile({
    required this.index,
    required this.defect,
    required this.onEdit,
    required this.onDelete,
  });
  final int index;
  final Defect defect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final label = defect.label.isEmpty ? 'Instance $index' : defect.label;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onEdit,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text('#$index',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 11.5)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14)),
                      const SizedBox(height: 4),
                      Row(children: [
                        Text(
                          defect.type.isEmpty ? '— Not set —' : defect.type,
                          style: TextStyle(
                              color: defect.type.isEmpty
                                  ? AppColors.textTertiary
                                  : AppColors.textSecondary,
                              fontSize: 12.5),
                        ),
                        const SizedBox(width: 8),
                        SeverityChip(severity: defect.severity),
                      ]),
                      if (defect.locationDescription.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.location_on_outlined,
                              size: 12, color: AppColors.textTertiary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              defect.locationDescription,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: AppColors.textTertiary,
                                  fontSize: 11.5),
                            ),
                          ),
                        ]),
                      ],
                      if (defect.immediateRisk) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.warningBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.warning_amber_rounded,
                                  size: 12,
                                  color: AppColors.severityHigh),
                              SizedBox(width: 4),
                              Text('IMMEDIATE RISK',
                                  style: TextStyle(
                                      color: AppColors.severityHigh,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.6)),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right,
                    color: AppColors.textTertiary),
              ]),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          OutlinedButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 14),
            label: const Text('Edit'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(70, 36),
              foregroundColor: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline,
                size: 14, color: AppColors.severityHigh),
            label: const Text('Delete',
                style: TextStyle(color: AppColors.severityHigh)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(70, 36),
              foregroundColor: AppColors.severityHigh,
              side: BorderSide(
                  color: AppColors.severityHigh.withOpacity(0.4)),
            ),
          ),
        ]),
      ]),
            ),
          ),
        ),
      );
  }
}
