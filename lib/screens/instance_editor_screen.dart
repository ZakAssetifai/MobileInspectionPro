import 'package:flutter/material.dart';
import '../core/responsive.dart';
import '../data/models.dart';
import '../theme/app_colors.dart';
import '../widgets/section_card.dart';

/// Full-page "Edit defect instance" editor.
///
/// Replaces the inline tile that used to expand under each instance row.
/// The editor matches the layout shown in the reference video:
/// label/location, photos, AI analyze, defect type, severity, extent,
/// LOCATION block (description + GPS + 3D markup), Immediate-risk pink
/// banner, and free-form notes — with X / Save in the header.
class InstanceEditorScreen extends StatefulWidget {
  const InstanceEditorScreen({
    super.key,
    required this.element,
    required this.defect,
    required this.instanceNumber,
  });

  final InspectionElement element;
  final Defect defect;
  final int instanceNumber;

  @override
  State<InstanceEditorScreen> createState() => _InstanceEditorScreenState();
}

class _InstanceEditorScreenState extends State<InstanceEditorScreen> {
  late final TextEditingController _label;
  late final TextEditingController _locationDesc;
  late final TextEditingController _extent;
  late final TextEditingController _notes;

  late String _type;
  late DefectSeverity _severity;
  late bool _immediateRisk;
  late bool _markerPlaced;
  late String _gps;
  late int _photoCount;

  @override
  void initState() {
    super.initState();
    final d = widget.defect;
    _label = TextEditingController(
        text: d.label.isEmpty ? 'Instance ${widget.instanceNumber}' : d.label);
    _locationDesc = TextEditingController(text: d.locationDescription);
    _extent = TextEditingController(text: d.extent > 0 ? '${d.extent}' : '');
    _notes = TextEditingController(text: d.notes);
    _type = widget.element.defectTypes.contains(d.type) ? d.type : '';
    _severity = d.severity;
    _immediateRisk = d.immediateRisk;
    _markerPlaced = d.markerPlaced;
    _gps = d.gpsCoordinates;
    _photoCount = d.photoCount;
  }

  @override
  void dispose() {
    _label.dispose();
    _locationDesc.dispose();
    _extent.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _save() {
    final d = widget.defect;
    d.label = _label.text.trim();
    d.locationDescription = _locationDesc.text.trim();
    d.extent = int.tryParse(_extent.text.trim()) ?? 0;
    d.notes = _notes.text.trim();
    if (_type.isNotEmpty) d.type = _type;
    d.severity = _severity;
    d.immediateRisk = _immediateRisk;
    d.markerPlaced = _markerPlaced;
    d.gpsCoordinates = _gps;
    d.photoCount = _photoCount;
    Navigator.pop(context, true);
  }

  void _captureGps() {
    // Faux GPS capture — replace with platform plugin call later.
    setState(() {
      _gps = '24.5803, 46.6193';
    });
  }

  @override
  Widget build(BuildContext context) {
    final pad = Responsive.isTablet(context) ? 32.0 : 16.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(
            onPressed: () => Navigator.pop(context, false),
            icon: const Icon(Icons.close, color: AppColors.textPrimary),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceMuted,
              shape: const CircleBorder(),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_label.text.isEmpty
                ? 'Instance ${widget.instanceNumber}'
                : _label.text),
            const Text(
              'Edit defect instance',
              style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 12, 8),
            child: ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Save'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(96, 40),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                textStyle:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(pad, 16, pad, 32),
        child: ContentColumn(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -------- LABEL / LOCATION --------
              const _Label('LABEL / LOCATION'),
              const SizedBox(height: 8),
              TextField(
                controller: _label,
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: 16),
              const _Label('PHOTOS'),
              const SizedBox(height: 8),
              _PhotoCapture(
                count: _photoCount,
                onCapture: () => setState(() => _photoCount++),
                onClear: _photoCount == 0
                    ? null
                    : () => setState(() => _photoCount = 0),
              ),

              const SizedBox(height: 12),
              _AnalyzeAiButton(
                onTap: () {
                  if (_type.isEmpty) {
                    setState(() {
                      _type = widget.element.defectTypes.isEmpty
                          ? 'Concrete Cracking'
                          : widget.element.defectTypes.first;
                      _severity = DefectSeverity.medium;
                    });
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      duration: Duration(seconds: 2),
                      backgroundColor: AppColors.primary,
                      content: Text('AI analysis complete · suggestion applied'),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),
              const _Label('DEFECT TYPE'),
              const SizedBox(height: 8),
              _Dropdown<String>(
                value: _type.isEmpty ? null : _type,
                hint: '— Select —',
                items: widget.element.defectTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _type = v ?? ''),
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Label('SEVERITY'),
                        const SizedBox(height: 8),
                        _Dropdown<DefectSeverity>(
                          value: _severity,
                          hint: 'Severity',
                          items: DefectSeverity.values
                              .map((s) => DropdownMenuItem(
                                    value: s,
                                    child: Row(children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                            color: s.color,
                                            shape: BoxShape.circle),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(s.label[0] +
                                          s.label.substring(1).toLowerCase()),
                                    ]),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _severity = v ?? _severity),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Label('EXTENT %'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _extent,
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(hintText: 'e.g. 15'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // -------- LOCATION --------
              const SizedBox(height: 18),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: const [
                      Icon(Icons.location_on_outlined,
                          size: 16, color: AppColors.textPrimary),
                      SizedBox(width: 6),
                      Text('Location',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14)),
                    ]),
                    const SizedBox(height: 12),
                    const _Label('LOCATION DESCRIPTION'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _locationDesc,
                      decoration: const InputDecoration(
                          hintText: 'e.g. Underside of deck, span 2, near pier'),
                    ),
                    const SizedBox(height: 14),
                    const _Label('LOCATION COORDINATES (GPS)'),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            _gps.isEmpty ? 'Not captured yet' : _gps,
                            style: TextStyle(
                              color: _gps.isEmpty
                                  ? AppColors.textTertiary
                                  : AppColors.textPrimary,
                              fontFamily: 'monospace',
                              fontWeight: _gps.isEmpty
                                  ? FontWeight.normal
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _captureGps,
                        icon: const Icon(Icons.my_location, size: 18),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.surfaceMuted,
                          foregroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(
                                  color: AppColors.border)),
                          padding: const EdgeInsets.all(14),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 6),
                    const Text(
                      'GPS coordinates will be auto-captured when the live app connects to device GPS.',
                      style: TextStyle(
                          color: AppColors.textTertiary, fontSize: 11.5),
                    ),
                    const SizedBox(height: 14),
                    const _Label('LOCATION MARKUP (3D)'),
                    const SizedBox(height: 8),
                    _MarkupRow(
                      placed: _markerPlaced,
                      onTap: () => setState(() => _markerPlaced = !_markerPlaced),
                    ),
                  ],
                ),
              ),

              // -------- IMMEDIATE RISK --------
              const SizedBox(height: 14),
              _ImmediateRiskBanner(
                value: _immediateRisk,
                onChanged: (v) => setState(() => _immediateRisk = v),
              ),

              // -------- NOTES --------
              const SizedBox(height: 14),
              const _Label('NOTES'),
              const SizedBox(height: 8),
              TextField(
                controller: _notes,
                maxLines: 4,
                decoration: const InputDecoration(
                    hintText: 'Observations, dimensions, access notes…'),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Save instance'),
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(54)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =================== Local UI helpers ===================

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w700,
        fontSize: 11,
        letterSpacing: 1.1,
      ),
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  const _Dropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    required this.hint,
  });
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: const InputDecoration(
          contentPadding:
              EdgeInsets.symmetric(horizontal: 12, vertical: 4)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          hint: Text(hint,
              style: const TextStyle(color: AppColors.textTertiary)),
          icon: const Icon(Icons.keyboard_arrow_down,
              color: AppColors.textTertiary),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _PhotoCapture extends StatelessWidget {
  const _PhotoCapture({
    required this.count,
    required this.onCapture,
    required this.onClear,
  });
  final int count;
  final VoidCallback onCapture;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          onTap: onCapture,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.aiAccentBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.aiAccent.withOpacity(0.45),
                style: BorderStyle.solid,
                width: 1.5,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    count == 0
                        ? Icons.photo_camera_outlined
                        : Icons.collections_outlined,
                    color: AppColors.aiAccent,
                    size: 28,
                  ),
                  const SizedBox(height: 6),
                  Text(count == 0 ? 'Capture' : '$count photo${count == 1 ? '' : 's'}',
                      style: const TextStyle(
                          color: AppColors.aiAccent,
                          fontWeight: FontWeight.w700)),
                  if (count > 0)
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Text('Tap to add another',
                          style: TextStyle(
                              color: AppColors.aiAccent, fontSize: 11)),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (onClear != null)
          Positioned(
            right: 10,
            top: 10,
            child: IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.delete_outline,
                  color: AppColors.severityHigh, size: 18),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: const Size(32, 32),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: AppColors.border)),
              ),
            ),
          ),
      ],
    );
  }
}

class _AnalyzeAiButton extends StatelessWidget {
  const _AnalyzeAiButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.auto_awesome, size: 16),
        label: const Text('Analyze with AI'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.aiAccent.withOpacity(0.55),
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(46),
          elevation: 0,
        ),
      ),
    );
  }
}

class _MarkupRow extends StatelessWidget {
  const _MarkupRow({required this.placed, required this.onTap});
  final bool placed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Icon(
                  placed ? Icons.location_on : Icons.view_in_ar_outlined,
                  color: placed
                      ? AppColors.statusSynced
                      : AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      placed
                          ? 'Marker placed on wireframe'
                          : 'Place marker on 3D wireframe',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13.5),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      placed
                          ? 'Tap to re-position the marker'
                          : 'Open bridge wireframe to mark location',
                      style: const TextStyle(
                          color: AppColors.textTertiary, fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImmediateRiskBanner extends StatelessWidget {
  const _ImmediateRiskBanner(
      {required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.severityHigh.withOpacity(0.25)),
      ),
      child: Row(children: [
        const Icon(Icons.warning_amber_rounded,
            color: AppColors.severityHigh, size: 20),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Immediate risk',
                  style: TextStyle(
                      color: AppColors.severityCritical,
                      fontWeight: FontWeight.w700)),
              SizedBox(height: 2),
              Text('Flag if hazard or failure imminent',
                  style: TextStyle(
                      color: AppColors.severityHigh, fontSize: 12)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: AppColors.severityHigh,
        ),
      ]),
    );
  }
}
