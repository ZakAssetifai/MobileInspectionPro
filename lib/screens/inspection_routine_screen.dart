import 'package:flutter/material.dart';
import '../core/responsive.dart';
import '../data/models.dart';
import '../theme/app_colors.dart';
import '../widgets/section_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/status_chip.dart';
import 'element_detail_screen.dart';
import 'inspection_summary_screen.dart';

class InspectionRoutineScreen extends StatefulWidget {
  const InspectionRoutineScreen({super.key, required this.inspection});
  final Inspection inspection;

  @override
  State<InspectionRoutineScreen> createState() =>
      _InspectionRoutineScreenState();
}

class _InspectionRoutineScreenState extends State<InspectionRoutineScreen> {
  int _step = 1;

  @override
  Widget build(BuildContext context) {
    final pad = Responsive.isTablet(context) ? 32.0 : 16.0;
    final ins = widget.inspection;
    final stepTitles = const [
      'Site conditions',
      'Asset attributes',
      'Element walkthrough',
      'Summary & submit',
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: AppColors.surface,
              padding: EdgeInsets.fromLTRB(pad, 12, pad, 16),
              child: StepHeader(
                title:
                    '${ins.kind.label[0]}${ins.kind.label.substring(1).toLowerCase()} inspection',
                subtitle: 'Step $_step of ${stepTitles.length} · ${stepTitles[_step - 1]}',
                totalSteps: stepTitles.length,
                currentStep: _step,
                trailing: _step > 1
                    ? IconButton(
                        onPressed: () => setState(() => _step--),
                        icon: const Icon(Icons.history),
                        color: AppColors.primary,
                      )
                    : null,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(pad),
                child: ContentColumn(
                  padding: EdgeInsets.zero,
                  child: _buildStep(context, ins),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, Inspection ins) {
    switch (_step) {
      case 1:
        return _SiteConditionsStep(
          inspection: ins,
          onChanged: () => setState(() {}),
          onNext: () => setState(() => _step = 2),
        );
      case 2:
        return _AssetAttributesStep(
          inspection: ins,
          onChanged: () => setState(() {}),
          onNext: () => setState(() => _step = 3),
        );
      case 3:
        return _WalkthroughStep(
          inspection: ins,
          onChanged: () => setState(() {}),
          onNext: () => setState(() => _step = 4),
        );
      default:
        return _SummaryStep(
          inspection: ins,
          onChanged: () => setState(() {}),
          onSubmit: () {
            ins.status = InspectionStatus.submitted;
            ins.submitted = DateTime.now();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => InspectionSummaryScreen(inspection: ins),
              ),
            );
          },
        );
    }
  }
}

class _AssetCard extends StatelessWidget {
  const _AssetCard({required this.inspection});
  final Inspection inspection;
  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Row(children: [
        AssetThumbnail(tag: inspection.asset.kind.tag),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(inspection.asset.id,
                  style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6)),
              const SizedBox(height: 4),
              Text(inspection.asset.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16)),
              Row(children: [
                const Icon(Icons.location_on_outlined,
                    size: 14, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                Text(inspection.asset.region,
                    style: const TextStyle(
                        color: AppColors.textTertiary, fontSize: 12.5)),
              ]),
            ],
          ),
        ),
      ]),
    );
  }
}

// -------------------- Step 1: Site Conditions --------------------

class _SiteConditionsStep extends StatelessWidget {
  const _SiteConditionsStep({
    required this.inspection,
    required this.onNext,
    required this.onChanged,
  });
  final Inspection inspection;
  final VoidCallback onNext;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AssetCard(inspection: inspection),
        const SizedBox(height: 18),
        const Text('Weather conditions',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final w in WeatherCondition.values) ...[
                _WeatherTile(
                  weather: w,
                  selected: inspection.weather == w,
                  onTap: () {
                    inspection.weather = w;
                    onChanged();
                  },
                ),
                const SizedBox(width: 10),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),
        SectionCard(
          child: Row(children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.warningBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.error_outline,
                  size: 16, color: AppColors.warningFg),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Access restricted?',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14)),
                  SizedBox(height: 2),
                  Text(
                    'Are any elements unreachable or unsafe to inspect?',
                    style: TextStyle(
                        color: AppColors.textTertiary, fontSize: 12.5),
                  ),
                ],
              ),
            ),
            Switch(
              value: inspection.accessRestricted,
              activeColor: AppColors.primary,
              onChanged: (v) {
                inspection.accessRestricted = v;
                onChanged();
              },
            ),
          ]),
        ),
        if (inspection.accessRestricted) ...[
          const SizedBox(height: 10),
          TextField(
            decoration:
                const InputDecoration(hintText: 'Brief reason / notes'),
            onChanged: (v) => inspection.accessNotes = v,
          ),
        ],
        const SizedBox(height: 18),
        PrimaryButton(label: 'Continue', onPressed: onNext),
      ],
    );
  }
}

class _WeatherTile extends StatelessWidget {
  const _WeatherTile(
      {required this.weather,
      required this.selected,
      required this.onTap});
  final WeatherCondition weather;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 86,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Column(children: [
          Icon(weather.icon,
              size: 22,
              color: selected ? AppColors.primary : AppColors.textSecondary),
          const SizedBox(height: 8),
          Text(weather.label.toUpperCase(),
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: 0.6,
                  color: selected
                      ? AppColors.primary
                      : AppColors.textSecondary)),
        ]),
      ),
    );
  }
}

// -------------------- Step 2: Element Walkthrough --------------------

// =================================================================
//  Step 2 — Asset attributes
// =================================================================

class _AssetAttributesStep extends StatefulWidget {
  const _AssetAttributesStep({
    required this.inspection,
    required this.onNext,
    required this.onChanged,
  });
  final Inspection inspection;
  final VoidCallback onNext;
  final VoidCallback onChanged;

  @override
  State<_AssetAttributesStep> createState() => _AssetAttributesStepState();
}

class _AssetAttributesStepState extends State<_AssetAttributesStep> {
  bool _editing = false;
  int _photoCount = 0;

  @override
  Widget build(BuildContext context) {
    final a = widget.inspection.asset;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AssetCard(inspection: widget.inspection),
        const SizedBox(height: 18),

        // ---- "No, keep as-is / Yes, edit attributes" toggle ----
        Row(children: [
          Expanded(
            child: _ChoicePill(
              label: 'No, keep as-is',
              selected: !_editing,
              onTap: () => setState(() => _editing = false),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ChoicePill(
              label: 'Yes, edit attributes',
              selected: _editing,
              onTap: () => setState(() => _editing = true),
            ),
          ),
        ]),
        const SizedBox(height: 14),

        // ---- Attribute list ----
        SectionCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _attr('Year built', '${a.yearBuilt}'),
              _attr('Primary material', a.material),
              _attr('Length (m)', '${a.length.toInt()}'),
              _attr('Width (m)', _editing ? '—' : '—'),
              _attr('Height / clearance (m)', '—'),
              _attr('Lanes', '—'),
              _attr('Deck / surface', '—'),
              _attr('Traffic (AADT)', '—'),
              _attr('Skew angle (°)', '0'),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // ---- Asset photos & files ----
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Asset photos & files',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14)),
                      SizedBox(height: 2),
                      Text(
                        'Optionally attach new photos, documents or other files for this asset.',
                        style: TextStyle(
                            color: AppColors.textTertiary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Text('$_photoCount',
                    style: const TextStyle(
                        color: AppColors.textTertiary, fontSize: 12)),
              ]),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => setState(() => _photoCount++),
                icon: const Icon(Icons.photo_camera_outlined, size: 18),
                label: const Text('Add photo or file'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(46),
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.border),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),
        PrimaryButton(label: 'Continue', onPressed: widget.onNext),
      ],
    );
  }

  Widget _attr(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textTertiary, fontSize: 12)),
          const SizedBox(height: 2),
          if (_editing)
            TextField(
              controller: TextEditingController(text: value == '—' ? '' : value),
              decoration: const InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
            )
          else
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 14.5)),
        ],
      ),
    );
  }
}

class _ChoicePill extends StatelessWidget {
  const _ChoicePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: selected ? AppColors.primary : AppColors.border),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _WalkthroughStep extends StatelessWidget {
  const _WalkthroughStep({
    required this.inspection,
    required this.onNext,
    required this.onChanged,
  });
  final Inspection inspection;
  final VoidCallback onNext;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTablet(context);
    final rated = inspection.ratedCount;
    final total = inspection.totalElements;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AssetCard(inspection: inspection),
        const SizedBox(height: 18),
        Row(children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rate each element',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16)),
                Text('AASHTO – Saudi Highway Code (SHC)',
                    style: TextStyle(
                        color: AppColors.textTertiary, fontSize: 12)),
              ],
            ),
          ),
          Text('$rated/$total done',
              style: const TextStyle(
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12)),
        ]),
        const SizedBox(height: 12),
        if (isTablet)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 540,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              mainAxisExtent: 168,
            ),
            itemCount: inspection.elements.length,
            itemBuilder: (_, i) => _ElementTile(
              element: inspection.elements[i],
              inspection: inspection,
              onChanged: onChanged,
            ),
          )
        else
          Column(
            children: [
              for (final el in inspection.elements) ...[
                _ElementTile(
                  element: el,
                  inspection: inspection,
                  onChanged: onChanged,
                ),
                const SizedBox(height: 10),
              ]
            ],
          ),
        const SizedBox(height: 18),
        PrimaryButton(
          label: rated == 0 ? 'Skip & continue' : 'Continue',
          onPressed: onNext,
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'Per-element ratings are optional — you can set just an overall condition next.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _ElementTile extends StatelessWidget {
  const _ElementTile({
    required this.element,
    required this.inspection,
    required this.onChanged,
  });
  final InspectionElement element;
  final Inspection inspection;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final hasRating = element.rating != null;
    final isInstance = element.byInstance;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ElementDetailScreen(
                element: element, inspection: inspection),
          ),
        );
        onChanged();
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 40,
                height: 38,
                decoration: BoxDecoration(
                  color: hasRating
                      ? element.rating!.color.withOpacity(0.18)
                      : const Color(0xFFEEF1F4),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(
                    hasRating
                        ? Icons.check_circle_outline
                        : Icons.image_outlined,
                    size: 20,
                    color: hasRating
                        ? element.rating!.color
                        : AppColors.textSecondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(element.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14.5)),
                    Text(element.description,
                        style: const TextStyle(
                            color: AppColors.textTertiary, fontSize: 12.5)),
                  ],
                ),
              ),
              if (element.aiAvailable && !hasRating)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.aiAccentBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: const [
                    Icon(Icons.auto_awesome,
                        size: 12, color: AppColors.aiAccent),
                    SizedBox(width: 4),
                    Text('AI',
                        style: TextStyle(
                            color: AppColors.aiAccent,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700)),
                  ]),
                ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right,
                  color: AppColors.textTertiary),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              _ToggleChip(
                label: 'COMBINED',
                icon: Icons.layers_outlined,
                selected: !isInstance,
                onTap: () {
                  element.byInstance = false;
                  onChanged();
                },
              ),
              const SizedBox(width: 6),
              _ToggleChip(
                label: 'BY INSTANCE',
                icon: Icons.format_list_numbered,
                selected: isInstance,
                onTap: () {
                  element.byInstance = true;
                  onChanged();
                },
              ),
              const SizedBox(width: 8),
              if (isInstance && hasRating)
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: element.rating!.color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                        'C${element.rating!.value} · ${element.rating!.label}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 10.5,
                            letterSpacing: 0.4)),
                  ),
                  const SizedBox(width: 6),
                  Text('${element.defects.length} INSTANCES',
                      style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6)),
                ]),
            ]),
            const SizedBox(height: 10),
            if (!isInstance)
              Row(children: [
                for (final r in ConditionRating.values) ...[
                  Expanded(
                    child: _RatingButton(
                      rating: r,
                      selected: element.rating == r,
                      onTap: () {
                        element.rating = r;
                        onChanged();
                      },
                    ),
                  ),
                  if (r != ConditionRating.values.last)
                    const SizedBox(width: 6),
                ],
              ])
            else
              ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ElementDetailScreen(
                          element: element,
                          inspection: inspection,
                          forceInstance: true),
                    ),
                  );
                  onChanged();
                },
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(46)),
                child: const Text('Open instance workflow'),
              ),
          ],
        ),
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  const _ToggleChip(
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: fg, size: 13),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w700,
                  fontSize: 10.5,
                  letterSpacing: 0.5)),
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
        padding: const EdgeInsets.symmetric(vertical: 8),
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
                  fontSize: 14,
                  color: selected ? color : AppColors.textPrimary)),
          Text(rating.label,
              style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w700,
                  color: selected ? color : AppColors.textTertiary)),
        ]),
      ),
    );
  }
}

// -------------------- Step 3: Summary --------------------

class _SummaryStep extends StatelessWidget {
  const _SummaryStep({
    required this.inspection,
    required this.onSubmit,
    required this.onChanged,
  });
  final Inspection inspection;
  final VoidCallback onSubmit;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final ins = inspection;
    final rated = ins.ratedCount;
    final critical =
        ins.elements.where((e) => e.immediateRisk).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AssetCard(inspection: ins),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
              child: _SummaryStat(
                  value: '$rated/${ins.totalElements}',
                  label: 'ELEMENTS')),
          const SizedBox(width: 10),
          Expanded(
              child: _SummaryStat(
                  value: '$critical', label: 'CRITICAL')),
          const SizedBox(width: 10),
          Expanded(
              child: _SummaryStat(
                  value: ins.weather?.label ?? '—', label: 'WEATHER')),
        ]),
        const SizedBox(height: 18),
        const Text('Overall condition',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const Text('AASHTO – Saudi Highway Code (SHC)',
            style:
                TextStyle(color: AppColors.textTertiary, fontSize: 12.5)),
        const SizedBox(height: 10),
        Row(children: [
          for (final r in ConditionRating.values) ...[
            Expanded(
              child: _RatingButton(
                rating: r,
                selected: ins.overallCondition == r,
                onTap: () {
                  ins.overallCondition = r;
                  onChanged();
                },
              ),
            ),
            if (r != ConditionRating.values.last)
              const SizedBox(width: 8),
          ],
        ]),
        const SizedBox(height: 18),
        const Text('Inspector notes',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          maxLines: 4,
          decoration: const InputDecoration(
              hintText: 'General observations, follow-ups, recommendations…'),
          onChanged: (v) => ins.inspectorNotes = v,
        ),
        const SizedBox(height: 18),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Element summary',
                  style:
                      TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 8),
              for (final e in ins.elements)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(children: [
                    Icon(
                        e.rating != null
                            ? Icons.check_circle_outline
                            : Icons.close,
                        size: 16,
                        color: e.rating != null
                            ? AppColors.primary
                            : AppColors.textTertiary),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(e.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600))),
                    if (e.rating != null)
                      RatingChip(rating: e.rating!)
                    else
                      const Text('Not rated',
                          style: TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 12.5)),
                  ]),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        PrimaryButton(
            label: 'Submit inspection',
            icon: Icons.send,
            onPressed: onSubmit),
      ],
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({required this.value, required this.label});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: [
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 22)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6)),
      ]),
    );
  }
}
